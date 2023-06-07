/****** Object:  Procedure [dbo].[S_Get_ProductionData_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure [dbo].[S_Get_ProductionData_Mivin]
@StartTime datetime='',
@EndTime datetime='',
@Machineid nvarchar(50)='',
@PumpModel nvarchar(50)='',
@operator nvarchar(50)='',
@operationno nvarchar(50)='',
@CycleStart nvarchar(50)='',
@SlNo nvarchar(50)='',
@pumpab nvarchar(50)='',
@pumptype nvarchar(50)='',
@ReworkNo int =0,
@ReCheckNo int=0,
@param nvarchar(50)=''
as
begin


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
Event NVARCHAR(50),
CycleStart DATETIME,
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
RecheckNo int default 0
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
TimeInterval float default 0
)


if @param='Screen1'
begin
insert into #test
select * FROM dbo.PumpTestData_Mivin p1 WHERE p1.MachineID=@Machineid and  p1.MeasuredDatetime>=@starttime and p1.MeasuredDatetime<=@endtime and p1.Event='T4'


insert into #Test1(Machineid,CycleStart,PumpModel,PumpType,pumpab,Slno,Event,Flowval,TempVal,PressureVal,RpmVal,status,MeasuredDatetime,ismasterpump,ReworkNo,RecheckNo,operationno,operator)
select distinct p1.MachineID,p1.CycleStart,p1.pumpmodel,p1.pumptype,p1.PumpAB,p1.slno,p1.event,
p1.FlowVal,p1.TempVal,p1.PressureVal,p1.RPMVal,p1.status,p1.MeasuredDatetime,
p1.IsMasterPump,p1.ReWorkNo,p1.ReCheckNo,p1.OperationNo,p1.Operator from #test p1
inner join(select machineid,PumpModel,OperationNo,PumpType,PumpAB,SlNo,event,cyclestart as Cyclestart,MAX(MeasuredDatetime) AS MeasuredDatetime  from #test 
group by machineid,PumpModel,OperationNo,PumpType,PumpAB,SlNo,Event,CycleStart)t on t.MachineID=p1.MachineID and t.PumpModel=p1.PumpModel and t.PumpType=p1.PumpType 
and t.PumpAB=p1.PumpAB and t.SlNo=p1.SlNo and t.Event=p1.Event and t.Cyclestart=p1.CycleStart  AND T.MeasuredDatetime=P1.MeasuredDatetime
order by p1.MeasuredDatetime,PumpAB asc

select distinct Machineid,PumpModel,e.Employeeid,e.Name,t1.operator,t1.operationno,PumpType,pumpab,Slno,ReworkNo,RecheckNo,Flowval,TempVal,PressureVal,RpmVal,CycleStart,MeasuredDatetime,
case when (t1.status)='ok' then 'Pass' when (t1.status)='Not Ok' then 'Fail' else '' end Result from #test1 t1
left outer join employeeinformation e on e.interfaceid=t1.operator
order by CycleStart asc

return
end

if @param='Screen2'
begin
PRINT 'SCREEN2'
insert into #Output2
select * from  dbo.PumpTestData_Mivin p1 WHERE MachineID=@Machineid and  PumpModel=@PumpModel and OperationNo=@operationno and Operator=@operator and PumpAB=@pumpab and PumpType=@pumptype
and CycleStart=@CycleStart and SlNo=@SlNo and ReWorkNo=@ReworkNo and ReCheckNo=@ReCheckNo and (MeasuredDatetime>=@starttime and MeasuredDatetime<=@endtime)


insert into #Test2(Machineid,CycleStart,PumpModel,PumpType,pumpab,Slno,Event,Flowval,TempVal,PressureVal,RpmVal,status,MeasuredDatetime,ismasterpump,ReworkNo,RecheckNo,operationno,operator)
select distinct p1.MachineID,p1.CycleStart,p1.pumpmodel,p1.pumptype,p1.PumpAB,p1.slno,p1.event,
p1.FlowVal,p1.TempVal,p1.PressureVal,p1.RPMVal,p1.status,p1.MeasuredDatetime,
p1.IsMasterPump,p1.ReWorkNo,p1.ReCheckNo,p1.OperationNo,p1.Operator from #Output2 p1
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


select distinct Machineid,PumpModel,t1.Event,TimeInterval,e.Employeeid,e.Name,t1.operator,t1.operationno,PumpType,pumpab,Slno,ReworkNo,RecheckNo,Flowval,TempVal,PressureVal,RpmVal,CycleStart,MeasuredDatetime,
case when (t1.status)='ok' then 'Pass' when (t1.status)='Not Ok' then 'Fail' else '' end Result   from #Test2 t1
left outer join employeeinformation e on e.interfaceid=t1.operator
order by Event ASC
RETURN

end


end
