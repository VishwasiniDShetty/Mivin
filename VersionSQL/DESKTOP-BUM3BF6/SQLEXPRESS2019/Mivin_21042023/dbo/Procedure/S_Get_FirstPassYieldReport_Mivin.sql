/****** Object:  Procedure [dbo].[S_Get_FirstPassYieldReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_Get_FirstPassYieldReport_Mivin] 'Testing','2022-01-01'
*/
CREATE PROCEDURE [dbo].[S_Get_FirstPassYieldReport_Mivin]
@GroupID NVARCHAR(50)='',
@StartDate DATETIME=''
AS
BEGIN


CREATE TABLE #Test
(
GroupID NVARCHAR(50),
Machineid NVARCHAR(50),
PumpModel NVARCHAR(50),
MeasuredDateTime DATETIME,
SlNo NVARCHAR(50),
ReCheckNo INT,
ReworkNo INT,
Total FLOAT
)
CREATE TABLE #YearWiseDateList
(
	ID BIGINT IDENTITY(1,1),
	MonthName NVARCHAR(50),
	MonthStart DATETIME,
	MonthEnd DATETIME,
	GroupID NVARCHAR(50),
	TotalParts FLOAT DEFAULT 0,
	FirstPassYield FLOAT DEFAULT 0,
	Actual FLOAT DEFAULT 0
)

CREATE TABLE #MonthWiseData
(
	ID BIGINT IDENTITY(1,1),
	MonthName NVARCHAR(50),
	MonthStart DATETIME,
	MonthEnd DATETIME,
	GroupID NVARCHAR(50),
	MachineId NVARCHAR(50),
	TotalParts FLOAT DEFAULT 0,
	FirstPassYield FLOAT DEFAULT 0,
	Actual FLOAT DEFAULT 0
)

Create table #DayWiseData
(
	ID bigint Identity(1,1),
	Date datetime,
	FromTime datetime,
	ToTime datetime,
	GroupID nvarchar(50),
	MachineId nvarchar(50),
	TotalParts float default 0,
	FirstPassYield float default 0,
	Actual float default 0
)

DECLARE @MonthStart datetime
Declare @MonthEnd Datetime

DECLARE @monthst datetime
Declare @monthnd Datetime


DECLARE @YearStart datetime
DECLARE @YStart datetime
DECLARE @Yend datetime
Declare @YearEnd Datetime

SELECT @YearStart = dbo.f_GetLogicalDay((DATEADD(yy, DATEDIFF(yy, 0, @StartDate), 0)),'start')
SELECT @YStart =  DATEADD(yy, DATEDIFF(yy, 0, @StartDate), 0)
select @Yend=  DATEADD(yy, DATEDIFF(yy, 0, @StartDate) + 1, -1)
SELECT @YearEnd = dbo.f_GetLogicalDay(( DATEADD(yy, DATEDIFF(yy, 0, @StartDate) + 1, -1)),'End')

-------------------------------------------------------Insert into #test1 data from (PumpTestData_Mivin table) starts--------------------------------------------------------------------------------------------------

insert into #Test(GroupID,machineid,PumpModel,SlNo,MeasuredDateTime)
select distinct P1.GroupID, M.machineid,p.PumpModel,P.slno, max(MeasuredDatetime) as MeasuredDatetime from PumpTestData_Mivin P
INNER JOIN machineinformation M ON M.InterfaceID=P.MachineID and IsTestBenchMachine=1
INNER JOIN dbo.PlantMachineGroups P1 ON P1.MachineID=M.machineid
where  (MeasuredDatetime>=@YearStart and MeasuredDatetime<=@YearEnd) AND P1.GroupID=@GroupID AND ISNULL(p.IsMasterPump,0)<>1
group by P1.GroupID,M.machineid,PumpModel,P.SlNo


update #Test set ReworkNo=isnull(t1.rewrk,0),ReCheckNo=isnull(t1.rechk,0)
from
(select distinct machineid,pumpmodel,slno,MeasuredDatetime,reworkno as rewrk,ReCheckNo as rechk  from PumpTestData_Mivin
where  (MeasuredDatetime>=@YearStart and MeasuredDatetime<=@YearEnd)
) t1 inner join #Test on t1.MachineID=#Test.Machineid and t1.PumpModel=#Test.PumpModel and t1.SlNo=#Test.SlNo and t1.MeasuredDatetime=#Test.MeasuredDatetime


--SELECT PLANTID,MACHINEID,PUMPMODEL,SLNO,MEASUREDDATETIME,ReworkNo,ReCheckNo FROM #Test
--RETURN
----------------------------------------------------------------Insert into #test1 data from (PumpTestData_Mivin table) ends--------------------------------------------------------------------------------------------------


