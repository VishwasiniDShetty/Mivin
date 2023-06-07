/****** Object:  Procedure [dbo].[s_GetPackingEfficiencyReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[s_GetPackingEfficiencyReport_Mivin]  '','2020-08-01','2020-08-28','','','',''
CREATE PROCEDURE [dbo].[s_GetPackingEfficiencyReport_Mivin] 
	@StationID nvarchar(50),
	@Fromdate datetime,
	@Todate datetime,
	@Pumpmodel nvarchar(50)='',
	@Workorder nvarchar(50)='',
	@Shift nvarchar(50)='',
	@Param nvarchar(50) =''
AS  
BEGIN  

create table #Schedules
(
StationID nvarchar(50),
date datetime,
Shift nvarchar(50),
--Operator nvarchar(50),
WONumber nvarchar(50),
Customer nvarchar(50),
PumpModel nvarchar(50),
ShiftTarget float,
PackedQty float,
Efficiency float,
Remarks nvarchar(1000),
PendingQty int
)

--insert into #Schedules(date,Shift,Operator,WONumber,Customer,PumpModel,PackedQty)
--select S.date,S.Shift,S.Operator,S.WONumber,SD.CustomerName,S.PumpModel,count(S.Scannedqty) from ScannedDetails S
--inner join ScheduleDetails SD on S.PumpModel=SD.PumpModel
--where convert(nvarchar(10),S.date,120)>=@Fromdate and convert(nvarchar(10),S.date,120)<=@Todate
--and (S.PumpModel=@Pumpmodel or isnull(@Pumpmodel,'')='') and (S.WONumber=@Workorder or isnull(@Workorder,'')='')
--and (S.shift=@shift or isnull(@shift,'')='')
--group by  S.date,S.Shift,S.Operator,S.WONumber,SD.CustomerName,S.PumpModel
--order by S.date,S.shift


insert into #Schedules(StationID,date,Shift,WONumber,Customer,PumpModel,PackedQty)
select S.StationID,S.date,S.Shift,S.WONumber,SD.CustomerName,S.PumpModel,count(S.Scannedqty) from ScannedDetails S
inner join ScheduleDetails SD on S.PumpModel=SD.PumpModel and CONVERT(NVARCHAR(10),SD.DATE,120)=CONVERT(NVARCHAR(10),S.DATE,120) and S.PackagingType=SD.PackagingType
where convert(nvarchar(10),S.date,120)>=@Fromdate and convert(nvarchar(10),S.date,120)<=@Todate 
and (S.PumpModel=@Pumpmodel or isnull(@Pumpmodel,'')='') and (S.WONumber=@Workorder or isnull(@Workorder,'')='')
and (S.shift=@shift or isnull(@shift,'')='')
and (S.StationID=@StationID or isnull(@StationID,'')='')
group by  S.StationID,S.date,S.Shift,S.WONumber,SD.CustomerName,S.PumpModel
order by S.date,S.shift


--update #Schedules set  ShiftTarget=T.PackingTarget from
--(Select p.pumpmodeL,P.Date,P.Shift,sum(P.Target) AS PackingTarget from PumpwiseTargetMaster p
--INNER JOIN #Schedules s ON CONVERT(NVARCHAR(10),p.DATE,120)=CONVERT(NVARCHAR(10),s.DATE,120) AND p.Shift=s.Shift and p.PumpModel=S.PumpModel
--group by p.pumpmodeL,P.Date,P.Shift)T inner join #Schedules on T.PumpModel=#Schedules.PumpModel	and CONVERT(NVARCHAR(10),T.DATE,120)=CONVERT(NVARCHAR(10),#Schedules.DATE,120) 
--AND T.Shift=#Schedules.Shift

update #Schedules set  ShiftTarget=T.PackingTarget from
(Select P.StationID,P.Date,P.Shift,sum(P.Target) AS PackingTarget from ShiftwiseTargetMaster p
INNER JOIN #Schedules s ON CONVERT(NVARCHAR(10),p.DATE,120)=CONVERT(NVARCHAR(10),s.DATE,120) AND p.Shift=s.Shift and P.StationID=S.StationID
where (P.StationID=@StationID or isnull(@StationID,'')='')
group by P.StationID,P.Date,P.Shift)T inner join #Schedules on CONVERT(NVARCHAR(10),T.DATE,120)=CONVERT(NVARCHAR(10),#Schedules.DATE,120) 
AND T.Shift=#Schedules.Shift and T.StationID=#Schedules.StationID

update #Schedules set Efficiency=Round((PackedQty/ShiftTarget)*100,2) where ShiftTarget>0

update #Schedules set PendingQty=ISNULL(ShiftTarget,0)-ISNULL(PackedQty,0)

select * from #Schedules order by Date,shift

END
