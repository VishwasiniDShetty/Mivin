/****** Object:  Procedure [dbo].[S_GetProcessInspectionReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_GetProcessInspectionReport_Mivin] 'Equator Phantom','','','2020-11-03 08:00:00','2020-11-04 08:00:00',''
exec S_GetProcessInspectionReport_Mivin @StartDate=N'2020-11-03 08:30:00',@EndDate=N'2020-11-04 08:30:00',@MachineId=N'Equator Phantom',@Shift=N''
Exec s_GetShiftTime '2020-11-04 00:00:00',''
*/
CREATE Procedure [dbo].[S_GetProcessInspectionReport_Mivin]
@MachineId nvarchar(50)='',
@Shift nvarchar(50)='',
@Type nvarchar(50)='',
@StartDate datetime='',
@EndDate datetime='',
@Param nvarchar(50)=''

AS
BEGIN

create table #Temp
(
	MachineId nvarchar(50),
	ComponentId nvarchar(50),
	Operation nvarchar(50),
	PartDescription nvarchar(50),
	CharacteristicId nvarchar(50),
	LSL float,
	USL float,
	TimeStamp datetime,
	ShiftDate DateTime,		
	Shiftname nvarchar(20),
	ShftSTtime DateTime,
	ShftEndTime DateTime,
	Value float,
	Operator nvarchar(50),
	InspectionType nvarchar(50),
	Remarks nvarchar(50),
)
CREATE TABLE #ShiftDefn
(
	ShiftDate DateTime,		
	Shiftname nvarchar(20),
	ShftSTtime DateTime,
	ShftEndTime DateTime	
)

DECLARE @StartTime datetime
set @StartTime = convert(nvarchar(10),@StartDate,120)

IF  isnull(@Shift,'')<> ''
BEGIN
	While @StartTime <= convert(nvarchar(10),@EndDate,120)
	begin
		INSERT INTO #ShiftDefn(ShiftDate,Shiftname,ShftSTtime,ShftEndTime)
		Exec s_GetShiftTime @StartTime,@Shift
		SELECT @StartTime=DATEADD(DAY,1,@StartTime)
	end
END
ELSE
BEGIN
	While @StartTime <= convert(nvarchar(10),@EndDate,120)
	begin
		INSERT INTO #ShiftDefn(ShiftDate,Shiftname,ShftSTtime,ShftEndTime)
		Exec s_GetShiftTime @StartTime,''
		SELECT @StartTime=DATEADD(DAY,1,@StartTime)
	end
END

INSERT INTO #Temp(MachineId,ComponentId,Operation,PartDescription,CharacteristicId,LSL,USL,ShiftDate,Shiftname,ShftSTtime,ShftEndTime)
select distinct T1.MachineID,T1.ComponentID,T1.OperationNo,T3.description,CharacteristicID,LSL,USL,ShiftDate,Shiftname,ShftSTtime,ShftEndTime from SPC_Characteristic T1
inner join componentinformation T3 on  T1.ComponentID=T3.componentid 
cross join #ShiftDefn T2
where T1.MachineID=@MachineId
 
update #Temp set Value=T1.Value, Operator=T1.Opr, InspectionType=T1.InspectionType, Remarks=T1.Remarks, TimeStamp=T1.Timestamp
from (
select A3.MachineId,A1.Comp,A1.Opn,A1.Dimension,A3.ShftSTtime,A1.Value,A1.Opr,A1.InspectionType,A1.Remarks,A1.Timestamp from SPCAutodata A1
inner join machineinformation A2 on A1.Mc=A2.interfaceid
inner join #Temp A3 on A3.MachineId=A2.MachineID and A3.ComponentId=A1.Comp and A1.Opn=A3.Operation and A1.Dimension=A3.CharacteristicId
and A1.Timestamp between A3.ShftSTtime and A3.ShftEndTime
Where (A1.InspectionType=@Type or ISNULL(@Type,'')='')
)T1 inner join #Temp T2 on T1.MachineId=T2.MachineId and T1.Comp=T2.ComponentId and T1.Opn=T2.Operation and T1.Dimension=T2.CharacteristicId 
and T1.ShftSTtime=T2.ShftSTtime

Update #Temp set Remarks=T1.Reason
from (
select A1.MachineId,A1.ComponentId,A1.Operation,A1.CharacteristicId,A1.TimeStamp,A1.InspectionType,A2.Reason
from #Temp A1 
inner join InspectionReason_Mivin A2 on A1.Remarks=A2.InterfaceID and A1.InspectionType=A2.InspectionType
)T1 inner join #Temp T2 on T1.MachineId=T2.MachineId and T1.ComponentId=T2.ComponentId and T1.Operation=T2.Operation and T1.CharacteristicId=T2.CharacteristicId 
and T1.TimeStamp=T2.TimeStamp and T1.InspectionType=T2.InspectionType

select MachineId,ComponentId,Operation,PartDescription,CharacteristicId,LSL,USL,Value,TimeStamp,convert(nvarchar(10),ShiftDate,120) as ShiftDate,Shiftname,Operator,InspectionType,Remarks from #Temp
where TimeStamp is not null
order by TimeStamp

END
