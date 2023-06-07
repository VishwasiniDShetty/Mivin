/****** Object:  Procedure [dbo].[S_Get_PlantWiseProductivityDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_Get_PlantWiseProductivityDetails_Mivin] 'Grinding','2021-08-01 00:00:00.000'
[dbo].[S_Get_PlantWiseProductivityDetails_Mivin] 'Testing','2021-08-01 00:00:00.000'

*/
CREATE PROCEDURE [dbo].[S_Get_PlantWiseProductivityDetails_Mivin]
@GroupID NVARCHAR(50)='',
@StartDate DATETIME=''
AS
BEGIN


CREATE TABLE #Test
(
PlantID NVARCHAR(50),
GroupID NVARCHAR(50),
Machineid NVARCHAR(50),
InterfaceID NVARCHAR(50),
PumpModel NVARCHAR(50),
MeasuredDateTime DATETIME,
SlNo NVARCHAR(50),
ReCheckNo INT,
ReworkNo INT,
Total FLOAT
)

CREATE TABLE #PlannedDownTimes
(
	MachineID NVARCHAR(50) NOT NULL, --ER0374
	MachineInterface NVARCHAR(50) NOT NULL, --ER0374
	StartTime DATETIME NOT NULL, --ER0374
	EndTime DATETIME NOT NULL --ER0374
)

ALTER TABLE #PlannedDownTimes
	ADD PRIMARY KEY CLUSTERED
		(   [MachineInterface],
			[StartTime],
			[EndTime]
						
		) ON [PRIMARY]

		CREATE TABLE #T_autodata(
	[mc] [NVARCHAR](50)NOT NULL,
	[comp] [NVARCHAR](50) NULL,
	[opn] [NVARCHAR](50) NULL,
	[opr] [NVARCHAR](50) NULL,
	[dcode] [NVARCHAR](50) NULL,
	[sttime] [DATETIME] NOT NULL,
	[ndtime] [DATETIME] NOT NULL,
	[datatype] [TINYINT] NULL ,
	[cycletime] [INT] NULL,
	[loadunload] [INT] NULL ,
	[msttime] [datetime] not NULL,
	[PartsCount] decimal(18,5) NULL ,
	id  bigint not null
)

ALTER TABLE #T_autodata

ADD PRIMARY KEY CLUSTERED
(
	mc,sttime,ndtime,msttime ASC
)ON [PRIMARY]

CREATE TABLE #MonthWiseData
(
	ID BIGINT IDENTITY(1,1),
	MonthName NVARCHAR(50),
	MonthStart DATETIME,
	MonthEnd DATETIME,
	GroupID NVARCHAR(50),
	MachineId NVARCHAR(50),
	InterfaceID NVARCHAR(50),
	TotalParts FLOAT DEFAULT 0,
	ManPower FLOAT DEFAULT 1,
	Hours FLOAT DEFAULT 0,
	pdt FLOAT DEFAULT 0,
	Actual FLOAT DEFAULT 0,
	Target FLOAT DEFAULT 0
)

CREATE TABLE #DayWiseData
(
	ID BIGINT IDENTITY(1,1),
	Date DATETIME,
	FromTime DATETIME,
	ToTime DATETIME,
	PlantID NVARCHAR(50),
	GroupID NVARCHAR(50),
	MachineId NVARCHAR(50),
	InterfaceID NVARCHAR(50),
	TotalParts FLOAT DEFAULT 0,
	ManPower FLOAT DEFAULT 1,
	Hours FLOAT DEFAULT 0,
	pdt FLOAT DEFAULT 0,
	Actual FLOAT DEFAULT 0,
	Target FLOAT DEFAULT 0
)

DECLARE @MonthStart DATETIME
DECLARE @MonthEnd DATETIME

DECLARE @monthst DATETIME
DECLARE @monthnd DATETIME


DECLARE @YearStart DATETIME
DECLARE @YStart DATETIME
DECLARE @Yend DATETIME
DECLARE @YearEnd DATETIME

