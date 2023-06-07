/****** Object:  Procedure [dbo].[S_Get_DayWisePumpTestReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_Get_DayWisePumpTestReport_Mivin] 'R983032372','2021-08-01 00:00:00.000','2021-08-29 00:00:00.000'
[dbo].[S_Get_DayWisePumpTestReport_Mivin] '','2021-08-01 00:00:00.000','2021-08-31 00:00:00.000'
[dbo].[S_Get_DayWisePumpTestReport_Mivin] '','2022-03-01 00:00:00.000','2022-03-28 00:00:00.000'

*/
CREATE PROCEDURE [dbo].[S_Get_DayWisePumpTestReport_Mivin]
@PumpModel NVARCHAR(50),
@startdate DATETIME,
@EndDate DATETIME
AS
BEGIN

--declare @startdate datetime
DECLARE @StartTime datetime
declare @EndTime datetime
declare @strsql nvarchar(max)


--select @startdate=(select DATEFROMPARTS(year(@EndDate),month(@EndDate),'01'))

select @StartTime=dbo.f_GetLogicalDay(@startdate,'start')
select @EndTime=dbo.f_GetLogicalDay(@EndDate,'End') 


CREATE TABLE #DailyProductionFromAutodataT0 
(
	DDate datetime,
	Shift nvarchar(20),
	ShiftStart datetime,
	ShiftEnd datetime,
	shiftid nvarchar(20)
)


create table #DailyProductionFromAutodataT1
(
Pdate datetime NOT NULL,
FromTime datetime,
ToTime datetime,
ComponentID NVARCHAR(50),
)
create table #FinalData
(
ComponentID NVARCHAR(50),
CompInterface nvarchar(50),
Category NVARCHAR(50),
Pdate datetime NOT NULL,
FromTime datetime,
ToTime datetime,
TotalParts float,
TotalOk float,
TotalNotOk float,
Assemblyparts float,
StdCycleTime float,
PlannedQty float,
MaterialDownTime float,
MaterialLoss float,
AbsentDownTime float,
AbsentLoss float,
MaintainanceDown float,
MaintainanceLoss float,
PowerFailureDown float,
PowerFailureLoss float,
OtherDown float,
OtherLoss float
)

create table #summary
(
Category NVARCHAR(50),
Assemblyparts float,
TotalOk float,
TotalNotOk float,
MaterialDownTime float,
MaterialLoss float,
AbsentDownTime float,
AbsentLoss float,
MaintainanceDown float,
MaintainanceLoss float,
PowerFailureDown float,
PowerFailureLoss float,
OtherDown float,
OtherLoss float
)



CREATE TABLE #T_autodata(
	[mc] [nvarchar](50)not NULL,
	[comp] [nvarchar](50) NULL,
	[opn] [nvarchar](50) NULL,
	[opr] [nvarchar](50) NULL,
	[dcode] [nvarchar](50) NULL,
	[sttime] [datetime] not NULL,
	[ndtime] [datetime] not NULL,
	[datatype] [tinyint] NULL ,
	[cycletime] [int] NULL,
	[loadunload] [int] NULL ,
	[msttime] [datetime] not NULL,
	[PartsCount] decimal(18,5) NULL ,
	id  bigint not null
)

ALTER TABLE #T_autodata

ADD PRIMARY KEY CLUSTERED
(
	mc,sttime,ndtime,msttime ASC
)ON [PRIMARY]

Create table #PlannedDownTimes
(
	MachineID nvarchar(50),
	MachineInterface nvarchar(50),
	StartTime_LogicalDay DateTime,
	EndTime_LogicalDay DateTime,
	StartTime_PDT DateTime,
	EndTime_PDT DateTime,
	pPlannedDT float Default 0,
	dPlannedDT float Default 0,
	MPlannedDT float Default 0,
	IPlannedDT float Default 0,
	DownID nvarchar(50)
)

create table #Test1
(
Componentid nvarchar(50),
SlNo nvarchar(50),
CycleStart datetime,
MeasuredDatetime datetime,
RejDate datetime,
ReworkNo nvarchar(50),
RejBit bit,
TotalParts float
)



Declare @T_ST AS Datetime 
Declare @T_ED AS Datetime 

Select @T_ST=dbo.f_GetLogicalDay(@StartDate,'start')
Select @T_ED=dbo.f_GetLogicalDay(@EndDate,'End')


Select @strsql=''
select @strsql ='insert into #T_autodata '
select @strsql = @strsql + 'SELECT mc, comp, opn, opr, dcode,sttime,'
	select @strsql = @strsql + 'ndtime, datatype, cycletime, loadunload, msttime, PartsCount,id'
