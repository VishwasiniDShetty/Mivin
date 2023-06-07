/****** Object:  Procedure [dbo].[S_Get_PumpSlNoProductionDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
exec [dbo].[S_Get_PumpSlNoProductionDetails_Mivin] @PumpModel=N'0510725464',@SlNo=N'280287801',@param=N'Screen2'
[dbo].[S_Get_PumpSlNoProductionDetails_Mivin] '2022-02-01 11:35:48.000','2022-02-10 18:13:52.000','R983106269','238228138','screen1'
[dbo].[S_Get_PumpSlNoProductionDetails_Mivin] '2022-02-01 11:35:48.000','2022-02-10 18:13:52.000','R983106269','238228138','screen1'
[dbo].[S_Get_PumpSlNoProductionDetails_Mivin] '2022-02-01 11:35:48.000','2022-02-10 18:13:52.000','R983106269','238228185','screen1'
*/
CREATE procedure [dbo].[S_Get_PumpSlNoProductionDetails_Mivin]
@Startdate datetime='',
@EndDate datetime='',
@PumpModel nvarchar(50)='',
@SlNo nvarchar(50)='',
@Machineid nvarchar(50)='',
@operator nvarchar(50)='',
@operationno nvarchar(50)='',
@CycleStart nvarchar(50)='',
@pumpab nvarchar(50)='',
@pumptype nvarchar(50)='',
@ReworkNo int =0,
@ReCheckNo int=0,
@param nvarchar(50)=''
as
begin

declare @starttime datetime
declare @endtime datetime
select @starttime= dbo.f_GetLogicalDay(@Startdate,'Start')
select @endtime=dbo.f_GetLogicalDay(@EndDate,'End')
declare @strtime nvarchar(300)
declare @strslno nvarchar(50)
declare @strpumpmodel nvarchar(50)
declare @strsql nvarchar(500)

select @strtime=''
select @strslno=''
select @strpumpmodel=''
select @strsql=''