SELECT @YearStart = dbo.f_GetLogicalDay((DATEADD(yy, DATEDIFF(yy, 0, @StartDate), 0)),'start')
SELECT @YStart =  DATEADD(yy, DATEDIFF(yy, 0, @StartDate), 0)
SELECT @Yend=  DATEADD(yy, DATEDIFF(yy, 0, @StartDate) + 1, -1)
SELECT @YearEnd = dbo.f_GetLogicalDay(( DATEADD(yy, DATEDIFF(yy, 0, @StartDate) + 1, -1)),'End')


------------------------------------------------------------------iNSERT INTO autodata---------------------------------------------------------------------------------------------------
DECLARE @T_ST AS DATETIME 
DECLARE @T_ED AS DATETIME 
DECLARE @strsql NVARCHAR(MAX)

SELECT @T_ST=dbo.f_GetLogicalDay((DATEADD(MONTH, DATEDIFF(MONTH, 0, @StartDate), 0)),'start')
SELECT @T_ED=dbo.f_GetLogicalDay((EOMONTH(@StartDate)),'End')

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

/* Planned Down times for the given time period */
SET @strSql = ''
SET @strSql = 'Insert into #PlannedDownTimes
	SELECT Machine,InterfaceID,
		CASE When StartTime<''' + convert(nvarchar(20),@T_ST,120)+''' Then ''' + convert(nvarchar(20),@T_ST,120)+''' Else StartTime End As StartTime,
		CASE When EndTime>''' + convert(nvarchar(20),@T_ED,120)+''' Then ''' + convert(nvarchar(20),@T_ED,120)+''' Else EndTime End As EndTime
	FROM PlannedDownTimes inner join MachineInformation on PlannedDownTimes.machine = MachineInformation.MachineID
	LEFT OUTER JOIN PlantMachine ON machineinformation.machineid = PlantMachine.MachineID 
    LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID 
	and PlantMachineGroups.machineid = PlantMachine.MachineID
	WHERE PDTstatus =1 and(
	(StartTime >= ''' + convert(nvarchar(20),@T_ST,120)+''' AND EndTime <=''' + convert(nvarchar(20),@T_ED,120)+''')
	OR ( StartTime < ''' + convert(nvarchar(20),@T_ST,120)+'''  AND EndTime <= ''' + convert(nvarchar(20),@T_ED,120)+''' AND EndTime > ''' + convert(nvarchar(20),@T_ST,120)+''' )
	OR ( StartTime >= ''' + convert(nvarchar(20),@T_ST,120)+'''   AND StartTime <''' + convert(nvarchar(20),@T_ED,120)+''' AND EndTime > ''' + convert(nvarchar(20),@T_ED,120)+''' )
	OR ( StartTime < ''' + convert(nvarchar(20),@T_ST,120)+'''  AND EndTime > ''' + convert(nvarchar(20),@T_ED,120)+''')) '
SET @strSql =  @strSql  + ' ORDER BY Machine,StartTime'
EXEC(@strSql)

-------------------------------------------------------Insert into #test1 data from (PumpTestData_Mivin table) starts--------------------------------------------------------------------------------------------------


INSERT into #Test(GroupID,machineid,InterfaceID,PumpModel,SlNo,MeasuredDateTime)
select distinct P1.GroupID, M.machineid,m.InterfaceID,p.PumpModel,P.slno, max(MeasuredDatetime) as MeasuredDatetime from PumpTestData_Mivin P
INNER JOIN machineinformation M ON M.InterfaceID=P.MachineID --and IsTestBenchMachine=1
INNER JOIN PlantMachineGroups P1 ON P1.MachineID=M.machineid
where  (MeasuredDatetime>=@T_ST and MeasuredDatetime<=@T_ED) AND P1.GroupID=@GroupID AND ISNULL(p.IsMasterPump,0)<>1
group by P1.GroupID,M.machineid,m.InterfaceID,PumpModel,P.SlNo

