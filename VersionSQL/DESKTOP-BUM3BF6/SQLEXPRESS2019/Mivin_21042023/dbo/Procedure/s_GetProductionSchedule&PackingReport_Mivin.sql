/****** Object:  Procedure [dbo].[s_GetProductionSchedule&PackingReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[s_GetProductionSchedule&PackingReport_Mivin] '2020-03-25 00:00:00'
*/

CREATE PROCEDURE [dbo].[s_GetProductionSchedule&PackingReport_Mivin] 
	@Startdate datetime
AS  
BEGIN  

create table #WeeklySchedules
(
PumpModel nvarchar(50),
CustomerName nvarchar(50),
CustomerModel nvarchar(50),
PackagingType nvarchar(50),
MonthRequirement int,
ActualPackedQty int,
PendingForPacking int,
ActualDispatch int,
CW1 int,
CW2 int,
CW3 int,
CW4 int,
CW5 int,
CW1Actual int,
Cw2Actual int,
CW3Actual int,
CW4Actual int,
CW5Actual int
)


insert into #WeeklySchedules(PumpModel,PackagingType,CustomerName,CustomerModel,MonthRequirement,CW1,Cw2,CW3,cw4,cw5,CW1Actual,Cw2Actual,CW3Actual,CW4Actual,CW5Actual,ActualPackedQty,PendingForPacking)
Select distinct PumpModel, PackagingType, CustomerName, CustomerModel, 0, 0, 0, 0, 0,0,0,0,0,0,0,0,0 from PumpMasterData

update #WeeklySchedules set CW1=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(SUM(PumpQty),0) as PumpQty from ScheduleDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and 
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '01') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '08')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType

update #WeeklySchedules set CW2=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(SUM(PumpQty),0) as PumpQty from ScheduleDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '08') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '15')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 

update #WeeklySchedules set CW3=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(SUM(PumpQty),0) as PumpQty from ScheduleDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '15') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '22')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 

update #WeeklySchedules set CW4=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(SUM(PumpQty),0) as PumpQty from ScheduleDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '22') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 

IF datepart(Month,@Startdate)=1 or datepart(Month,@Startdate)=3 or datepart(Month,@Startdate)=5  or datepart(Month,@Startdate)=7  or datepart(Month,@Startdate)=8  or datepart(Month,@Startdate)=10 or datepart(Month,@Startdate)=12 
Begin
update #WeeklySchedules set CW5=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(SUM(PumpQty),0) as PumpQty from ScheduleDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29') and Date<=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '31')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType
End

IF datepart(Month,@Startdate)=2 
Begin
update #WeeklySchedules set CW5=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(SUM(PumpQty),0) as PumpQty from ScheduleDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 
End

IF datepart(Month,@Startdate)=4 or datepart(Month,@Startdate)=6 or datepart(Month,@Startdate)=9  or datepart(Month,@Startdate)=11
Begin
update #WeeklySchedules set CW5=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(SUM(PumpQty),0) as PumpQty from ScheduleDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29') and Date<=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '30')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType
End


update #WeeklySchedules set CW1Actual=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(count(ScannedQty),0) as PumpQty from ScannedDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and 
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '01') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '08')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 

update #WeeklySchedules set Cw2Actual=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(count(ScannedQty),0) as PumpQty from ScannedDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '08') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '15')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 

update #WeeklySchedules set CW3Actual=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(count(ScannedQty),0) as PumpQty from ScannedDetails S
where datepart(month,DATE)=datepart(month,@Startdate) 
and Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '15') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '22')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType and S.CustomerModel=W.CustomerModel


update #WeeklySchedules set CW4Actual=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(count(ScannedQty),0) as PumpQty from ScannedDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '22') and Date<(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 


IF datepart(Month,@Startdate)=1 or datepart(Month,@Startdate)=3 or datepart(Month,@Startdate)=5  or datepart(Month,@Startdate)=7  or datepart(Month,@Startdate)=8  or datepart(Month,@Startdate)=10 or datepart(Month,@Startdate)=12 
Begin
update #WeeklySchedules set CW5Actual=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(count(ScannedQty),0) as PumpQty from ScannedDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29') and Date<=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '31')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 
End

IF datepart(Month,@Startdate)=2 
Begin
update #WeeklySchedules set CW5Actual=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(count(ScannedQty),0) as PumpQty from ScannedDetails S 
where datepart(month,DATE)=datepart(month,@Startdate) and
Date=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 
End

IF datepart(Month,@Startdate)=4 or datepart(Month,@Startdate)=6 or datepart(Month,@Startdate)=9  or datepart(Month,@Startdate)=11
Begin
update #WeeklySchedules set CW5Actual=ISNULL(S.PumpQty,0) from(
select S.PumpModel,S.PackagingType,S.CustomerModel,ISNULL(count(ScannedQty),0) as PumpQty from ScannedDetails S
where datepart(month,DATE)=datepart(month,@Startdate) and
Date>=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '29') and Date<=(cast(datepart(Year,@Startdate)as nvarchar) + '-' + cast(datepart(Month,@Startdate) as nvarchar)+ '-' + '30')
group by S.PumpModel,S.PackagingType,S.CustomerModel
)S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType 
End

update #WeeklySchedules set ActualPackedQty=ISNULL(CW1Actual,0)+ISNULL(Cw2Actual,0)+ISNULL(Cw3Actual,0)+ISNULL(Cw4Actual,0)+ISNULL(Cw5Actual,0)

update #WeeklySchedules set MonthRequirement=ISNULL(CW1,0)+ISNULL(CW2,0)+ISNULL(CW3,0)+ISNULL(CW4,0)+ISNULL(CW5,0)

update #WeeklySchedules set PendingForPacking=case when MonthRequirement>0 and (MonthRequirement-ActualPackedQty)>0 then MonthRequirement-ActualPackedQty else 0 end

select * from #WeeklySchedules

END
