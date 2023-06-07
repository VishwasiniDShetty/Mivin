/****** Object:  Procedure [dbo].[S_GetAggregatedReports_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_GetAggregatedReports_Mivin] '','Housing','2021-04-01 00:00:00',''
[dbo].[S_GetAggregatedReports_Mivin] '','Housing','2020-11-28 00:00:00',''
[dbo].[S_GetAggregatedReports_Mivin] 'VMC-17','','2020-11-28 00:00:00',''

*/

CREATE PROCEDURE [dbo].[S_GetAggregatedReports_Mivin]
@MachineId NVARCHAR(50)='',
@GroupID nvarchar(50)='',
@StartDate datetime='',
@Param nvarchar(50)=''

AS
BEGIN

Create table #YearWiseDateList
(
	MonthName nvarchar(50),
	MonthStart datetime,
	MonthEnd datetime
)

Create table #YearWiseData
(
	ID bigint Identity(1,1),
	MonthName nvarchar(50),
	MonthStart datetime,
	MonthEnd datetime,
	GroupID nvarchar(50),
	AcceptedQty float default 0,
	ProdQty float default 0,
	RejCount float default 0,
	FirstPassYield float default 0,
)

Create table #MonthWiseData
(
	ID bigint Identity(1,1),
	MonthName nvarchar(50),
	MonthStart datetime,
	MonthEnd datetime,
	MachineId nvarchar(50),
	GroupID nvarchar(50),
	AcceptedQty float default 0,
	ProdQty float default 0,
	RejCount float default 0,
	FirstPassYield float default 0,
)

Create table #DayWiseData
(
	ID bigint Identity(1,1),
	Date datetime,
	MachineId nvarchar(50),
	GroupID nvarchar(50),
	AcceptedQty float default 0,
	ProdQty float default 0,
	RejCount float default 0,
	FirstPassYield float default 0,
)

DECLARE @MonthStart datetime
Declare @MonthEnd Datetime

DECLARE @YearStart datetime
DECLARE @YStart datetime
Declare @YearEnd Datetime

SELECT @YearStart =  DATEADD(yy, DATEDIFF(yy, 0, @StartDate), 0)
SELECT @YStart =  DATEADD(yy, DATEDIFF(yy, 0, @StartDate), 0)
SELECT @YearEnd =  DATEADD(yy, DATEDIFF(yy, 0, @StartDate) + 1, -1)

----------------------------------------------------------------------- Cell Eff w.r.t each month-----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

while @YStart <= @YearEnd
begin
	insert into #YearWiseDateList(MonthName,MonthStart,MonthEnd)
	select cast(Datename(month,@YStart) as nvarchar(3)),DATEADD(MONTH, DATEDIFF(MONTH, 0, @YStart), 0),EOMONTH(@YStart)

	SELECT @YStart=DATEADD(MONTH,1,@YStart)
end

insert into #YearWiseData(GroupID,MonthName,MonthStart,MonthEnd)
select distinct GroupID,MonthName,MonthStart,MonthEnd from ShiftProductionDetails
cross join #YearWiseDateList
where (GroupID=@GroupID or isnull(@GroupID,'')='')
order by GroupID,MonthStart

update #YearWiseData set AcceptedQty=ISNULL(T1.AcceptedCnt,0), ProdQty=ISNULL(T1.ProdQty,0)
from(
	SELECT A1.GroupID,A2.MonthName,sum(isnull(A1.AcceptedParts,0)) as AcceptedCnt, sum(isnull(A1.Prod_Qty,0)) as ProdQty from ShiftProductionDetails A1
	INNER join #YearWiseData A2 on A1.GroupID=A2.GroupID 
	WHERE A1.pDate between A2.MonthStart and A2.MonthEnd
	GROUP by A1.GroupID,A2.MonthName
)T1 inner join #YearWiseData T2 on T1.GroupID=T2.GroupID and T1.MonthName=T2.MonthName

update #YearWiseData set RejCount=T1.Rej
from (
	Select  A1.GroupID,A2.MonthName,Sum(isnull(ShiftRejectionDetails.Rejection_Qty,0))as Rej  
	From ShiftProductionDetails A1 inner join #YearWiseData A2 on A1.GroupID=A2.GroupID 
	Left Outer Join ShiftRejectionDetails ON A1.ID=ShiftRejectionDetails.ID  
	where A1.pDate between A2.MonthStart and A2.MonthEnd
	group by A1.GroupID,A2.MonthName
)T1 inner join #YearWiseData T2 on T1.GroupID=T2.GroupID and T1.MonthName=T2.MonthName


--update #YearWiseData set FirstPassYield=round((AcceptedQty/ProdQty)*100,2)
--where ProdQty <> 0

update #YearWiseData set FirstPassYield=round((AcceptedQty/(AcceptedQty+RejCount))*100,2)
where (AcceptedQty+RejCount) <> 0

select distinct ID,MonthName,GroupID,AcceptedQty,ProdQty,FirstPassYield from #YearWiseData
order by Id ASC
----------------------------------------------------------------------- Machine Eff for a month -----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT @MonthStart = DATEADD(month, DATEDIFF(month, 0, @StartDate), 0) 
SELECT @MonthEnd = EOMONTH(@StartDate)