if @PumpModel<>''
begin
set @strpumpmodel= ' and pumpmodel='''+@PumpModel+''' '
end

if (@Startdate<>'' and @EndDate<>'')
begin
set @strtime= ' and (MeasuredDatetime>='''+convert(nvarchar(20),@Startdate)+''' and MeasuredDatetime<='''+convert(nvarchar(20),@EndDate)+''') '
end

if (@SlNo<>'')
begin
set @strslno=' and slno like '''+'%'+@SlNo+'%'+''' '
end

create table #shift
(
ShiftDate DateTime,		
Shiftname nvarchar(20),
ShiftID NVARCHAR(50),
ShftSTtime DateTime,
ShftEndTime DateTime
)

create table #test
(
	[ID] [bigint] ,
	[MachineID] [nvarchar](50) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpType] [nvarchar](50) NOT NULL,
	[RotationalType] [nvarchar](50) NULL,
	[SlNo] [nvarchar](50) NOT NULL,
	[Event] [nvarchar](50) NOT NULL,
	[CycleStart] [datetime] NOT NULL,
	[MeasuredDatetime] [datetime] NOT NULL,
	[OperationNo] [int] NULL,
	[Operator] [nvarchar](50) NULL,
	[FlowVal] [float] NULL,
	[TempVal] [float] NULL,
	[PressureVal] [float] NULL,
	[RPMVal] [float] NULL,
	[FlowLSL] [float] NULL,
	[FlowUSL] [float] NULL,
	[TempLSL] [float] NULL,
	[TempUSL] [float] NULL,
	[PressureLSL] [float] NULL,
	[PressureUSL] [float] NULL,
	[RPMLSL] [float] NULL,
	[RPMUSL] [float] NULL,
	[ReCheckNo] [int] NULL,
	[ReWorkNo] [int] NULL,
	[IsMasterPump] [bit] NULL,
	[UpdatedTS] [datetime] NULL,
	[PumpAB] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[TorqueVal] [float] NULL,
	[TorqueMin] [float] NULL,
	[TorqueMax] [float] NULL,
	[ModelType] [nvarchar](50) NULL,
)

create table #Output2
(
	[ID] [bigint] ,
	[MachineID] [nvarchar](50) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpType] [nvarchar](50) NOT NULL,
	[RotationalType] [nvarchar](50) NULL,
	[SlNo] [nvarchar](50) NOT NULL,
	[Event] [nvarchar](50) NOT NULL,
	[CycleStart] [datetime] NOT NULL,
	[MeasuredDatetime] [datetime] NOT NULL,
	[OperationNo] [int] NULL,
	[Operator] [nvarchar](50) NULL,
	[FlowVal] [float] NULL,
	[TempVal] [float] NULL,
	[PressureVal] [float] NULL,
	[RPMVal] [float] NULL,
	[FlowLSL] [float] NULL,
	[FlowUSL] [float] NULL,
	[TempLSL] [float] NULL,
	[TempUSL] [float] NULL,
	[PressureLSL] [float] NULL,
	[PressureUSL] [float] NULL,
	[RPMLSL] [float] NULL,
	[RPMUSL] [float] NULL,
	[ReCheckNo] [int] NULL,
	[ReWorkNo] [int] NULL,
	[IsMasterPump] [bit] NULL,
	[UpdatedTS] [datetime] NULL,
	[PumpAB] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[TorqueVal] [float] NULL,
	[TorqueMin] [float] NULL,
	[TorqueMax] [float] NULL,
	[ModelType] [nvarchar](50) NULL,
)


CREATE TABLE #Test2
(
	Machineid NVARCHAR(50),
	Date datetime,
	Shift nvarchar(50),
	PumpModel NVARCHAR(50),
	operationno nvarchar(50),
	operator nvarchar(50),
	Slno NVARCHAR(50),
	PumpType NVARCHAR(50),
	Event NVARCHAR(50),
	CycleStart DATETIME,
	MeasuredDatetime DATETIME,
	[RotationalType] [nvarchar](50) NULL,
	Flowval FLOAT default 0,
	TempVal FLOAT default 0,
	PressureVal FLOAT default 0,
	RpmVal FLOAT default 0,
	flowlsl FLOAT default 0,
	flowusl FLOAT default 0,
	Templsl FLOAT default 0,
	Tempusl FLOAT default 0,
	pressurelsl FLOAT default 0,
	pressureusl FLOAT default 0,
	rpmlsl FLOAT default 0,
	rpmusl FLOAT default 0,
	ismasterpump bit,
	pumpab NVARCHAR(50),
	status NVARCHAR(50),
	DeliveryValue float default 0,
	PressureValue float default 0,
	ReworkNo int default 0,
	RecheckNo int default 0,
	TimeInterval float default 0,
	[TorqueVal] [float] NULL,
	[TorqueMin] [float] NULL,
	[TorqueMax] [float] NULL,
	[ModelType] [nvarchar](50) NULL,
)

CREATE TABLE #Test1
(
Machineid NVARCHAR(50),
Date datetime,
Shift nvarchar(50),
PumpModel NVARCHAR(50),
operationno nvarchar(50),
operator nvarchar(50),
Slno NVARCHAR(50),
PumpType NVARCHAR(50),
PumpCategory nvarchar(50),
Event NVARCHAR(50),
CycleStart DATETIME,
[RotationalType] [nvarchar](50) NULL,
MeasuredDatetime DATETIME,
Flowval FLOAT default 0,
TempVal FLOAT default 0,
PressureVal FLOAT default 0,
RpmVal FLOAT default 0,
flowlsl FLOAT default 0,
flowusl FLOAT default 0,
Templsl FLOAT default 0,
Tempusl FLOAT default 0,
pressurelsl FLOAT default 0,
pressureusl FLOAT default 0,
rpmlsl FLOAT default 0,
rpmusl FLOAT default 0,
ismasterpump bit,
pumpab NVARCHAR(50),
status NVARCHAR(50),
DeliveryValue float default 0,
PressureValue float default 0,
ReworkNo int default 0,
RecheckNo int default 0,
[TorqueVal] [float] NULL,
[TorqueMin] [float] NULL,
[TorqueMax] [float] NULL,
[ModelType] [nvarchar](50) NULL
)

if @param='Screen1'
begin
print'Screen1'
DECLARE @start DATETIME
DECLARE @End DATETIME


select @strsql=''
select @strsql=@strsql+'insert into #test '
select @strsql=@strsql+'select * from PumpTestData_Mivin where 1=1 and event=''T4'' '
select @strsql=@strsql+ @strpumpmodel+@strslno+@strtime
print @strsql
exec(@strsql)

insert into #Test1(Machineid,CycleStart,PumpModel,PumpType,pumpab,Slno,Event,Flowval,TempVal,PressureVal,RpmVal,status,MeasuredDatetime,ismasterpump,
ReworkNo,RecheckNo,operationno,operator,TorqueMin,TorqueMax,TorqueVal,RotationalType,ModelType)
select distinct p1.MachineID,p1.CycleStart,p1.pumpmodel,p1.pumptype,p1.PumpAB,p1.slno,p1.event,
p1.FlowVal,p1.TempVal,p1.PressureVal,p1.RPMVal,p1.status,p1.MeasuredDatetime,
p1.IsMasterPump,p1.ReWorkNo,p1.ReCheckNo,p1.OperationNo,p1.Operator,p1.TorqueMin,p1.TorqueMax,p1.TorqueVal,p1.RotationalType,p1.ModelType from #test p1
inner join(select machineid,PumpModel,OperationNo,PumpType,PumpAB,SlNo,event,cyclestart as Cyclestart,MAX(MeasuredDatetime) AS MeasuredDatetime  from #test 
group by machineid,PumpModel,OperationNo,PumpType,PumpAB,SlNo,Event,CycleStart)t on t.MachineID=p1.MachineID and t.PumpModel=p1.PumpModel and t.PumpType=p1.PumpType 
and t.PumpAB=p1.PumpAB and t.SlNo=p1.SlNo and t.Event=p1.Event and t.Cyclestart=p1.CycleStart  AND T.MeasuredDatetime=P1.MeasuredDatetime
order by p1.MeasuredDatetime,PumpAB asc

UPDATE #Test1 SET pumpcategory=t1.pumpcategory
FROM
(
SELECT MachineID,t.PumpModel,t.PumpType,t.Event,p.PumpCategory,SlNo,CycleStart,MeasuredDatetime,FlowVal,TempVal,PressureVal,RPMVal,IsMasterPump,PumpAB,Status,Operator FROM #Test1 t
inner join PumpModelMaster_Mivin p on p.PumpModel=t.PumpModel and p.PumpType=t.PumpType
)t1 INNER JOIN #Test1 ON t1.MachineID=#Test1.Machineid and  t1.PumpModel=#Test1.PumpModel AND t1.SlNo=#test1.Slno AND t1.PumpType=#Test1.PumpType and t1.PumpAB=#Test1.pumpab AND t1.Event=#Test1.Event AND t1.MeasuredDatetime=#test1.MeasuredDatetime


update #Test1 set flowlsl=t1.lsl,flowusl=t1.usl
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='flow' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event

update #Test1 set Templsl=t1.lsl,Tempusl=t1.usl
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='Temperature' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event


update #Test1 set pressurelsl=t1.lsl,pressureusl=t1.usl
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='Pressure' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event

update #Test1 set rpmlsl=t1.lsl,rpmusl=t1.usl
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='RPM' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event



SELECT @starttime=(select min(measureddatetime) from #Test1)
SELECT @endtime=(select max(measureddatetime) from #Test1)

select @start= dbo.f_GetLogicalDay(@starttime,'Start')
select @End=dbo.f_GetLogicalDay(@endtime,'End')

while cast(@start as date)<=cast(@end as date)
begin
INSERT INTO #shift(ShiftDate,Shiftname,ShftSTtime,ShftEndTime)
		Exec s_GetShiftTime @start,''
		SELECT @Start = DATEADD(DAY,1,@start)
end

Update #shift Set shiftid = isnull(#shift.Shiftid,0) + isnull(T1.shiftid,0) from
(Select SD.shiftid ,SD.shiftname from shiftdetails SD
inner join #shift S on SD.shiftname=S.shiftname where
running=1 )T1 inner join #shift on  T1.shiftname=#shift.shiftname



select distinct Machineid,PumpModel,cast(MeasuredDatetime as date) as Date,s.shiftid,s.shiftname,Event,e.Employeeid,e.Name,t1.operator,t1.operationno,PumpType,pumpab,PumpCategory,
CycleStart,MeasuredDatetime as MeasuredTime,
RpmVal as RpmActual,rpmlsl as RpmMinSpec, rpmusl as Rpmmaxspec,
TempVal as TempActual,Templsl as TempMinSpec,Tempusl as TempMaxSpec,
PressureVal as PressureActual,pressurelsl as pressureMinSpec,pressureusl as pressurMaxSpec,
Flowval as flowactual,flowlsl  as flowMinspec,flowusl as FlowMaxSpec,
case when ReworkNo>0 then  (t1.SlNo+'_'+CAST(t1.ReworkNo AS NVARCHAR(10))) else Slno end as slno,
RecheckNo,ReworkNo,
--Flowval,TempVal,PressureVal,RpmVal,
case when (t1.status)='ok' then 'Pass' when (t1.status)='Not Ok' then 'Fail' else '' end Result
,case when (cast(ReworkNo as nvarchar(50))<>'0' and cast(recheckno as nvarchar(50))='0') then 'Rework' when (cast(RecheckNo as nvarchar(50))<>'0' and cast(reworkno as nvarchar(50))='0') then 'ReCheck'
when (cast(RecheckNo as nvarchar(50))<>'0' and cast(RecheckNo as nvarchar(50))<>'0') then 'RecheckAndRework'  else '' end as Rework_ReCheckStatus,
TorqueMin,TorqueMax,TorqueVal,RotationalType,ModelType
from #test1 t1
cross join #shift s
left outer join employeeinformation e on e.interfaceid=t1.operator
where MeasuredDatetime>=ShftSTtime and MeasuredDatetime<=ShftEndTime
order by Machineid,MeasuredTime asc

end

if @param='Screen2'
begin
declare @serialNo nvarchar(50)
select @serialNo=case when CHARINDEX('_', @SlNo)>0 then SUBSTRING(@SlNo,1,CHARINDEX('_',@SlNo) - 1) else @SlNo end

insert into #Output2
select * from  dbo.PumpTestData_Mivin p1 WHERE MachineID=@Machineid and  PumpModel=@PumpModel and OperationNo=@operationno and Operator=@operator and PumpAB=@pumpab and PumpType=@pumptype
and CycleStart=@CycleStart and SlNo=@serialNo and ReWorkNo=@ReworkNo and ReCheckNo=@ReCheckNo 


insert into #Test2(Machineid,CycleStart,PumpModel,PumpType,pumpab,Slno,Event,Flowval,TempVal,PressureVal,RpmVal,status,MeasuredDatetime,ismasterpump,
ReworkNo,RecheckNo,operationno,operator,TorqueMin,TorqueMax,TorqueVal,RotationalType,ModelType)
select distinct p1.MachineID,p1.CycleStart,p1.pumpmodel,p1.pumptype,p1.PumpAB,p1.slno,p1.event,
p1.FlowVal,p1.TempVal,p1.PressureVal,p1.RPMVal,p1.status,p1.MeasuredDatetime,
p1.IsMasterPump,p1.ReWorkNo,p1.ReCheckNo,p1.OperationNo,p1.Operator,p1.TorqueMin,p1.TorqueMax,p1.TorqueVal,p1.RotationalType,p1.ModelType from #Output2 p1
inner join(select machineid,PumpModel,OperationNo,PumpType,PumpAB,SlNo,event,cyclestart as Cyclestart,MAX(MeasuredDatetime) AS MeasuredDatetime  from #Output2 
group by machineid,PumpModel,OperationNo,PumpType,PumpAB,SlNo,Event,CycleStart)t on t.MachineID=p1.MachineID and t.PumpModel=p1.PumpModel and t.PumpType=p1.PumpType 
and t.PumpAB=p1.PumpAB and t.SlNo=p1.SlNo and t.Event=p1.Event and t.Cyclestart=p1.CycleStart AND T.MeasuredDatetime=P1.MeasuredDatetime
order by p1.MeasuredDatetime,PumpAB asc

update #Test2 set TimeInterval=isnull(t.TimeIntervalVal1,0)
from
(
select distinct t1.PumpModel,t1.PumpType,TimeIntervalVal1 from #Test2 t1
inner join PumpModelMaster_Mivin p1 on p1.PumpModel=t1.PumpModel and p1.PumpType=t1.PumpType
)t inner join #Test2 on #Test2.PumpModel=t.pumpmodel and #Test2.PumpType=t.PumpType and #Test2.Event='t1'

update #Test2 set TimeInterval=isnull(t.TimeIntervalVal2,0)
from
(
select distinct t1.PumpModel,t1.PumpType,TimeIntervalVal2 from #Test2 t1
inner join PumpModelMaster_Mivin p1 on p1.PumpModel=t1.PumpModel and p1.PumpType=t1.PumpType
)t inner join #Test2 on #Test2.PumpModel=t.pumpmodel and #Test2.PumpType=t.PumpType and #Test2.Event='t2'

update #Test2 set TimeInterval=isnull(t.TimeIntervalVal3,0)
from
(
select distinct t1.PumpModel,t1.PumpType,TimeIntervalVal3 from #Test2 t1
inner join PumpModelMaster_Mivin p1 on p1.PumpModel=t1.PumpModel and p1.PumpType=t1.PumpType
)t inner join #Test2 on #Test2.PumpModel=t.pumpmodel and #Test2.PumpType=t.PumpType and #Test2.Event='t3'

update #Test2 set TimeInterval=isnull(t.TimeIntervalVal4,0)
from
(
select distinct t1.PumpModel,t1.PumpType,TimeIntervalVal4 from #Test2 t1
inner join PumpModelMaster_Mivin p1 on p1.PumpModel=t1.PumpModel and p1.PumpType=t1.PumpType
)t inner join #Test2 on #Test2.PumpModel=t.pumpmodel and #Test2.PumpType=t.PumpType and #Test2.Event='t4'

update #Test2 set TimeInterval=isnull(t.TimeIntervalVal5,0)
from
(
select distinct t1.PumpModel,t1.PumpType,TimeIntervalVal5 from #Test2 t1
inner join PumpModelMaster_Mivin p1 on p1.PumpModel=t1.PumpModel and p1.PumpType=t1.PumpType
)t inner join #Test2 on #Test2.PumpModel=t.pumpmodel and #Test2.PumpType=t.PumpType and #Test2.Event='t5'


select distinct Machineid,PumpModel,t1.Event,TimeInterval,e.Employeeid,e.Name,t1.operator,t1.operationno,PumpType,pumpab,Slno,RecheckNo,ReworkNo,Flowval,TempVal,PressureVal,RpmVal,CycleStart,MeasuredDatetime,
case when ReworkNo>0 then  (t1.SlNo+'_'+CAST(t1.ReworkNo AS NVARCHAR(10))) else Slno end as serialNumber,
case when (t1.status)='ok' then 'Pass' when (t1.status)='Not Ok' then 'Fail' else '' end Result,TorqueMin,TorqueMax,TorqueVal,RotationalType,ModelType
from #Test2 t1
left outer join employeeinformation e on e.interfaceid=t1.operator
order by Event ASC
RETURN



end


end