update #Test set ReworkNo=isnull(t1.rewrk,0),ReCheckNo=isnull(t1.rechk,0)
from
(select distinct machineid,pumpmodel,slno,MeasuredDatetime,reworkno as rewrk,ReCheckNo as rechk  from PumpTestData_Mivin
where  (MeasuredDatetime>=@T_ST and MeasuredDatetime<=@T_ED)
) t1 inner join #Test on t1.MachineID=#Test.Machineid and t1.PumpModel=#Test.PumpModel and t1.SlNo=#Test.SlNo and t1.MeasuredDatetime=#Test.MeasuredDatetime

----------------------------------------------------------------Insert into #test1 data from (PumpTestData_Mivin table) ends--------------------------------------------------------------------------------------------------

------------------------------------------------------------------MonthWise Data for each machines (istestbenchenable=1) starts--------------------------------------------------------------------------------------------

SELECT @MonthSt = DATEADD(month, DATEDIFF(month, 0, @StartDate), 0) 
SELECT @Monthnd = EOMONTH(@StartDate)

select @MonthStart=dbo.f_GetLogicalDay(@MonthSt,'start') 
select @MonthEnd=dbo.f_GetLogicalDay(@Monthnd,'end') 

insert into #MonthWiseData(GroupID,MachineId,InterfaceID,MonthName,MonthStart,MonthEnd)
select distinct p1.GroupID,m.Machineid,m.InterfaceID,CAST(Datename(month,@StartDate) as nvarchar(3)),@MonthStart,@MonthEnd
from PlantInformation p
inner join PlantMachineGroups p1 on p1.GroupID=p1.GroupID
inner join machineinformation m on m.machineid=p1.MachineID --and m.IsTestBenchMachine=1
where (p1.GroupID=@GroupID)
order by p1.GroupID,Machineid

IF @GroupID='Testing'
BEGIN
UPDATE #MonthWiseData set TotalParts=ISNULL(t.total,0)
from
(
select p1.GroupID,m.MachineID,MonthName,count(t1.SlNo) as total from PlantInformation p
inner join PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join machineinformation m on m.machineid=p1.MachineID --and m.IsTestBenchMachine=1
inner join #MonthWiseData y on y.GroupID=p1.GroupID AND Y.MachineId=p1.machineid
inner join #Test t1 on t1.Machineid=m.InterfaceID AND T1.GroupID=Y.GroupID
where (t1.MeasuredDateTime>=y.MonthStart and  t1.MeasuredDateTime<=y.MonthEnd)
and p1.GroupID=@GroupID
group by p1.GroupID,m.MachineID,MonthName
)t inner join #MonthWiseData on t.GroupID=#MonthWiseData.GroupID AND T.MachineID=#MonthWiseData.MachineId and t.MonthName=#MonthWiseData.MonthName
END

IF @GroupID<>'Testing'
BEGIN
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='N'
begin
UPDATE #MonthWiseData SET TotalParts = ISNULL(TotalParts,0) + ISNULL(t2.comp,0)
From
(
	  Select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) As Comp --NR0097
		   From (select mc,SUM(autodata.partscount)AS OrginalCount,comp,opn 
			from #T_autodata autodata 
			INNER JOIN #MonthWiseData M1 ON M1.InterfaceID=autodata.mc
		   where (autodata.ndtime>MonthStart) and (autodata.ndtime<=MonthEnd) and (autodata.datatype=1)
		   Group By mc,comp,opn) as T1
	Inner join componentinformation C on T1.Comp = C.interfaceid
	Inner join ComponentOperationPricing O ON  T1.Opn = O.interfaceid and C.Componentid=O.componentid
	inner join machineinformation on machineinformation.machineid =O.machineid
	and T1.mc=machineinformation.interfaceid
	GROUP BY mc
) As T2 Inner join #MonthWiseData on T2.mc = #MonthWiseData.InterfaceID
END

