/****** Object:  Procedure [dbo].[s_GetAndonDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

-- [dbo].[s_GetAndonDetails_Mivin] '2020-03-24 15:00:00'

CREATE PROCEDURE [dbo].[s_GetAndonDetails_Mivin] 
	@StationID nvarchar(50),
	@Starttime datetime
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
Priority int
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
TotalScannedQty int
)

create table #Efficiency
(
shifttarget float,
Shiftactual float,
Efficiency float
)


----RESULT1
insert into #RunningSchedules(StationID,SDate,WONumber,PumpModel,CustomerModel,QtyPerbox,WorkOrderStatus)
Select R.StationID,R.ScheduledDate,R.WONumber,R.PumpModel,R.CustomerModel,M.PerBoxPumpQty,S.WorkOrderStatus from RunningScheduleDetails R
inner join PumpMasterData M on M.PumpModel=R.PumpModel
inner join ScheduleDetails S on R.PumpModel=S.PumpModel and R.WONumber=S.WONumber and convert(nvarchar(10),S.Date,120)=convert(nvarchar(10),R.ScheduledDate,120) 
where R.StationID=@StationID


Declare @LastPrintTS as datetime

select @LastPrintTS=max(S1.ScannedTS) from ScannedDetails S1 inner join #RunningSchedules R on R.PumpModel=S1.PumpModel and R.WONumber=S1.WONumber and convert(nvarchar(10),S1.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120)  
where S1.ScannedOrForceCloseStatus=1 and S1.StationID=@StationID

If ISNULL(@LastPrintTS,'1900-01-01')<>'1900-01-01'
Begin
update #RunningSchedules set ScannedQty=ISNULL(T.qty,0) from
(select Count(S.ScannedQty) as qty from ScannedDetails S
inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.WONumber=S.WONumber and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120)  and S.StationID=R.StationID
where S.StationID=@StationID and ScannedTS>(select max(S1.ScannedTS) from ScannedDetails S1 inner join #RunningSchedules R on R.PumpModel=S1.PumpModel and R.WONumber=S1.WONumber and convert(nvarchar(10),S1.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and R.StationID=S1.StationID
where S1.ScannedOrForceCloseStatus=1 and S1.StationID=@StationID))T
END
Else
BEgin
update #RunningSchedules set ScannedQty=ISNULL(T.qty,0) from
(select Count(S.ScannedQty) as qty from ScannedDetails S
inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.WONumber=S.WONumber and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
Where S.StationID=@StationID
)T
END


update #RunningSchedules set LastScannedSlno=T.ScannedSlNo,operator=T.Operator from
(select ScannedSlNo,Operator from 
	 (select Max(ScannedTS) as ts from ScannedDetails S
	 inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.WONumber=S.WONumber and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
	 where S.StationID=@StationID
	 )t INNER JOIN ScannedDetails ON T.TS=ScannedDetails.ScannedTS
 )T

update #RunningSchedules set TotalScannedQty=ISNULL(T.qty,0) from
(select Count(S.ScannedQty) as qty from ScannedDetails S
inner join #RunningSchedules R on R.PumpModel=S.PumpModel and R.WONumber=S.WONumber  and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),R.SDate,120) and S.StationID=R.StationID
where S.StationID=@StationID
)T

select StationID,SDate,WONumber,PumpModel,CustomerModel,QtyPerbox,ScannedQty,operator,LastScannedSlno,WorkOrderStatus,TotalScannedQty from #RunningSchedules
----RESULT1


----RESULT2
INSERT INTO #ShiftDetails(dDate,Shift,Starttime,Endtime,Shiftid)
EXEC s_GetCurrentShiftTime @Starttime

insert into #Schedules(Sdate,WONumber,Customer,PumpModel,CustomerModel,PackingTarget,QtyPerbox,PackagingType,WorkOrderStatus,Priority)
select S.date,S.WONumber,S.CustomerName,S.PumpModel,S.CustomerModel,S.PumpQty,M.PerBoxPumpQty,S.PackagingType,S.WorkOrderStatus,S.WeekwisePriority from ScheduleDetails S
inner join PumpMasterData M on M.PumpModel=S.PumpModel where S.WorkOrderStatus<>'Completed' order by S.date

update #Schedules set  TotalScannedQty=ISNULL(T.TotalScannedQty,0) from
(Select S.StationID,S.ScheduledDate,S.pumpmodeL,S.WONumber,Count(S.ScannedQty) as TotalScannedQty from ScannedDetails S
INNER JOIN #Schedules s1 ON S.PumpModel=S1.PumpModel and S.WONumber=S1.WONumber and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),S1.Sdate,120) 
Where S.StationID=@StationID
group by S.StationID,S.pumpmodeL,S.WONumber,S.ScheduledDate)T inner join #Schedules on T.PumpModel=#Schedules.PumpModel	and T.WONumber=#Schedules.WONumber 
and convert(nvarchar(10),#Schedules.Sdate,120)=convert(nvarchar(10),T.ScheduledDate,120) 	

update #Schedules set  PackedBoxCount=ISNULL(T.PackedBoxCount,0) from
(Select S.StationID,S.ScheduledDate,S.pumpmodeL,S.WONumber,Count(*) as PackedBoxCount from ScannedDetails S
INNER JOIN #Schedules s1 ON S.PumpModel=S1.PumpModel and S.WONumber=S1.WONumber and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),S1.Sdate,120) 
where S.ScannedOrForceCloseStatus=1 and S.StationID=@StationID
group by S.StationID,S.pumpmodeL,S.WONumber,S.ScheduledDate)T inner join #Schedules on T.PumpModel=#Schedules.PumpModel	and T.WONumber=#Schedules.WONumber	
and convert(nvarchar(10),#Schedules.Sdate,120)=convert(nvarchar(10),T.ScheduledDate,120) 

select Sdate,WONumber,Customer,PumpModel,CustomerModel,PackingTarget,QtyPerbox,TotalScannedQty,PackedBoxCount,PackagingType,WorkOrderStatus,Priority from #Schedules
order by Sdate
----RESULT2

---RESULT3
Insert into #Efficiency(shifttarget,Shiftactual)
Select ISNULL(sum(target),0),0 from PumpwiseTargetMaster P
cross join #ShiftDetails  S where convert(nvarchar(10),P.date,120)=convert(nvarchar(10),S.dDate,120) and P.Shift=S.Shift and P.StationID=@StationID

update #Efficiency set Shiftactual=ISNULL(T.qty,0) from
(Select count(ScannedQty) as qty from ScannedDetails S 
cross join #ShiftDetails  SH where convert(nvarchar(10),S.date,120)=convert(nvarchar(10),SH.dDate,120) and S.Shift=SH.Shift and S.StationID=@StationID
)T

update #Efficiency set Efficiency=ISNULL((Shiftactual/shifttarget)*100,0) where shifttarget>0

select * from #Efficiency 
--RESULT3


END
