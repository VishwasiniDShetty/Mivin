/****** Object:  Procedure [dbo].[S_Get_PumpTestSummaryReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_Get_PumpTestSummaryReport_Mivin] '2021-04-29','2021-04-30','R002G12176'
[dbo].[S_Get_PumpTestSummaryReport_Mivin] '2022-02-01','2022-02-28',''

*/
CREATE procedure [dbo].[S_Get_PumpTestSummaryReport_Mivin]
@StartDate datetime='',
@EndDate datetime='',
@PumpModel nvarchar(50)=''
as
begin
Declare @StartTime datetime
Declare @EndTime datetime
declare @year int
declare @month int


select @year= DATEPART(year,@StartDate)
select @month=DATEPART(month,@startdate)


CREATE TABLE #DailyProductionFromAutodataT0 
(
	DDate DATETIME,
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
Pdate datetime NOT NULL,
FromTime datetime,
ToTime datetime,
TotalParts float,
tOTAL FLOAT,
TotalOk float,
TotalNotOk float,
Assemblyparts float
)

create table #summary
(
ComponentID NVARCHAR(50),
CompInterface nvarchar(50),
TotalParts float,
TotalOk float,
TotalNotOk float,
ScheduledQuantity float,
DispatchQuantity float,
PendingQuantity float,
TotalAssemblyparts float
)


create table #Test1
(
Componentid nvarchar(50),
SlNo nvarchar(50),
CycleStart datetime,
TotalParts FLOAT,
MeasuredDatetime datetime,
RejDate datetime,
ReworkNo nvarchar(50),
RejBit bit
)



Declare @T_ST AS Datetime 
Declare @T_ED AS Datetime 

Select @T_ST=dbo.f_GetLogicalDay(@StartDate,'start')
Select @T_ED=dbo.f_GetLogicalDay(@EndDate,'End')

select @StartTime=@StartDate
select @EndTime=@EndDate


Declare @lstart AS nvarchar(50) --ER0465
Declare @lend AS nvarchar(50) --ER0465

while @StartTime<=@EndTime
BEGIN
	SET @lstart = dbo.f_GetLogicalDay(@StartTime,'start') --ER0465
	SET @lend = dbo.f_GetLogicalDay(@StartTime,'End') --ER0465

	INSERT INTO #DailyProductionFromAutodataT1 (Pdate,FromTime,ToTime) 
	SELECT convert(nvarchar(20),@StartTime), @lstart,@lend 

	SELECT @StartTime=DATEADD(DAY,1,@StartTime)


end



insert into #FinalData(Pdate,FromTime,ToTime,ComponentID,CompInterface)
SELECT distinct t1.Pdate,t1.FromTime,t1.ToTime,c1.PumpModel,c2.InterfaceID FROM #DailyProductionFromAutodataT1 T1 CROSS JOIN ScheduleDetails C1
inner join componentinformation c2 on c1.PumpModel=c2.componentid
WHERE (C1.PumpModel=@PumpModel OR ISNULL(@PUMPMODEL,'')='') AND C2.ISPUMPENABLED=1 and (date>=@StartDate and date<=@EndDate)

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

-------------------------------------------------------Insert into #test1 data from (PumpTestData_Mivin table) starts--------------------------------------------------------------------------------------------------

insert into #Test1(Componentid,SlNo,MeasuredDatetime)
select distinct PumpModel,SlNo,max(MeasuredDatetime) as MeasuredDatetime from PumpTestData_Mivin where (PumpModel=@PumpModel or isnull(@pumpmodel,'')='') and (MeasuredDatetime>=@T_ST and MeasuredDatetime<=@T_ED)
AND ISNULL(IsMasterPump,0)<>1
GROUP by PumpModel,SlNo

update #Test1 set ReworkNo=(T1.Rewrk)
from
(
select PumpModel,SlNo,isnull(max(reworkno),0) as Rewrk  from PumpTestData_Mivin
where (PumpModel=@PumpModel or isnull(@pumpmodel,'')='') and (MeasuredDatetime>=@T_ST and MeasuredDatetime<=@T_ED)
group by PumpModel,SlNo
)t1 inner join #Test1 on t1.PumpModel=#Test1.Componentid and t1.SlNo=#Test1.SlNo 

-------------------------------------------------------Insert into #test1 data from (PumpTestData_Mivin table) ends--------------------------------------------------------------------------------------------------

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



-----------------------------------------------------------------------Cal for TotalParts ends------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------Accepted Cal starts---------------------------------------------------------------------------------------------------

update #FinalData set TotalOk=isnull(isnull(totalparts,0)-isnull(TotalNotOk,0),0)

------------------------------------------------------------------DayWise Output (testok,testnotok) starts------------------------------------------------------------------------------------------

select ComponentID,CompInterface,Pdate,FromTime,ToTime,ISNULL(TotalParts,0) AS TotalParts,ISNULL(TotalOk,0) AS TotalOk,ISNULL(TotalNotOk,0) AS TotalNotOk,isnull(Assemblyparts,0) as Assemblyparts from #FinalData
order by Pdate
------------------------------------------------------------------DayWise Output (testok,testnotok) ends------------------------------------------------------------------------------------------


insert into #summary(ComponentID,CompInterface,TotalParts,TotalOk,TotalNotOk)
select  componentid,CompInterface,sum(TotalParts) as TotalParts,sum(TotalOk) as TotalTestOk,sum(TotalNotOk) as TotalTestNotOk from #FinalData
group by componentid,CompInterface


update #summary set ScheduledQuantity=(t1.scheduleqty)
from
(
select distinct pumpmodel,sum(distinct MonthRequirement) as scheduleqty from MonthlyAndWeeklyScheduleDetails
where datepart(year,[date])=@year and DATEPART(month,[date])=@month
group by pumpmodel
)t1 inner join #summary on t1.PumpModel=#summary.ComponentID

update #summary set DispatchQuantity=(t1.scannedQty)
from
(
select distinct pumpmodel,sum(scannedQty) as scannedQty from ScannedDetails where datepart(year,[date])=@year and DATEPART(month,[date])=@month
group by PumpModel
)t1 inner join #summary on t1.PumpModel=#summary.ComponentID

update #summary set PendingQuantity=isnull(ScheduledQuantity,0)-isnull(DispatchQuantity,0)


SELECT ComponentID,CompInterface,ISNULL(TotalParts,0) AS TotalParts,ISNULL(TotalOk,0) AS TotalOk,ISNULL(TotalNotOk,0) AS TotalNotOk,isnull(ScheduledQuantity,0) as ScheduledQuantity,
isnull(DispatchQuantity,0) as DispatchQuantity,isnull(PendingQuantity,0) as PendingQuantity,isnull(TotalAssemblyparts,0) as TotalAssemblyparts   FROM #summary
where ScheduledQuantity<>0


end