If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN
UPDATE #MonthWiseData SET TotalParts = ISNULL(TotalParts,0) + ISNULL(t2.comp,0)
From
(
	  Select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) As Comp --NR0097
		   From (select mc,SUM(autodata.partscount)AS OrginalCount,comp,opn 
			from #T_autodata autodata 
			INNER JOIN #MonthWiseData M1 ON M1.InterfaceID=autodata.mc
		   where (autodata.ndtime>MonthStart) and (autodata.ndtime<=MonthEnd) and (autodata.datatype=1)
		   Group By mc,comp,opn) as T1
	Inner join componentinformation C on T1.Comp = C.interfaceid
	Inner join ComponentOperationPricing O ON  T1.Opn = O.interfaceid and C.Componentid=O.componentid
	inner join machineinformation on machineinformation.machineid =O.machineid
	and T1.mc=machineinformation.interfaceid
	GROUP BY mc
) As T2 Inner join #MonthWiseData on T2.mc = #MonthWiseData.InterfaceID

	UPDATE #MonthWiseData SET TotalParts = ISNULL(TotalParts,0) - ISNULL(T2.comp,0) from(
		select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) as comp From ( --NR0097
			select mc,Sum(ISNULL(PartsCount,1))AS OrginalCount,comp,opn 
			from #T_autodata autodata 
			INNER JOIN #MonthWiseData M1 ON M1.InterfaceID=autodata.mc
			CROSS JOIN #PlannedDownTimes T
			WHERE autodata.DataType=1 And T.MachineInterface = autodata.mc
			AND (autodata.ndtime > T.StartTime  AND autodata.ndtime <=T.EndTime)
			AND (autodata.ndtime > MonthStart  AND autodata.ndtime <=MonthEnd)
		    Group by mc,comp,opn
		) as T1
	Inner join Machineinformation M on M.interfaceID = T1.mc
	Inner join componentinformation C on T1.Comp=C.interfaceid
	Inner join ComponentOperationPricing O ON T1.Opn=O.interfaceid and C.Componentid=O.componentid and O.MachineID = M.MachineID
	GROUP BY MC
	) as T2 inner join #MonthWiseData on T2.mc = #MonthWiseData.InterfaceID
END
END


UPDATE #MonthWiseData SET ManPower=ISNULL(t.noofopr,1)
FROM
(SELECT machineid, SUM(NoOfOperators) AS noofopr FROM manpowerdetails_mivin
WHERE DATEPART(MONTH,@StartDate)=DATEPART(MONTH,pdate)
GROUP BY machineid
)t INNER JOIN #MonthWiseData ON t.MachineId=#MonthWiseData.MachineId

UPDATE #MonthWiseData SET Hours=DATEDIFF(HOUR,MonthStart,MonthEnd)

UPDATE #MonthWiseData SET pdt=ISNULL(T.plannedDT,0)
FROM
(
SELECT MachineID,DBO.f_FormatTime((ISNULL(SUM(DATEDIFF(ss,StartTime,EndTime)),0)),'HH') AS plannedDT FROM #PlannedDownTimes
WHERE EndTime>=@T_ST AND EndTime<=@T_ED
GROUP BY MachineID
)T INNER JOIN #MonthWiseData ON T.MachineId=#MonthWiseData.MachineId

UPDATE #MonthWiseData SET ACTUAL=ISNULL(ROUND((TotalParts/ManPower/(Hours-PDT)),6),0)
WHERE ((HOURS-PDT)<>0) AND (ManPower<>0)

UPDATE #MonthWiseData SET Target=(T1.TGT)
FROM
(SELECT GroupID,TARGET AS TGT FROM PlantWiseTargetDetails_Mivin WHERE GroupID=@GroupID
) T1 INNER JOIN #MonthWiseData ON T1.GroupID=#MonthWiseData.GroupID

