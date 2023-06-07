/****** Object:  Procedure [dbo].[s_GetShiftwiseAndonDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

--- [dbo].[s_GetShiftwiseAndonDetails_Mivin] 'Station3','2020-09-04 15:00:00'

CREATE PROCEDURE [dbo].[s_GetShiftwiseAndonDetails_Mivin]
@StationID nvarchar(50),
@Starttime datetime,
@PumpModel nvarchar(50)=''
AS
BEGIN

CREATE TABLE #ShiftDetails
(
dDate datetime ,
Shift nvarchar(50),
Starttime datetime ,
Endtime datetime,
Shiftid int
)

create table #Schedules
(
StationID nvarchar(50),
SDate datetime,
WONumber nvarchar(50),
PumpModel nvarchar(50),
CustomerModel nvarchar(50),
Customer nvarchar(50),
PackingTarget int,
QtyPerbox int,
TotalScannedQty int default 0,
PackagingType nvarchar(50),
PackedBoxCount int default 0,
WorkOrderStatus nvarchar(50),
Priority int,
PendingQty int default 0,
TotalTarget int default 0
)

create table #RunningSchedules
(
StationID nvarchar(50),
SDate datetime,
WONumber nvarchar(50),
PumpModel nvarchar(50),
CustomerModel nvarchar(50),
ScannedQty int ,
QtyPerbox int,
operator nvarchar(50),
LastScannedSlno nvarchar(50),
PackagingType nvarchar(50),
WorkOrderStatus nvarchar(50),
TotalScannedQty int,
MonthlyTotalScannedQty int default 0,
MonthlyTotalTarget int default 0
)

create table #Efficiency
(
shifttarget float,
Shiftactual float,
Efficiency float
)


----RESULT1
insert into #RunningSchedules(StationID,SDate,WONumber,PumpModel,CustomerModel,QtyPerbox,WorkOrderStatus,PackagingType)
Select R.StationID,R.ScheduledDate,R.WONumber,R.PumpModel,R.CustomerModel,M.PerBoxPumpQty,S.WorkOrderStatus,R.PackagingType from RunningScheduleDetails R
inner join PumpMasterData M on M.PumpModel=R.PumpModel and M.PackagingType=R.PackagingType
inner join ScheduleDetails S on R.PumpModel=S.PumpModel and R.PackagingType=S.PackagingType and convert(nvarchar(10),S.Date,120)=convert(nvarchar(10),R.ScheduledDate,120)
inner join StationInformation ST on ST.StationID=R.StationID
where (S.PumpModel=@PumpModel or isnull(@pumpmodel,'')='')
and (R.StationID=@StationID or isnull(@StationID,'')='')

Declare @LastPrintTS as datetime

select @LastPrintTS=max(S1.ScannedTS) from ScannedDetails S1 inner join #RunningSchedules R on
R.PumpModel=S1.PumpModel and R.PackagingType=S1.PackagingType and convert(nvarchar(10),S1.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S1.StationID=R.StationID
where S1.ScannedOrForceCloseStatus=1 and (S1.StationID=@StationID or isnull(@StationID,'')='')

create table #StationwiseMaxScannedTS
(
Stationid nvarchar(50),
MaxScannedTS datetime
)

insert into #StationwiseMaxScannedTS(Stationid,MaxScannedTS)
Select S1.StationID,max(S1.ScannedTS) from ScannedDetails S1 inner join #RunningSchedules R on R.PumpModel=S1.PumpModel and R.PackagingType=S1.PackagingType and convert(nvarchar(10),S1.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and R.StationID=S1.StationID
where S1.ScannedOrForceCloseStatus=1 and (S1.StationID=@StationID or isnull(@StationID,'')='')
group by S1.StationID


If ISNULL(@LastPrintTS,'1900-01-01')<>'1900-01-01'
Begin
--update #RunningSchedules set ScannedQty=ISNULL(T.qty,0) from
--(select Count(S.ScannedQty) as qty from ScannedDetails S
--inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.PackagingType=S.PackagingType and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
--where (S.StationID=@StationID or isnull(@StationID,'')='') and ScannedTS>(select max(S1.ScannedTS) from ScannedDetails S1 inner join #RunningSchedules R on R.PumpModel=S1.PumpModel and R.PackagingType=S1.PackagingType and convert(nvarchar(10),S1.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and R.StationID=S1.StationID
--where S1.ScannedOrForceCloseStatus=1 and (S1.StationID=@StationID or isnull(@StationID,'')='')))T

update #RunningSchedules set ScannedQty=ISNULL(T.qty,0) from
(select R.StationID,Count(S.ScannedQty) as qty from ScannedDetails S
inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.PackagingType=S.PackagingType and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
inner join #StationwiseMaxScannedTS M on M.Stationid=S.StationID
where (S.StationID=@StationID or isnull(@StationID,'')='') and S.ScannedTS>M.MaxScannedTS group by R.StationID
)T inner join #RunningSchedules on #RunningSchedules.StationID=T.StationID

END
Else
BEgin
update #RunningSchedules set ScannedQty=ISNULL(T.qty,0) from
(select S.StationID,Count(S.ScannedQty) as qty from ScannedDetails S
inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.PackagingType=S.PackagingType and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
where (S.StationID=@StationID or isnull(@StationID,'')='') group by S.StationID
)T inner join #RunningSchedules on #RunningSchedules.StationID=T.StationID
END


update #RunningSchedules set LastScannedSlno=T.ScannedSlNo,operator=T.Operator from
(select ScannedDetails.StationID,ScannedDetails.ScannedSlNo,ScannedDetails.Operator from
(select S.StationID,Max(ScannedTS) as ts from ScannedDetails S
inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.PackagingType=S.PackagingType and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
where (S.StationID=@StationID or isnull(@StationID,'')='') group by S.StationID
)t INNER JOIN ScannedDetails ON T.TS=ScannedDetails.ScannedTS and t.StationID=ScannedDetails.StationID
)T inner join #RunningSchedules on #RunningSchedules.StationID=T.StationID

update #RunningSchedules set TotalScannedQty=ISNULL(T.qty,0) from
(select S.stationid,Count(S.ScannedQty) as qty from ScannedDetails S
inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.PackagingType=S.PackagingType and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
where (S.StationID=@StationID or isnull(@StationID,'')='') group by S.StationID
)T inner join #RunningSchedules on #RunningSchedules.StationID=T.StationID

select StationID,SDate,WONumber,PumpModel,CustomerModel,QtyPerbox,ISNULL(ScannedQty,0) as ScannedQty,PackagingType,operator,LastScannedSlno,WorkOrderStatus,TotalScannedQty from #RunningSchedules
----RESULT1


----RESULT2
INSERT INTO #ShiftDetails(dDate,Shift,Starttime,Endtime,Shiftid)
EXEC s_GetCurrentShiftTime @Starttime

--insert into #Schedules(StationID,Sdate,WONumber,Customer,PumpModel,CustomerModel,PackingTarget,QtyPerbox,PackagingType,WorkOrderStatus,Priority)
--select ST.StationID,S.date,S.WONumber,S.CustomerName,S.PumpModel,S.CustomerModel,S.PumpQty,M.PerBoxPumpQty,S.PackagingType,S.WorkOrderStatus,S.WeekwisePriority from ScheduleDetails S
--inner join PumpMasterData M on M.PumpModel=S.PumpModel and S.PackagingType=M.PackagingType
--cross join StationInformation ST
--where S.WorkOrderStatus<>'Completed' and (S.PumpModel=@PumpModel or ISNULL(@PumpModel,'')='') and (ST.StationID=@StationID or isnull(@StationID,'')='')
--order by S.date

insert into #Schedules(StationID,Sdate,WONumber,Customer,PumpModel,CustomerModel,PackingTarget,QtyPerbox,PackagingType,WorkOrderStatus,Priority)
select ST.StationID,S.date,S.WONumber,M.CustomerName,S.PumpModel,M.CustomerModel,S.PumpQty,M.PerBoxPumpQty,S.PackagingType,S.WorkOrderStatus,S.WeekwisePriority from ScheduleDetails S
inner join PumpMasterData M on M.PumpModel=S.PumpModel and S.PackagingType=M.PackagingType
cross join StationInformation ST
where S.WorkOrderStatus<>'Completed' and (S.PumpModel=@PumpModel or ISNULL(@PumpModel,'')='') and (ST.StationID=@StationID or isnull(@StationID,'')='')
order by S.date

---Day Scanned QTy will be for the CurrentDay-Station
update #Schedules set TotalScannedQty=ISNULL(T.TotalScannedQty,0) from
(Select S.StationID,S.date,Count(S.ScannedQty) as TotalScannedQty from ScannedDetails S
where (S.StationID=@StationID or isnull(@StationID,'')='') and convert(nvarchar(10),S.Date,120)=convert(nvarchar(10),@Starttime,120)
group by S.StationID,S.date)T inner join #Schedules on T.StationID=#Schedules.StationID --convert(nvarchar(10),#Schedules.Sdate,120)=convert(nvarchar(10),T.ScheduledDate,120)

update #Schedules set PackedBoxCount=ISNULL(T.PackedBoxCount,0) from
(Select S.StationID,S.date,Count(*) as PackedBoxCount from ScannedDetails S
where S.ScannedOrForceCloseStatus=1 and (S.StationID=@StationID or isnull(@StationID,'')='') and convert(nvarchar(10),S.Date,120)=convert(nvarchar(10),@Starttime,120)
group by S.StationID,S.date)T inner join #Schedules on T.StationID=#Schedules.StationID

---Day target Qty will be for the CurrentDay-Station from ShiftwiseTargetMaster
update #schedules set TotalTarget=isnull(T.Target,0) from
(Select P.StationID,P.Date,ISNULL(sum(target),0) as Target from ShiftwiseTargetMaster P
Where (P.StationID=@StationID or isnull(@StationID,'')='') and convert(nvarchar(10),P.Date,120)=convert(nvarchar(10),@Starttime,120)
group by P.StationID,P.Date
)T inner join #Schedules S on T.StationID=S.StationID

select StationID,Sdate,WONumber,Customer,PumpModel,CustomerModel,PackingTarget,QtyPerbox,TotalScannedQty,PackedBoxCount,PackagingType,WorkOrderStatus,Priority from #Schedules
order by Sdate
----RESULT2

---RESULT3
Insert into #Efficiency(shifttarget,Shiftactual)
Select ISNULL(sum(target),0),0 from ShiftwiseTargetMaster P
cross join #ShiftDetails S
where convert(nvarchar(10),P.date,120)=convert(nvarchar(10),S.dDate,120) and P.Shift=S.Shift
and (P.StationID=@StationID or isnull(@stationid,'')='')

update #Efficiency set Shiftactual=ISNULL(T.qty,0) from
(Select count(ScannedQty) as qty from ScannedDetails S
cross join #ShiftDetails SH where convert(nvarchar(10),S.date,120)=convert(nvarchar(10),SH.dDate,120) and S.Shift=SH.Shift
and (S.StationID=@StationID or isnull(@stationid,'')='')
)T

update #Efficiency set Efficiency=Round(ISNULL((Shiftactual/shifttarget)*100,0),2) where shifttarget>0


select * from #Efficiency
--RESULT3

--RESULT4

---Monthly Scanned QTy will be forthe CurrentMonth-Station-pumpModel-packagingType
--update #RunningSchedules set MonthlyTotalScannedQty=ISNULL(T.TotalScannedQty,0) from
--(Select S.StationID,datepart(Month,S.Date) as sdate,S.pumpmodeL,S.PackagingType,Count(S.ScannedQty) as TotalScannedQty from ScannedDetails S
--INNER JOIN #RunningSchedules s1 ON S.PumpModel=S1.PumpModel and S.PackagingType=S1.PackagingType
--and S.StationID=s1.StationID
--where (S.StationID=@StationID or isnull(@StationID,'')='') and datepart(Month,S.Date)=datepart(Month,@Starttime)
--group by S.StationID,S.pumpmodeL,S.PackagingType,datepart(Month,S.Date))T inner join #RunningSchedules on T.PumpModel=#RunningSchedules.PumpModel and T.PackagingType=#RunningSchedules.PackagingType
--and T.StationID=#RunningSchedules.StationID
update #RunningSchedules set MonthlyTotalScannedQty=ISNULL(T.TotalScannedQty,0) from
(Select datepart(Month,S.Date) as sdate,S.pumpmodeL,S.PackagingType,Count(S.ScannedQty) as TotalScannedQty from ScannedDetails S
INNER JOIN (select distinct pumpmodel,PackagingType from #RunningSchedules) s1 ON S.PumpModel=S1.PumpModel and S.PackagingType=S1.PackagingType
where datepart(Month,S.Date)=datepart(Month,@Starttime)
group by S.pumpmodeL,S.PackagingType,datepart(Month,S.Date))T inner join #RunningSchedules on T.PumpModel=#RunningSchedules.PumpModel and T.PackagingType=#RunningSchedules.PackagingType

---Monthly Target QTy will be forthe CurrentMonth-Station-pumpModel-packagingType From MonthlyAndWeeklyScheduleDetails
--update #RunningSchedules set MonthlyTotalTarget=isnull(T.Target,0) from
--(Select S.StationID,datepart(month,S.SDate) as SDate,ISNULL(sum(MonthRequirement),0) as Target,S.PumpModel,S.PackagingType from MonthlyAndWeeklyScheduleDetails P
--inner join #RunningSchedules S on P.PumpModel=S.PumpModel and P.PackagingType=S.PackagingType
--Where (S.StationID=@StationID or isnull(@StationID,'')='') and datepart(Month,P.Date)=datepart(Month,@Starttime)
--group by S.StationID,datepart(month,S.SDate),S.PumpModel,S.PackagingType
--)T inner join #RunningSchedules S on datepart(month,S.SDate)=T.SDate and T.StationID=S.StationID and T.PumpModel=S.PumpModel and T.PackagingType=S.PackagingType

update #RunningSchedules set MonthlyTotalTarget=isnull(T.Target,0) from
(Select ISNULL(sum(MonthRequirement),0) as Target,S.PumpModel,S.PackagingType from MonthlyAndWeeklyScheduleDetails P
inner join (select distinct pumpmodel,PackagingType from #RunningSchedules) S on P.PumpModel=S.PumpModel and P.PackagingType=S.PackagingType
Where datepart(Month,P.Date)=datepart(Month,@Starttime)
group by S.PumpModel,S.PackagingType
)T inner join #RunningSchedules S on T.PumpModel=S.PumpModel and T.PackagingType=S.PackagingType

Select S.StationID,S.Sdate,S.Pumpmodel,S.PackagingType,ISNULL(SUM(S.totaltarget),0) as DailyTotalTarget,ISNULL(SUM(S.TotalScannedQty),0) as DailyActual,ISNULL(SUM(S.PackedBoxCount),0) as DailyNoOfPackedBoxes,
ISNULL(SUM(S.totaltarget),0)-ISNULL(SUM(S.TotalScannedQty),0) as DailyPendingQty,ISNULL(SUM(S.PackingTarget),0) as DailyPackingTarget
,R.MonthlyTotalScannedQty,R.MonthlyTotalTarget,(ISNULL(R.MonthlyTotalTarget,0)-ISNULL(R.MonthlyTotalScannedQty,0)) as MonthlyPendingQty from #Schedules S
inner join #RunningSchedules R on S.PumpModel=R.PumpModel AND s.PackagingType=R.PackagingType AND S.SDate=R.SDate and S.StationID=R.StationID
group by S.StationID,S.Sdate,S.Pumpmodel,S.PackagingType,R.MonthlyTotalScannedQty,R.MonthlyTotalTarget
--RESULT4

END