insert into #MonthWiseData(GroupID,MachineId,MonthName,MonthStart,MonthEnd)
select distinct GroupID,Machineid,cast(Datename(month,@StartDate) as nvarchar(3)),@MonthStart,@MonthEnd
from ShiftProductionDetails
where (GroupID=@GroupID or isnull(@GroupID,'')='')
and (MachineID=@MachineId or isnull(@MachineId,'')='')
order by GroupID,Machineid

update #MonthWiseData set AcceptedQty=ISNULL(T1.AcceptedCnt,0), ProdQty=ISNULL(T1.ProdQty,0)
from(
	SELECT A1.GroupID,A1.MachineID,A2.MonthName,sum(isnull(A1.AcceptedParts,0)) as AcceptedCnt, sum(isnull(A1.Prod_Qty,0)) as ProdQty from ShiftProductionDetails A1
	INNER join #MonthWiseData A2 on A1.GroupID=A2.GroupID and A1.MachineID=A2.MachineId
	WHERE A1.pDate between A2.MonthStart and A2.MonthEnd
	GROUP by A1.GroupID,A1.MachineID,A2.MonthName
)T1 inner join #MonthWiseData T2 on T1.MachineID=T2.MachineId and T1.GroupID=T2.GroupID and T1.MonthName=T2.MonthName

update #MonthWiseData set RejCount=T1.Rej
from (
	Select  A1.GroupID,A1.MachineID,A2.MonthName,Sum(isnull(ShiftRejectionDetails.Rejection_Qty,0))as Rej  
	From ShiftProductionDetails A1 inner join #MonthWiseData A2 on A1.GroupID=A2.GroupID  and A1.MachineID=A2.MachineId
	Left Outer Join ShiftRejectionDetails ON A1.ID=ShiftRejectionDetails.ID  
	where A1.pDate between A2.MonthStart and A2.MonthEnd
	group by A1.GroupID,A1.MachineID,A2.MonthName
)T1 inner join #MonthWiseData T2 on T1.MachineID=T2.MachineId and T1.GroupID=T2.GroupID and T1.MonthName=T2.MonthName

--update #MonthWiseData set FirstPassYield=round((AcceptedQty/ProdQty)*100,2)
--where ProdQty <> 0

update #MonthWiseData set FirstPassYield=round((AcceptedQty/(AcceptedQty+RejCount))*100,2)
where (AcceptedQty+RejCount) <> 0

select ID,MonthName,GroupID,MachineId,AcceptedQty,ProdQty,FirstPassYield from #MonthWiseData
ORDER BY ID

----------------------------------------------------------------------- Machine Eff w.r.t each day -----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

while @MonthStart <= @MonthEnd
begin
	insert into #DayWiseData(Date,GroupID,MachineId)
	select distinct @MonthStart,GroupID,MachineId from ShiftProductionDetails
	where (GroupID=@GroupID or isnull(@GroupID,'')='')
	and (MachineID=@MachineId or isnull(@MachineId,'')='')

	SELECT @MonthStart=DATEADD(DAY,1,@MonthStart)
end

update #DayWiseData set AcceptedQty=ISNULL(T1.AcceptedCnt,0), ProdQty=ISNULL(T1.ProdQty,0)
from(
	SELECT A1.GroupID,A1.MachineID,A2.Date,sum(isnull(A1.AcceptedParts,0)) as AcceptedCnt, sum(isnull(A1.Prod_Qty,0)) as ProdQty from ShiftProductionDetails A1
	INNER join #DayWiseData A2 on A1.GroupID=A2.GroupID and A1.MachineID=A2.MachineId
	WHERE convert(nvarchar(10),A1.pDate,120) = convert(nvarchar(10),A2.Date,120)
	GROUP by A1.GroupID,A1.MachineID,A2.Date
)T1 inner join #DayWiseData T2 on T1.MachineID=T2.MachineId and T1.GroupID=T2.GroupID and T1.Date=T2.Date


update #DayWiseData set RejCount=T1.Rej
from (
	Select   A1.GroupID,A1.MachineID,A2.Date,Sum(isnull(ShiftRejectionDetails.Rejection_Qty,0))as Rej  
	From ShiftProductionDetails A1 inner join #DayWiseData A2 on A1.GroupID=A2.GroupID and A1.MachineID=A2.MachineId
	Left Outer Join ShiftRejectionDetails ON A1.ID=ShiftRejectionDetails.ID  
	where convert(nvarchar(10),A1.pDate,120) = convert(nvarchar(10),A2.Date,120)
	group by A1.GroupID,A1.MachineID,A2.Date
)T1 inner join #DayWiseData T2 on T1.MachineID=T2.MachineId and T1.GroupID=T2.GroupID and T1.Date=T2.Date

--update #DayWiseData set FirstPassYield=round((AcceptedQty/ProdQty)*100,2)
--where ProdQty <> 0

update #DayWiseData set FirstPassYield=round((AcceptedQty/(AcceptedQty+RejCount))*100,2)
where (AcceptedQty+RejCount) <> 0

select ID,Date,MachineId,GroupID,AcceptedQty,ProdQty,FirstPassYield from #DayWiseData
order by GroupID,Machineid,date

END