select id,GroupID,MachineId,InterfaceID,MonthName,MonthStart,MonthEnd,isnull(totalparts,0) as TotalParts,isnull(ManPower,0) as ManPower,Hours as Hours,pdt AS pdt, ROUND(Actual,3) AS Actual,Target AS Target from #MonthWiseData
order by id
------------------------------------------------------------------MonthWise Data for each machines (istestbenchenable=1) ends--------------------------------------------------------------------------------------------
---------------------------------------------------------------------Daywise Data for specific machine for the passed month starts----------------------------------------------------------------------------
Declare @lstart AS nvarchar(50) 
Declare @lend AS nvarchar(50) 

while @monthst <= @monthnd
begin
	SET @lstart = dbo.f_GetLogicalDay(@monthst,'start') 
	SET @lend = dbo.f_GetLogicalDay(@monthst,'End') 

	insert into #DayWiseData(GroupID,MachineId,InterfaceID,Date,FromTime,ToTime)
	select distinct p1.GroupID,m.MachineId,m.InterfaceID, @monthst,convert(nvarchar(20),@lstart),convert(nvarchar(20),@lend) from PlantInformation p
	inner join PlantMachineGroups p1 on p.PlantID=p1.PlantID
	inner join machineinformation m on m.machineid=p1.MachineID --and m.IsTestBenchMachine=1
	where (p1.GroupID=@GroupID)


	SELECT @monthst=DATEADD(DAY,1,@monthst)

end

IF @GroupID='Testing'
BEGIN
update #DayWiseData set TotalParts=ISNULL(t.total,0)
from
(
select p1.GroupID,m.MachineID,Y.FromTime,y.ToTime,count(t1.SlNo) as total from PlantInformation p
inner join PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join #DayWiseData y on y.GroupID=p1.GroupID AND Y.MachineId=P1.MachineID
inner join machineinformation m on m.machineid=p1.MachineID --and m.IsTestBenchMachine=1
inner join #Test t1 on t1.Machineid=m.InterfaceID 
where (MeasuredDateTime>=y.FromTime and MeasuredDateTime<=y.ToTime) and p1.GroupID=@GroupID
group by p1.GroupID,m.MachineID,Y.FromTime,y.ToTime
)t inner join #DayWiseData on t.GroupID=#DayWiseData.GroupID AND T.MachineID=#DayWiseData.MachineId and t.FromTime=#DayWiseData.FromTime and t.ToTime=#DayWiseData.ToTime
END

IF @GroupID<>'Testing'
BEGIN
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='N'
begin
UPDATE #DayWiseData SET TotalParts = ISNULL(TotalParts,0) + ISNULL(t2.comp,0)
From
(
	  Select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) As Comp,Date --NR0097
		   From (select mc,SUM(autodata.partscount)AS OrginalCount,comp,opn,M1.Date 
			from #T_autodata autodata 
			INNER JOIN #DayWiseData M1 ON M1.InterfaceID=autodata.mc
		   where (autodata.ndtime>FromTime) and (autodata.ndtime<=ToTime) and (autodata.datatype=1)
		   Group By mc,comp,opn,M1.Date) as T1
	Inner join componentinformation C on T1.Comp = C.interfaceid
	Inner join ComponentOperationPricing O ON  T1.Opn = O.interfaceid and C.Componentid=O.componentid
	inner join machineinformation on machineinformation.machineid =O.machineid
	and T1.mc=machineinformation.interfaceid
	GROUP BY mc,Date
) As T2 Inner join #DayWiseData on T2.mc = #DayWiseData.InterfaceID AND t2.Date=#DayWiseData.Date
END

