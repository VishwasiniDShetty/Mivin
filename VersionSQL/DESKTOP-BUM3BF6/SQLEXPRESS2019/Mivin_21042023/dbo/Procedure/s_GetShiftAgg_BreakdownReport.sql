/****** Object:  Procedure [dbo].[s_GetShiftAgg_BreakdownReport]    Committed by VersionSQL https://www.versionsql.com ******/

/*******************************************************************************************************
--Created by Mrudula Rao 02/dec/2006
--Procedure to get breakdown report from shift aggregated data
mod 1 :- ER0182 By Kusuma M.H on 18-May-2009. Modify all the procedures to support unicode characters. Qualify with leading N.
Note:For ER0181 No component operation qualification found.
mod 2 :- DR0185 By Kusuma M.H on 25-May-2009. Increased the length of column downdescription from 50 to 100.
ER0317 - SwathiKS - 19/Dec/2011 :: To Calculate Setup Efficiency based on downid 'SETUP' or 'SETTING'.
********************************************************************************************************/
CREATE    procedure [dbo].[s_GetShiftAgg_BreakdownReport]
	@StartTime datetime,
	@EndTime datetime,
	@MachineID nvarchar(50)= '',
	@DownID varchar(8000)='',
	@PlantID Nvarchar(50)='',
	@Exclude int
AS
BEGIN
---mod 1
---To support unicode characters replaced varchar with nvarchar.
--DECLARE @strsql varchar(8000)
DECLARE @strsql nvarchar(4000)
--mod 1
DECLARE @strmachine nvarchar(200)
DECLARE @StrDownId NVARCHAR(200)
DECLARE @StrPlantID NVARCHAR(200)
DECLARE @timeformat NVARCHAR(12)
create table #TempBreakDownDataAgg
(
StartTime datetime,
EndTime datetime,
machineid nvarchar(50),
componentid nvarchar(50),
OperationNo integer,
OperatorName nvarchar(50),
downid nvarchar(50),
---mod 2
--DownDescription nvarchar(50),
DownDescription nvarchar(100),
---mod 2
downtime float,
McDowntime float,
id bigint primary key,
StdSetup float,
SetupEff float
)
SELECT  @strsql=''
SELECT @strmachine=''
SELECT @StrDownId=''
SELECT @StrPlantID=''
if isnull(@PlantID,'')<>''
begin
---mod 1
--select @StrPlantID=' AND (SD.PlantID ='''+@PlantID+''')'
select @StrPlantID=' AND (SD.PlantID =N'''+@PlantID+''')'
---mod 1
end
if isnull(@MachineID,'')<>''
begin
---mod 1
--select @strmachine=' AND (SD.machineid ='''+@MachineID+''')'
select @strmachine=' AND (SD.machineid =N'''+@MachineID+''')'
---mod 1
end
IF ISNULL(@DownID,'')<>'' and @Exclude=0
BEGIN
SELECT @StrDownId=' AND (SD.Downid in ('+@DownID+' ))'
END
IF ISNULL(@DownID,'')<>'' and @Exclude=1
BEGIN
SELECT @StrDownId=' AND (SD.Downid not in ('+@DownID+' ))'
END
Select @timeformat ='ss'
Select @timeformat = isnull((Select valueintext from cockpitdefaults where parameter='timeformat'),'ss')
if (@timeformat <>'hh:mm:ss' and @timeformat <>'hh' and @timeformat <>'mm'and @timeformat <>'ss')
Begin
Select @timeformat = 'ss'
End
Select @strsql = 'insert into #TempBreakDownDataAgg(StartTime,EndTime,MachineID,ComponentID,OperationNo,'
select @strsql = @strsql+'OperatorName,DownID,DownDescription,DownTime,McDowntime,StdSetup,SetupEff,ID) '
select @strsql = @strsql+ ' select SD.StartTime,SD.EndTime,SD.MachineID,SD.ComponentID,SD.OperationNo,'
select @strsql = @strsql+ 'SD.OperatorID,SD.DownID,downcodeinformation.downdescription,SD.DownTime,0,SD.StdSetupTime,0,SD.ID '
select @strsql = @strsql+' From ShiftDownTimeDetails SD INNER JOIN downcodeinformation ON SD.DownID=downcodeinformation.DownID where StartTime>=''' + convert(nvarchar(20),@StartTime)+ ''' '
select @strsql = @strsql+' and EndTime<=''' +convert(nvarchar(20),@EndTime)+ ''' '
select @strsql = @strsql+ @StrPlantID+ @strmachine+ @StrDownId
select @strsql = @strsql+' order by SD.EndTime'
print @strsql
exec (@strsql)
--select * from #TempBreakDownDataAgg
												
--total Downtime by machine
update #TempBreakDownDataAgg set McDowntime=isnull(McDowntime,0)+ isnull(t2.down,0)
	from (select machineid,sum(downtime) as down from #TempBreakDownDataAgg group by machineid) as t2 inner join
	#TempBreakDownDataAgg on t2.machineid=#TempBreakDownDataAgg.machineid
--Query to calculate Seup Efficiency
--Update #TempBreakDownDataAgg set SetupEff=isnull((StdSetup/isnull(downtime,0)),0)*100  where Downid='SETUP' and downtime<>0 --ER0317 commented
Update #TempBreakDownDataAgg set SetupEff=isnull((StdSetup/isnull(downtime,0)),0)*100  where (Downid='SETUP' OR Downid='SETTING') and downtime<>0 --ER0317 Added
---output
select @strsql=''
select @strsql='select StartTime,EndTime,MachineID,ComponentID,OperationNo,OperatorName,DownID,DownDescription, '
if (@TimeFormat = 'hh:mm:ss'or @TimeFormat = 'hh' or @TimeFormat = 'mm' or @TimeFormat = 'ss' )
begin	
	SELECT @strsql =  @strsql  +'dbo.f_FormatTime(DownTime,''' + @TimeFormat + ''') as DownTime , '
	SELECT @strsql =  @strsql  +'dbo.f_FormatTime(McDownTime,''' + @TimeFormat + ''') as McDownTime , '
	SELECT @strsql =  @strsql  +'dbo.f_FormatTime(StdSetup,''' + @TimeFormat + ''') as StdSetup , '
end
SELECT @strsql =  @strsql  + 'SetupEff From #TempBreakDownDataAgg order by EndTime'
exec (@strsql)
END