------------------------------------------------------------------MonthWise Data for passed startdate(year part) starts--------------------------------------------------------------------------------------------
while @YStart <= @Yend
begin

	insert into #YearWiseDateList(MonthName,MonthStart,MonthEnd,GroupID)
	select cast(Datename(month,@YStart) as nvarchar(3)),dbo.f_GetLogicalDay((DATEADD(MONTH, DATEDIFF(MONTH, 0, @YStart), 0)),'start'),dbo.f_GetLogicalDay((EOMONTH(@YStart)),'End'),@GroupID

	SELECT @YStart=DATEADD(MONTH,1,@YStart)
end

update #YearWiseDateList set TotalParts=ISNULL(t.total,0)
from
(
select p1.groupid,MonthName,count(t1.SlNo) as total from PlantInformation p
inner join dbo.PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join #YearWiseDateList y on y.GroupID=p1.GroupID
inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
inner join #Test t1 on t1.Machineid=m.InterfaceID 
where (t1.MeasuredDateTime>=y.MonthStart and  t1.MeasuredDateTime<=y.MonthEnd)
and p1.GroupID=@GroupID
group by p1.GroupID,MonthName
)t inner join #YearWiseDateList on t.GroupID=#YearWiseDateList.GroupID and t.MonthName=#YearWiseDateList.MonthName

update #YearWiseDateList set FirstPassYield=ISNULL(t.FPY,0)
FROM
(
select p1.GroupID,MonthName,count(t1.SlNo) as FPY from PlantInformation p
inner join dbo.PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join #YearWiseDateList y on y.GroupID=p1.GroupID
inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
inner join #Test t1 on t1.Machineid=m.InterfaceID 
where (t1.MeasuredDateTime>=y.MonthStart and  t1.MeasuredDateTime<=y.MonthEnd) AND (ISNULL(T1.ReworkNo,0)=0)
and p1.GroupID=@GroupID
group by p1.GroupID,MonthName
)t inner join #YearWiseDateList on t.GroupID=#YearWiseDateList.GroupID and t.MonthName=#YearWiseDateList.MonthName

update #YearWiseDateList set Actual=round((FirstPassYield/TotalParts)*100,2)
where TotalParts <> 0

select ID,MonthName,MonthStart,MonthEnd,GroupID,ISNULL(TOTALPARTS,0) AS TotalParts,isnull(FirstPassYield,0) as FirstPassYield,Actual as ActualInPercent from #YearWiseDateList
order by id asc

------------------------------------------------------------------MonthWise Data for passed startdate(year part) ends--------------------------------------------------------------------------------------------
------------------------------------------------------------------MonthWise Data for each machines (istestbenchenable=1) starts--------------------------------------------------------------------------------------------

SELECT @MonthSt = DATEADD(month, DATEDIFF(month, 0, @StartDate), 0) 
SELECT @Monthnd = EOMONTH(@StartDate)

select @MonthStart=dbo.f_GetLogicalDay(@MonthSt,'start') 
select @MonthEnd=dbo.f_GetLogicalDay(@Monthnd,'end') 

insert into #MonthWiseData(GroupID,MachineId,MonthName,MonthStart,MonthEnd)
select distinct p1.GroupID,m.Machineid,cast(Datename(month,@StartDate) as nvarchar(3)),@MonthStart,@MonthEnd
from PlantInformation p
inner join dbo.PlantMachineGroups p1 on p.PlantID=p1.PlantID
inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
where (p1.GroupID=@GroupID)
order by p1.GroupID,Machineid


update #MonthWiseData set TotalParts=ISNULL(t.total,0)
from
(
select p1.GroupID,m.MachineID,MonthName,count(t1.SlNo) as total from PlantInformation p
inner join dbo.PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
inner join #MonthWiseData y on y.GroupID=p1.GroupID AND Y.MachineId=p1.machineid
inner join #Test t1 on t1.Machineid=m.InterfaceID AND T1.GroupID=Y.GroupID
where (t1.MeasuredDateTime>=y.MonthStart and  t1.MeasuredDateTime<=y.MonthEnd)
and p1.GroupID=@GroupID
group by p1.GroupID,m.MachineID,MonthName
)t inner join #MonthWiseData on t.GroupID=#MonthWiseData.GroupID AND T.MachineID=#MonthWiseData.MachineId and t.MonthName=#MonthWiseData.MonthName