If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN
UPDATE #DayWiseData SET TotalParts = ISNULL(TotalParts,0) + ISNULL(t2.comp,0)
From
(
	  Select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) As Comp,T1.Date --NR0097
		   From (select mc,SUM(autodata.partscount)AS OrginalCount,comp,opn,M1.Date 
			from #T_autodata autodata 
			INNER JOIN #DayWiseData M1 ON M1.InterfaceID=autodata.mc
		   where (autodata.ndtime>FromTime) and (autodata.ndtime<=ToTime) and (autodata.datatype=1)
		   Group By mc,comp,opn,M1.Date) as T1
	Inner join componentinformation C on T1.Comp = C.interfaceid
	Inner join ComponentOperationPricing O ON  T1.Opn = O.interfaceid and C.Componentid=O.componentid
	inner join machineinformation on machineinformation.machineid =O.machineid
	and T1.mc=machineinformation.interfaceid
	GROUP BY mc,T1.Date
) As T2 Inner join #DayWiseData on T2.mc = #DayWiseData.InterfaceID AND t2.Date=#DayWiseData.Date

	UPDATE #DayWiseData SET TotalParts = ISNULL(TotalParts,0) - ISNULL(T2.comp,0) from(
		select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) as comp,T1.date From ( --NR0097
			select mc,Sum(ISNULL(PartsCount,1))AS OrginalCount,comp,opn,M1.date 
			from #T_autodata autodata 
			INNER JOIN #DayWiseData M1 ON M1.InterfaceID=autodata.mc
			CROSS JOIN #PlannedDownTimes T
			WHERE autodata.DataType=1 And T.MachineInterface = autodata.mc
			AND (autodata.ndtime > T.StartTime  AND autodata.ndtime <=T.EndTime)
			AND (autodata.ndtime > FromTime  AND autodata.ndtime <=ToTime)
		    Group by mc,comp,opn,M1.date
		) as T1
	Inner join Machineinformation M on M.interfaceID = T1.mc
	Inner join componentinformation C on T1.Comp=C.interfaceid
	Inner join ComponentOperationPricing O ON T1.Opn=O.interfaceid and C.Componentid=O.componentid and O.MachineID = M.MachineID
	GROUP BY MC,T1.date
	) as T2 inner join #DayWiseData on T2.mc = #DayWiseData.InterfaceID AND t2.date=#DayWiseData.date
END
END

UPDATE #DayWiseData SET ManPower=ISNULL(t.noofopr,1)
FROM
(SELECT machineid,pdate,SUM(NoOfOperators) AS noofopr FROM manpowerdetails_mivin
GROUP BY machineid,pdate
)t INNER JOIN #DayWiseData ON t.MachineId=#DayWiseData.MachineId AND t.pdate=#DayWiseData.Date

UPDATE #DayWiseData SET Hours=DATEDIFF(HOUR,FromTime,ToTime)

UPDATE #DayWiseData SET pdt=ISNULL(T.plannedDT,0)
FROM
(
SELECT D.MachineID,D.Fromtime,DBO.f_FormatTime((ISNULL(SUM(DATEDIFF(ss,StartTime,EndTime)),0)),'HH') AS plannedDT FROM #PlannedDownTimes P
INNER JOIN #DayWiseData D ON D.MachineId=P.MachineID
WHERE StartTime>=FromTime AND EndTime<=ToTime
GROUP BY D.MachineId,D.FromTime
)T INNER JOIN #DayWiseData ON T.MachineId=#DayWiseData.MachineId AND t.FromTime=#DayWiseData.FromTime

UPDATE #DayWiseData SET ACTUAL=ISNULL(ROUND((TotalParts/ManPower/(Hours-PDT)),6),0)
WHERE ((HOURS-PDT)<>0) AND (ManPower<>0)

UPDATE #DayWiseData SET Target=(T1.TGT)
FROM
(SELECT GroupID,TARGET AS TGT FROM PlantWiseTargetDetails_Mivin WHERE GroupID=@GroupID
) T1 INNER JOIN #DayWiseData ON T1.GroupID=#DayWiseData.GroupID


select id,GroupID,machineid,InterfaceID,date, fromtime,totime,isnull(totalparts,0) as TotalParts,isnull(ManPower,0) as ManPower,Hours as Hours, pdt AS pdt,round(Actual,3) AS Actual,Target AS Target from #DayWiseData
order by GroupID,Machineid,date

---------------------------------------------------------------------Daywise Data for specific machine for the passed month ends----------------------------------------------------------------------------


END
