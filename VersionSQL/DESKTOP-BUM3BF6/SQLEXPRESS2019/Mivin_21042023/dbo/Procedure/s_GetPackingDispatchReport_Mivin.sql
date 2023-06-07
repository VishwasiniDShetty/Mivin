/****** Object:  Procedure [dbo].[s_GetPackingDispatchReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

-- [dbo].[s_GetPackingDispatchReport_Mivin]  '','2020-09-01','2020-09-08','','','',''

CREATE PROCEDURE [dbo].[s_GetPackingDispatchReport_Mivin] 
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
PumpModel nvarchar(50),
BoxtypeNo int,
PackedQty float,
PackagingType nvarchar(50),
Remarks nvarchar(1000)
)

insert into #Schedules(StationID,PumpModel,BoxtypeNo,PackedQty,PackagingType)
select S.StationID,S.PumpModel,M.PerBoxPumpQty,Count(S.Scannedqty),M.PackagingType from ScannedDetails S
inner join PumpMasterData M on S.PumpModel=M.PumpModel and S.PackagingType=M.PackagingType
--inner join ScheduleDetails SD on S.PumpModel=SD.PumpModel and S.PackagingType=M.PackagingType and convert(nvarchar(10),S.ScheduledDate,120)=convert(nvarchar(10),SD.Date,120) 
where convert(nvarchar(10),S.date,120)>=@Fromdate and convert(nvarchar(10),S.date,120)<=@Todate
and (S.PumpModel=@Pumpmodel or isnull(@Pumpmodel,'')='') and (S.WONumber=@Workorder or isnull(@Workorder,'')='')
and (S.shift=@shift or isnull(@shift,'')='')
and (S.StationID=@StationID or isnull(@StationID,'')='')
group by S.StationID,S.PumpModel,M.PerBoxPumpQty,M.PackagingType
order by S.PumpModel

select * from #Schedules order by PumpModel

END