update #MonthWiseData set FirstPassYield=ISNULL(t.FPY,0)
FROM
(
select p1.GroupID,m.MachineID,MonthName,count(t1.SlNo) as FPY from PlantInformation p
inner join dbo.PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
inner join #MonthWiseData y on y.GroupID=p1.GroupID AND Y.MachineId=p1.machineid
inner join #Test t1 on t1.Machineid=m.InterfaceID AND T1.GroupID=Y.GroupID
where (t1.MeasuredDateTime>=y.MonthStart and  t1.MeasuredDateTime<=y.MonthEnd) AND (ISNULL(T1.ReworkNo,0)=0)
and p1.GroupID=@GroupID
group by p1.GroupID,m.MachineID,MonthName
)t inner join #MonthWiseData on t.GroupID=#MonthWiseData.GroupID AND T.MachineID=#MonthWiseData.MachineId and t.MonthName=#MonthWiseData.MonthName



update #MonthWiseData set Actual=round((FirstPassYield/TotalParts)*100,2)
where TotalParts <> 0

select id,MonthName,MonthStart,MonthEnd,GroupID,MachineId,isnull(totalparts,0) as TotalParts,isnull(FirstPassYield,0) as FirstPassYield,Actual as ActualInPercent from #MonthWiseData
order by id
------------------------------------------------------------------MonthWise Data for each machines (istestbenchenable=1) ends--------------------------------------------------------------------------------------------
---------------------------------------------------------------------Daywise Data for specific machine for the passed month starts----------------------------------------------------------------------------
Declare @lstart AS nvarchar(50) 
Declare @lend AS nvarchar(50) 

while @monthst <= @monthnd
begin
	SET @lstart = dbo.f_GetLogicalDay(@monthst,'start') 
	SET @lend = dbo.f_GetLogicalDay(@monthst,'End') 

	insert into #DayWiseData(GroupID,MachineId,Date,FromTime,ToTime)
	select distinct p1.GroupID,m.MachineId, @monthst,convert(nvarchar(20),@lstart),convert(nvarchar(20),@lend) from PlantInformation p
	inner join dbo.PlantMachineGroups p1 on p.PlantID=p1.PlantID
	inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
	where (p1.GroupID=@GroupID)


	SELECT @monthst=DATEADD(DAY,1,@monthst)

end

update #DayWiseData set TotalParts=ISNULL(t.total,0)
from
(
select p1.GroupID,m.MachineID,Y.FromTime,y.ToTime,count(t1.SlNo) as total from PlantInformation p
inner join dbo.PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join #DayWiseData y on y.GroupID=p1.GroupID AND Y.MachineId=P1.MachineID
inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
inner join #Test t1 on t1.Machineid=m.InterfaceID 
where (MeasuredDateTime>=y.FromTime and MeasuredDateTime<=y.ToTime) and p1.GroupID=@GroupID
group by p1.GroupID,m.MachineID,Y.FromTime,y.ToTime
)t inner join #DayWiseData on t.GroupID=#DayWiseData.GroupID AND T.MachineID=#DayWiseData.MachineId and t.FromTime=#DayWiseData.FromTime and t.ToTime=#DayWiseData.ToTime

update #DayWiseData set FirstPassYield=ISNULL(t.FPY,0)
FROM
(
select p1.GroupID,m.MachineID,Y.FromTime,y.ToTime,count(t1.SlNo) as FPY from PlantInformation p
inner join PlantMachineGroups p1 on p1.PlantID=p.PlantID
inner join #DayWiseData y on y.GroupID=p1.GroupID AND Y.MachineId=P1.MachineID
inner join machineinformation m on m.machineid=p1.MachineID and m.IsTestBenchMachine=1
inner join #Test t1 on t1.Machineid=m.InterfaceID 
where (MeasuredDateTime>=y.FromTime and MeasuredDateTime<=y.ToTime) and (p1.GroupID=@GroupID) and (isnull(t1.ReworkNo,0)=0)
group by p1.GroupID,m.MachineID,Y.FromTime,y.ToTime
)t inner join #DayWiseData on t.GroupID=#DayWiseData.GroupID AND T.MachineID=#DayWiseData.MachineId and t.FromTime=#DayWiseData.FromTime and t.ToTime=#DayWiseData.ToTime

update #DayWiseData set Actual=round((FirstPassYield/TotalParts)*100,2)
where TotalParts <> 0

select id,GroupID,machineid,date, fromtime,totime,isnull(totalparts,0) as totalparts, isnull(FirstPassYield,0) as FirstPassYield,Actual as ActualInPercent from #DayWiseData
order by GroupID,Machineid,date

---------------------------------------------------------------------Daywise Data for specific machine for the passed month ends----------------------------------------------------------------------------

end