select @strsql = @strsql + ' from autodata where (( sttime >='''+ convert(nvarchar(25),@T_ST,120)+''' and ndtime <= '''+ convert(nvarchar(25),@T_ED,120)+''' ) OR '
select @strsql = @strsql + '( sttime <'''+ convert(nvarchar(25),@T_ST,120)+''' and ndtime >'''+ convert(nvarchar(25),@T_ED,120)+''' )OR '
select @strsql = @strsql + '( sttime <'''+ convert(nvarchar(25),@T_ST,120)+''' and ndtime >'''+ convert(nvarchar(25),@T_ST,120)+'''
					and ndtime<='''+convert(nvarchar(25),@T_ED,120)+''' )'
select @strsql = @strsql + ' OR ( sttime >='''+convert(nvarchar(25),@T_ST,120)+''' and ndtime >'''+ convert(nvarchar(25),@T_ED,120)+''' and sttime<'''+convert(nvarchar(25),@T_ED,120)+''' ) )'
print @strsql
exec (@strsql)



select @StartTime=@startdate
select @EndTime=@EndDate

Declare @lstart AS nvarchar(50) --ER0465
Declare @lend AS nvarchar(50) --ER0465

while @StartTime<=@EndTime
BEGIN
	SET @lstart = dbo.f_GetLogicalDay(@StartTime,'start') --ER0465
	SET @lend = dbo.f_GetLogicalDay(@StartTime,'End') --ER0465

	INSERT INTO #DailyProductionFromAutodataT1 (Pdate,FromTime,ToTime) 
	SELECT convert(nvarchar(20),@StartTime), @lstart,@lend 

	Insert into #PlannedDownTimes
	Select machineinformation.MachineID,machineinformation.InterfaceID,@lstart,@lend,
	 Case When StartTime<@lstart Then @lstart Else StartTime End as StartTime, 	
	 Case When EndTime > @lend Then @lend Else EndTime End as EndTime,
	 0,0,0,0,PlannedDownTimes.DownReason
	 from PlannedDownTimes inner join machineinformation on PlannedDownTimes.machine=machineinformation.machineid
	      Where PlannedDownTimes.PDTstatus =1 AND (
		(StartTime >= @lstart and EndTime <= @lend) OR
		(StartTime < @lstart and EndTime <= @lend and EndTime > @lstart) OR
		(StartTime >= @lstart and EndTime > @lend and StartTime < @lend) OR
		(StartTime < @lstart and EndTime > @lend))
		And machineinformation.MachineID in (select distinct MachineID from machineinformation where IsTestBenchMachine=1)
	--mod 4


	SELECT @StartTime=DATEADD(DAY,1,@StartTime)


end



insert into #FinalData(Pdate,FromTime,ToTime,ComponentID,CompInterface,Category)
SELECT distinct t1.Pdate,t1.FromTime,t1.ToTime,c1.PumpModel,c2.InterfaceID,M.PumpCategory FROM #DailyProductionFromAutodataT1 T1 CROSS JOIN ScheduleDetails C1
inner join componentinformation c2 on c1.PumpModel=c2.componentid
INNER JOIN PumpModelMaster_Mivin M ON M.PumpModel=C2.InterfaceID
WHERE (C1.PumpModel=@PumpModel OR ISNULL(@PUMPMODEL,'')='') AND C2.ISPUMPENABLED=1 and (date>=@startdate and date<=@EndDate)


--select m.pumpmodel,c.interfaceid,m.pumpcategory,convert(nvarchar(20),@EndDate),convert(nvarchar(20),@StartTime),convert(nvarchar(20),@endtime) from PumpModelMaster_Mivin m
--inner join componentinformation c on c.InterfaceID=m.PumpModel where (componentid=@ComponentID or isnull(@ComponentID,'')='') and IsPumpEnabled=1



DECLARE @StartTime1 DATETIME
DECLARE @EndTime1 DATETIME
select @StartTime1=dbo.f_GetLogicalDay(@StartDate,'start')
select @EndTime1=dbo.f_GetLogicalDay(@EndDate,'End') 

while @StartTime1<@EndTime1
BEGIN
INSERT #DailyProductionFromAutodataT0(DDate,Shift, ShiftStart, ShiftEnd)
EXEC s_GetShiftTime @StartTime1
	
	SELECT @StartTime1=DATEADD(DAY,1,@StartTime1)
END


Update #DailyProductionFromAutodataT0 Set shiftid = isnull(#DailyProductionFromAutodataT0.shiftid,0) + isnull(T1.shiftid,0) from    
(Select SD.shiftid ,SD.shiftname from shiftdetails SD    
inner join #DailyProductionFromAutodataT0 S on SD.shiftname=S.Shift where    
running=1 )T1 inner join #DailyProductionFromAutodataT0 on  T1.shiftname=#DailyProductionFromAutodataT0.Shift  


insert into #Test1(Componentid,SlNo,MeasuredDatetime)
select distinct PumpModel,SlNo,max(MeasuredDatetime) as MeasuredDatetime from PumpTestData_Mivin where (PumpModel=@PumpModel or isnull(@pumpmodel,'')='') and (MeasuredDatetime>=@T_ST and MeasuredDatetime<=@T_ED)
AND ISNULL(IsMasterPump,0)<>1
GROUP by PumpModel,SlNo

---------------------------------------------------------------------------------Cal for ReworkNo starts-------------------------------------------------------------------------------------------------------------------------

update #Test1 set ReworkNo=(T1.Rewrk)
from
(
select PumpModel,SlNo,isnull(max(reworkno),0) as Rewrk  from PumpTestData_Mivin
where (PumpModel=@PumpModel or isnull(@pumpmodel,'')='') and (MeasuredDatetime>=@T_ST and MeasuredDatetime<=@T_ED)
group by PumpModel,SlNo
)t1 inner join #Test1 on t1.PumpModel=#Test1.Componentid and t1.SlNo=#Test1.SlNo


--update #Test1 set ReworkNo=(t1.rewrk)
--from
--(select distinct pumpmodel,slno,MeasuredDatetime,reworkno as rewrk  from PumpTestData_Mivin where (PumpModel=@PumpModel or isnull(@pumpmodel,'')='') and (MeasuredDatetime>=@T_ST and MeasuredDatetime<=@T_ED)
--) t1 inner join #Test1 on t1.PumpModel=#Test1.Componentid and t1.SlNo=#Test1.SlNo and t1.MeasuredDatetime=#test1.MeasuredDatetime
---------------------------------------------------------------------------------Cal for ReworkNo ends-------------------------------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------Cal for RejBit starts-------------------------------------------------------------------------------------------------------------------------

update #Test1 set RejBit=(tt.Rej)
from
( select a.comp,a.WorkOrderNumber,1 as Rej from #Test1 t1 inner join AutodataRejections a  ON t1.Componentid=a.comp and a.WorkOrderNumber =
            CASE
               WHEN t1.ReworkNo IN (0)
                   THEN  t1.SlNo
               WHEN t1.ReworkNo IN (1,2,3,4,5,6,7,8,9,10)
                   THEN ((t1.SlNo+'_'+CAST(t1.ReworkNo AS NVARCHAR(10))))
               END
)tt inner join #Test1 on #Test1.Componentid=tt.comp and WorkOrderNumber =
            CASE
               WHEN ReworkNo IN (0)
                   THEN  SlNo
               WHEN ReworkNo IN (1,2,3,4,5,6,7,8,9,10)
                   THEN ((SlNo+'_'+CAST(ReworkNo AS NVARCHAR(10))))
               END
---------------------------------------------------------------------------------Cal for RejBit ends-------------------------------------------------------------------------------------------------------------------------

--update #FinalData set TotalNotOk=t1.notok
--from
--(
--select componentid,slno,measureddatetime,count(rejbit) as notok from #Test1
--group by componentid,slno,measureddatetime
--)t1 inner join #FinalData on #FinalData.ComponentID=t1.Componentid and #FinalData.Pdate=cast(t1.measureddatetime as date)

--------------------------------------------------------------------PlannedQty Cal starts ( pumpqty from  TPM_PACKING.dbo.ScheduleDetails table)------------------------------------------------------------------------------

update #FinalData set PlannedQty=t1.PumpQty
from
(
select pumpmodel,date,sum(PumpQty) as PumpQty from ScheduleDetails
group by pumpmodel,date
)t1 inner join #FinalData  on t1.PumpModel=#FinalData.CompInterface and t1.Date=#FinalData.Pdate

--------------------------------------------------------------------PlannedQty Cal ends ( pumpqty from  TPM_PACKING.dbo.ScheduleDetails table)------------------------------------------------------------------------------

-----------------------------------------------------------------------Cal for TotalParts starts------------------------------------------------------------------------------------------------------------------

-------------------------------OLD CAL----------------------------
--update #FinalData SET TotalParts=ISNULL(TOTALPARTS,0)+ISNULL(tt.Total,0)
--from
--(
--select t1.Componentid,slno,measureddatetime,count(*) as total from #Test1 t1
--inner join #FinalData f1 on f1.ComponentID=t1.Componentid
--where (MeasuredDatetime>=f1.FromTime and MeasuredDatetime<=f1.ToTime)
--group by t1.Componentid,SlNo,MeasuredDatetime
--) tt inner join #FinalData on #FinalData.CompInterface=tt.Componentid and #FinalData.Pdate=cast(measureddatetime as date)
-------------------------------OLD CAL----------------------------


--update #Test1 set TotalParts=ISNULL(tt.Total,0)
--from
--(
--select t1.Componentid,slno,measureddatetime,count(*) as total from #Test1 t1
--group by t1.Componentid,SlNo,MeasuredDatetime
--)tt inner join #Test1 on #Test1.Componentid=tt.Componentid and #Test1.SlNo=tt.SlNo and #Test1.MeasuredDatetime=tt.MeasuredDatetime

update #FinalData SET TotalParts=ISNULL(tt.total,0)
from
(
select t1.Componentid,f1.FromTime,f1.ToTime,count(SlNo) as total from #Test1 t1
inner join #FinalData f1 on f1.ComponentID=t1.Componentid
where (MeasuredDatetime>=f1.FromTime and MeasuredDatetime<=f1.ToTime)
group by t1.Componentid,f1.FromTime,f1.ToTime
) tt inner join #FinalData on #FinalData.CompInterface=tt.Componentid and #FinalData.FromTime=tt.FromTime and #FinalData.ToTime=tt.ToTime

-----------------------------------------------------------------------Cal for TotalParts ends---------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------Rejection Cal starts ---------------------------------------------------------------------------------------------------


Update #FinalData set TotalNotOk = isnull(TotalNotOk,0) + isnull(T1.RejQty,0)    
From    
( Select A.comp,SUM(A.Rejection_Qty) as RejQty,T1.Pdate from AutodataRejections A    
inner join componentinformation C on A.comp=C.interfaceid    
inner join #FinalData T1 on T1.CompInterface=A.comp
inner join #Test1 Te on te.Componentid=a.comp 
inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid    
where A.CreatedTS>=T1.FromTime and A.CreatedTS<T1.ToTime and A.flag = 'Rejection'    
and Isnull(A.Rejshift,'a')='a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'    
and te.RejBit=1
group by A.comp,T1.Pdate
)T1 inner join #FinalData B on B.CompInterface=T1.comp and B.Pdate=T1.Pdate     
 
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'    
BEGIN    
 Update #FinalData set TotalNotOk = isnull(TotalNotOk,0) - isnull(T1.RejQty,0) from    
 (Select A.comp,SUM(A.Rejection_Qty) as RejQty,T1.Pdate from AutodataRejections A    
 inner join componentinformation C on A.comp=C.interfaceid
 INNER JOIN componentoperationpricing CO ON CO.componentid=C.componentid
 inner join #FinalData T1 on T1.CompInterface=A.comp  
 inner join #Test1 Te on te.Componentid=a.comp 
 inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid    
 Cross join PlannedDownTimes P    
 where  A.flag = 'Rejection' and P.machine=CO.Machineid     
 and Isnull(A.Rejshift,'a')='a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000' and    
 A.CreatedTS>=FromTime and A.CreatedTS<ToTime And    
 A.CreatedTS>=P.Starttime and A.CreatedTS<P.endtime and te.RejBit=1   
 group by A.comp,T1.Pdate
 )T1 inner join #FinalData B on B.CompInterface=T1.comp and B.Pdate=T1.Pdate     
END   



Update #FinalData set TotalNotOk = isnull(TotalNotOk,0) + isnull(T1.RejQty,0)    
From    
( Select A.comp,SUM(A.Rejection_Qty) as RejQty,T1.Pdate from AutodataRejections A    
inner join componentinformation C on A.comp=C.interfaceid    
inner join #FinalData T1 on T1.CompInterface=A.comp AND convert(nvarchar(10),(A.RejDate),120) in (convert(nvarchar(10),T1.PDate,120))  
inner join #Test1 Te on te.Componentid=a.comp 
inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid    
inner join #DailyProductionFromAutodataT0 S on (convert(nvarchar(10),(A.RejDate),120)=convert(nvarchar(10),S.DDate,120)) and A.RejShift=S.shiftid 
where A.flag = 'Rejection' and A.Rejshift in (S.shiftid) and convert(nvarchar(10),(A.RejDate),120) in (convert(nvarchar(10),S.DDate,120)) and  
Isnull(A.Rejshift,'a')<>'a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')<>'1900-01-01 00:00:00.000' and te.RejBit=1   
group by A.comp,T1.Pdate
)T1 inner join #FinalData B on  B.CompInterface=T1.comp and B.Pdate=T1.Pdate   
    
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'    
BEGIN    
 Update #FinalData set TotalNotOk = isnull(TotalNotOk,0) - isnull(T1.RejQty,0) from    
 (Select A.comp,SUM(A.Rejection_Qty) as RejQty,T1.Pdate from AutodataRejections A    
 inner join componentinformation C on A.comp=C.interfaceid   
 INNER JOIN componentoperationpricing CO ON CO.componentid=C.componentid
 inner join #FinalData T1 on T1.CompInterface=A.comp  AND convert(nvarchar(10),(A.RejDate),120) in (convert(nvarchar(10),T1.PDate,120))
 inner join #Test1 Te on te.Componentid=a.comp 
 inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid    
 inner join #DailyProductionFromAutodataT0 S on (convert(nvarchar(10),(A.RejDate),120)=convert(nvarchar(10),S.DDate,120)) and A.RejShift=S.shiftid      
 Cross join PlannedDownTimes P    
 where  A.flag = 'Rejection' and P.machine=CO.Machineid and    
 A.Rejshift in (S.shiftid) and convert(nvarchar(10),(A.RejDate),120) in (convert(nvarchar(10),s.DDate,120)) and 
 Isnull(A.Rejshift,'a')<>'a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')<>'1900-01-01 00:00:00.000'    
 and P.starttime>=S.ShiftStart and P.Endtime<=S.ShiftEnd and te.RejBit=1
 group by A.comp,T1.Pdate)T1 inner join #FinalData B on  B.CompInterface=T1.comp and B.Pdate=T1.Pdate   
END    

-----------------------------------------------------------------------Rejection Cal ends---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------StdCycleTime Cal starts----------------------------------------------------------------------------------------------
update #FinalData set StdCycleTime=(t1.stdcycleTime)
from
(
select distinct c.componentid,cycletime as stdcycleTime from componentoperationpricing c
inner join componentinformation c1 on c1.componentid=c.componentid
inner join machineinformation m on m.machineid=c.machineid
where (c.componentid=@PumpModel or isnull(@pumpmodel,'')='') and m.IsTestBenchMachine=1 and c1.IsPumpEnabled=1
)t1 inner join #FinalData on #FinalData.ComponentID=t1.componentid

-----------------------------------------------------------------------StdCycleTime Cal ends----------------------------------------------------------------------------------------------


  --------------------------------------------------------------------Material (downcatagory) down cal starts----------------------------------------------------------------------------
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='N'
BEGIN
	UPDATE #FinalData SET MaterialDownTime = isnull(MaterialDownTime,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory ='Material'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime
end


If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='Y'
BEGIN
	UPDATE #FinalData SET MaterialDownTime = isnull(MaterialDownTime,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory = 'Material'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime

	UPDATE #FinalData set MaterialDownTime =isnull(MaterialDownTime,0) - isNull(TT.PPDT ,0)
	FROM(
		SELECT autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay,SUM
		   (CASE
			WHEN autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT  AND autodata.ndtime > T.StartTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT  AND autodata.ndtime > T.EndTime_PDT  ) THEN DateDiff(second,autodata.sttime,T.EndTime_PDT )
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,T.EndTime_PDT )
			END ) as PPDT
		from  #T_autodata autodata CROSS jOIN #PlannedDownTimes T
		inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND m.IsTestBenchMachine=1 and
			(
			(autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT)
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT AND autodata.ndtime > T.StartTime_PDT )
			OR ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT AND autodata.ndtime > T.EndTime_PDT )
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT)
			)
			AND downcodeinformation.Catagory = 'Material'
		group by autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay
	) as TT INNER JOIN #FinalData ON TT.comp = #FinalData.CompInterface And
	TT.StartTime_LogicalDay = #FinalData.FromTime and TT.EndTime_LogicalDay = #FinalData.ToTime
end
 --------------------------------------------------------------------Material (downcatagory) down Time cal ends------------------------------------------------------------------------------------------------------


   --------------------------------------------------------------------Absent (downcatagory) down cal starts----------------------------------------------------------------------------
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='N'
BEGIN
	UPDATE #FinalData SET AbsentDownTime = isnull(AbsentDownTime,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory ='Absent'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime
end


If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='Y'
BEGIN
	UPDATE #FinalData SET AbsentDownTime = isnull(AbsentDownTime,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory ='Absent'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime

	UPDATE #FinalData set AbsentDownTime =isnull(AbsentDownTime,0) - isNull(TT.PPDT ,0)
	FROM(
		SELECT autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay,SUM
		   (CASE
			WHEN autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT  AND autodata.ndtime > T.StartTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT  AND autodata.ndtime > T.EndTime_PDT  ) THEN DateDiff(second,autodata.sttime,T.EndTime_PDT )
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,T.EndTime_PDT )
			END ) as PPDT
		from  #T_autodata autodata CROSS jOIN #PlannedDownTimes T
		inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND m.IsTestBenchMachine=1 and
			(
			(autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT)
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT AND autodata.ndtime > T.StartTime_PDT )
			OR ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT AND autodata.ndtime > T.EndTime_PDT )
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT)
			)
			AND downcodeinformation.Catagory ='Absent'
		group by autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay
	) as TT INNER JOIN #FinalData ON TT.comp = #FinalData.CompInterface And
	TT.StartTime_LogicalDay = #FinalData.FromTime and TT.EndTime_LogicalDay = #FinalData.ToTime
end
 --------------------------------------------------------------------Absent (downcatagory) down Time cal ends------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------Maintenance (downcatagory) down cal starts----------------------------------------------------------------------------
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='N'
BEGIN
	UPDATE #FinalData SET MaintainanceDown = isnull(MaintainanceDown,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory ='Maintenance'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime
end


If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='Y'
BEGIN
	UPDATE #FinalData SET MaintainanceDown = isnull(MaintainanceDown,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory ='Maintenance'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime

	UPDATE #FinalData set MaintainanceDown =isnull(MaintainanceDown,0) - isNull(TT.PPDT ,0)
	FROM(
		SELECT autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay,SUM
		   (CASE
			WHEN autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT  AND autodata.ndtime > T.StartTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT  AND autodata.ndtime > T.EndTime_PDT  ) THEN DateDiff(second,autodata.sttime,T.EndTime_PDT )
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,T.EndTime_PDT )
			END ) as PPDT
		from  #T_autodata autodata CROSS jOIN #PlannedDownTimes T
		inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND m.IsTestBenchMachine=1 and
			(
			(autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT)
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT AND autodata.ndtime > T.StartTime_PDT )
			OR ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT AND autodata.ndtime > T.EndTime_PDT )
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT)
			)
			AND downcodeinformation.Catagory ='Maintenance'
		group by autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay
	) as TT INNER JOIN #FinalData ON TT.comp = #FinalData.CompInterface And
	TT.StartTime_LogicalDay = #FinalData.FromTime and TT.EndTime_LogicalDay = #FinalData.ToTime
end
 --------------------------------------------------------------------Maintenance (downcatagory) down Time cal ends------------------------------------------------------------------------------------------------------

 -----------------------------------------------------------------------Power Failure (downcatagory) down cal starts----------------------------------------------------------------------------
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='N'
BEGIN
	UPDATE #FinalData SET PowerFailureDown = isnull(PowerFailureDown,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory='Power Failure'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime
end


If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='Y'
BEGIN
	UPDATE #FinalData SET PowerFailureDown = isnull(PowerFailureDown,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory='Power Failure'
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime

	UPDATE #FinalData set PowerFailureDown =isnull(PowerFailureDown,0) - isNull(TT.PPDT ,0)
	FROM(
		SELECT autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay,SUM
		   (CASE
			WHEN autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT  AND autodata.ndtime > T.StartTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT  AND autodata.ndtime > T.EndTime_PDT  ) THEN DateDiff(second,autodata.sttime,T.EndTime_PDT )
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,T.EndTime_PDT )
			END ) as PPDT
		from  #T_autodata autodata CROSS jOIN #PlannedDownTimes T
		inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND T.MachineInterface=autodata.mc and m.IsTestBenchMachine=1 and
			(
			(autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT)
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT AND autodata.ndtime > T.StartTime_PDT )
			OR ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT AND autodata.ndtime > T.EndTime_PDT )
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT)
			)
			AND downcodeinformation.Catagory ='Power Failure'
		group by autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay
	) as TT INNER JOIN #FinalData ON TT.comp = #FinalData.CompInterface And
	TT.StartTime_LogicalDay = #FinalData.FromTime and TT.EndTime_LogicalDay = #FinalData.ToTime
end
 --------------------------------------------------------------------power failure (downcatagory) down Time cal ends------------------------------------------------------------------------------------------------------

  -----------------------------------------------------------------------Others (downcatagory) down cal starts----------------------------------------------------------------------------
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='N'
BEGIN
	UPDATE #FinalData SET OtherDown = isnull(OtherDown,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory not in ('Power Failure','Maintenance','Absent','Material')
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime
end


If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='Y'
BEGIN
	UPDATE #FinalData SET OtherDown = isnull(OtherDown,0) + isNull(t2.matdown,0)	from (
		select comp,D.FromTime,D.ToTime,sum(
			CASE
				WHEN  autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime  THEN  loadunload
				WHEN (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)  THEN DateDiff(second, D.FromTime, ndtime)
				WHEN (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)  THEN DateDiff(second, stTime, D.ToTime)
				WHEN autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime   THEN DateDiff(second, D.FromTime, D.ToTime)
			END
			)AS matdown
		from  #T_autodata autodata inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		where autodata.datatype=2 AND m.IsTestBenchMachine=1 and
		(
		(autodata.msttime>=D.FromTime  and  autodata.ndtime<=D.ToTime)
		OR (autodata.sttime<D.FromTime and  autodata.ndtime>D.FromTime and autodata.ndtime<=D.ToTime)
		OR (autodata.msttime>=D.FromTime  and autodata.sttime<D.ToTime  and autodata.ndtime>D.ToTime)
		OR (autodata.msttime<D.FromTime and autodata.ndtime>D.ToTime )
		) AND downcodeinformation.Catagory not in ('Power Failure','Maintenance','Absent','Material')
		group by autodata.comp,D.FromTime,D.ToTime
	) as t2 inner join #FinalData on t2.comp = #FinalData.CompInterface
	And t2.FromTime = #FinalData.FromTime
	And t2.ToTime = #FinalData.ToTime

	UPDATE #FinalData set OtherDown =isnull(OtherDown,0) - isNull(TT.PPDT ,0)
	FROM(
		SELECT autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay,SUM
		   (CASE
			WHEN autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT  AND autodata.ndtime > T.StartTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT  AND autodata.ndtime > T.EndTime_PDT  ) THEN DateDiff(second,autodata.sttime,T.EndTime_PDT )
			WHEN ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT ) THEN DateDiff(second,T.StartTime_PDT,T.EndTime_PDT )
			END ) as PPDT
		from  #T_autodata autodata CROSS jOIN #PlannedDownTimes T
		inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		inner join machineinformation m on m.InterfaceID=autodata.mc
		inner join #FinalData D on autodata.comp = D.CompInterface
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND m.IsTestBenchMachine=1 and
			(
			(autodata.sttime >= T.StartTime_PDT  AND autodata.ndtime <=T.EndTime_PDT)
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime <= T.EndTime_PDT AND autodata.ndtime > T.StartTime_PDT )
			OR ( autodata.sttime >= T.StartTime_PDT   AND autodata.sttime <T.EndTime_PDT AND autodata.ndtime > T.EndTime_PDT )
			OR ( autodata.sttime < T.StartTime_PDT  AND autodata.ndtime > T.EndTime_PDT)
			)
			AND downcodeinformation.Catagory not in ('Power Failure','Maintenance','Absent','Material')
		group by autodata.comp,StartTime_LogicalDay,EndTime_LogicalDay
	) as TT INNER JOIN #FinalData ON TT.comp = #FinalData.CompInterface And
	TT.StartTime_LogicalDay = #FinalData.FromTime and TT.EndTime_LogicalDay = #FinalData.ToTime
end
 -------------------------------------------------------------------Others (downcatagory) down Time cal ends------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------Material (MaterialDownTime/stdcycletime) loss cal starts-------------------------------------------------------------------------------
  
  update #FinalData set MaterialLoss=isnull((MaterialDownTime/StdCycleTime),0)


  -------------------------------------------------------------------Material (MaterialDownTime/stdcycletime) loss cal ends---------------------------------------------------------------------------------

 ---------------------------------------------------------------------Absent (AbsentDownTime/stdcycletime) loss cal starts--------------------------------------------------------------------------------
 
 update #FinalData set AbsentLoss=isnull((AbsentDownTime/StdCycleTime),0)

 --------------------------------------------------------------------Absent (AbsentDownTime/stdcycletime) loss cal ends------------------------------------------------------------------------------------

  ---------------------------------------------------------------------Maintenance (MaintainanceDown/stdcycletime) loss cal starts-------------------------------------------------------------------------
 
  update #FinalData set MaintainanceLoss=isnull((MaintainanceDown/StdCycleTime),0)

 -----------------------------------------------------------------------Maintenance (MaintainanceDown/stdcycletime) loss cal ends---------------------------------------------------------------------------

   ---------------------------------------------------------------------Power Failure (PowerFailureDown/stdcycletime) loss cal starts-------------------------------------------------------------------------
  
  update #FinalData set PowerFailureLoss=isnull((PowerFailureDown/StdCycleTime),0)

 -----------------------------------------------------------------------Power Failure (PowerFailureDown/stdcycletime) loss cal ends---------------------------------------------------------------------------
  
  ---------------------------------------------------------------------Others (OtherDown/stdcycletime) loss cal starts-------------------------------------------------------------------------
 
  update #FinalData set OtherLoss=isnull((OtherDown/StdCycleTime),0)

 -----------------------------------------------------------------------Power Failure (OtherDown/stdcycletime) loss cal ends---------------------------------------------------------------------------

-----------------------------------------------------------------------Accepted Cal starts-----------------------------------------------------------------------------------------------------------

update #FinalData set TotalOk=isnull(isnull(totalparts,0)-isnull(TotalNotOk,0),0)

-----------------------------------------------------------------------Accepted Cal ends------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------DayWise Output (testok,testnotok) starts------------------------------------------------------------------------------------------

select ComponentID,CompInterface,Category,pdate,FromTime,ToTime,ISNULL(Assemblyparts,0) AS Assemblyparts, isnull(PlannedQty,0) as PlannedQty,isnull(TotalParts,0) as totalparts,isnull(totalok,0) as totalok,isnull(totalnotok,0) as totalnotok,isnull(StdCycleTime,0) as StdCycleTime,
isnull(otherdown,0) as otherdowninsec,dbo.f_FormatTime(isnull(OtherDown,0),'hh') as OtherDown, round(isnull(OtherLoss,0),1) as OtherLoss,
--dbo.f_FormatTime(isnull(OtherDown,0),'hh:mm:ss') as Otherdownhhmmss,dbo.f_FormatTime(isnull(Otherloss,0),'hh:mm:ss') as Otherlosshhmmss,
isnull(MaterialDownTime,0) as materialdowninsec,dbo.f_FormatTime(isnull(MaterialDownTime,0),'hh') as MaterialDownTime, round(isnull(MaterialLoss,0),1) as MaterialLoss,
isnull(AbsentDownTime,0) as absentdowninsec,dbo.f_FormatTime(isnull(AbsentDownTime,0),'hh') as AbsentDownTime,round(isnull(AbsentLoss,0),1) as AbsentLoss,
isnull(MaintainanceDown,0) as maintdowninsec,dbo.f_FormatTime(isnull(MaintainanceDown,0),'hh') as MaintainanceDown,round(isnull(MaintainanceLoss,0),1) as MaintainanceLoss,
isnull(PowerFailureDown,0) as powerdowninsec,dbo.f_FormatTime(isnull(PowerFailureDown,0),'hh') as PowerFailureDown,round(isnull(PowerFailureLoss,0),1) as PowerFailureLoss from #FinalData
where PlannedQty<>0
order by Pdate

------------------------------------------------------------------DayWise Output (testok,testnotok) ends------------------------------------------------------------------------------------------

--------------------------------------------------------------------Summary output (group by category) starts--------------------------------------------------------------------------------------------

select t1.category as category,isnull(sum(t1.Assemblyparts),0) as TotalAssembly,isnull(sum(t1.PlannedQty),0) as MonthTarget,isnull(sum(t1.totalparts),0) as totalparts, isnull(sum(t1.totalok),0) as totalok,isnull(sum(t1.totalnotok),0) as totalnotok,
dbo.f_FormatTime(isnull(sum(t1.OtherDown),0),'hh') as OtherDown,round(isnull(sum(t1.OtherLoss),0),1) as OtherLoss,
dbo.f_FormatTime(isnull(sum(t1.MaterialDownTime),0),'hh') as MaterialDownTime,round(isnull(sum(t1.MaterialLoss),0),1) as MaterialLoss,
dbo.f_FormatTime(isnull(sum(t1.AbsentDownTime),0),'hh') as AbsentDownTime,round(isnull(sum(t1.AbsentLoss),0),1) as AbsentLoss,
dbo.f_FormatTime(isnull(sum(t1.MaintainanceDown),0),'hh') as MaintainanceDown,round(isnull(sum(t1.MaintainanceLoss),0),1) as MaintainanceLoss,
dbo.f_FormatTime(isnull(sum(t1.PowerFailureDown),0),'hh') as PowerFailureDown,round(isnull(sum(t1.PowerFailureLoss),0),1) as PowerFailureLoss
from
( 
select Category,ISNULL(Assemblyparts,0) AS Assemblyparts, isnull(PlannedQty,0) as PlannedQty,isnull(TotalParts,0) as TotalParts, isnull(totalok,0) as totalok,isnull(totalnotok,0) as totalnotok,
isnull(OtherDown,0) as OtherDown, isnull(OtherLoss,0) as OtherLoss,isnull(MaterialDownTime,0) as MaterialDownTime,isnull(MaterialLoss,0) as MaterialLoss,
isnull(AbsentDownTime,0) as AbsentDownTime,isnull(AbsentLoss,0) as AbsentLoss,isnull(MaintainanceDown,0) as MaintainanceDown,isnull(MaintainanceLoss,0) as MaintainanceLoss,
isnull(PowerFailureDown,0) as PowerFailureDown,isnull(PowerFailureLoss,0) as PowerFailureLoss from #FinalData
)t1
group by category

--------------------------------------------------------------------Summary output (group by category) ends--------------------------------------------------------------------------------------------


end
