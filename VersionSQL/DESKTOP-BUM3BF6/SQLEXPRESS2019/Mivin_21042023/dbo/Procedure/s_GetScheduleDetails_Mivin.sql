/****** Object:  Procedure [dbo].[s_GetScheduleDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[s_GetScheduleDetails_Mivin] 
	@Startdate datetime
AS  
BEGIN  

create table #WeeklySchedules
(
PumpModel nvarchar(50),
Customer nvarchar(50),
PackagingType nvarchar(50),
MonthRequirement int,
CW1 int,
Cw2 int,
CW3 int,
CW4 int,
CW5 int
)

create table #Schedules
(
PumpModel nvarchar(50),
Customer nvarchar(50),
PackagingType nvarchar(50),
SDate int,
PumpQty int default 0,
WONumber nvarchar(50),
CustomerModel nvarchar(50)
)

create table #day
(
day int
)

declare @i as int
select @i=1
while @i<=31
Begin
	insert into #day(day)
	Select @i
	Select @i=@i+1
End


insert into #WeeklySchedules(PumpModel,PackagingType,Customer,MonthRequirement,CW1,Cw2,CW3,cw4,CW5)
Select distinct PumpModel, PackagingType, CustomerName, MonthRequirement, Week1Qty, Week2Qty, Week3Qty, Week4Qty, Week5Qty from MonthlyAndWeeklyScheduleDetails
where datepart(year,DATE)=datepart(year,@Startdate) and  datepart(month,DATE)=datepart(month,@Startdate)

insert into #Schedules(PumpModel,PackagingType,Customer,SDate,PumpQty,WONumber,CustomerModel)
select PumpModel,PackagingType,CustomerName,datepart(day,date),ISNULL(SUM(PumpQty),0),WONumber,CustomerModel from ScheduleDetails
where datepart(year,DATE)=datepart(year,@Startdate) and datepart(month,DATE)=datepart(month,@Startdate)
group by PumpModel,PackagingType,CustomerName,datepart(day,date),WONumber,CustomerModel


Declare @DynamicPivotQuery1 nvarchar(max)

Declare @SelectColumnName nvarchar(max)
SELECT @SelectColumnName= ISNULL(@SelectColumnName + ',','') 
+ QUOTENAME(day)
FROM (select distinct day from #day) AS BatchValues 

select @DynamicPivotQuery1=''
SET @DynamicPivotQuery1 = 
N'
SELECT PumpModel as PartNo,PackagingType as Type,Customer,WONumber,CustomerModel,MonthRequirement,CW1,CW2,CW3,CW4,CW5,' + @SelectColumnName + ' 
FROM (select S.PumpModel,S.PackagingType,S.Customer,S.SDate,ISNULL(S.PumpQty,''0'') as PumpQty,S.WONumber,S.CustomerModel,W.MonthRequirement,W.CW1,W.Cw2,W.CW3,W.cw4,W.CW5
from #schedules S inner join #WeeklySchedules W on S.PumpModel=W.PumpModel and S.PackagingType=W.PackagingType and S.customer=W.customer
)as s 
PIVOT (SUM(PumpQty)
FOR [SDate] IN (' + @SelectColumnName + ' )) AS PVTTable2
order by PumpModel'

EXEC sp_executesql @DynamicPivotQuery1

END
