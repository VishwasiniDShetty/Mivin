/****** Object:  Procedure [dbo].[S_ScanSLNoDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_ScanSLNoDetails_Mivin] 'R979030526','12345674',''

[dbo].[S_ScanSLNoDetails_Mivin] 'R979028998','123456790',''

[dbo].[S_ScanSLNoDetails_Mivin] 'r983035463','338142457',''

*/
CREATE PROCEDURE [dbo].[S_ScanSLNoDetails_Mivin]
@PumpModel NVARCHAR(50)='',
@SerialNo NVARCHAR(50)='',
@param nvarchar(50)=''
AS
BEGIN

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

CREATE TABLE #Test1
(
Machineid NVARCHAR(50),
PumpModel NVARCHAR(50),
Slno NVARCHAR(50),
PumpType NVARCHAR(50),
Event NVARCHAR(50),
CycleStart DATETIME,
MeasuredDatetime DATETIME,
Flowval FLOAT ,
TempVal FLOAT ,
PressureVal FLOAT ,
RpmVal FLOAT ,
flowlsl FLOAT ,
flowusl FLOAT ,
Templsl FLOAT,
Tempusl FLOAT ,
pressurelsl FLOAT ,
pressureusl FLOAT ,
pt4lsl float ,
pt4usl float ,
rpmlsl FLOAT,
rpmusl FLOAT ,
ismasterpump bit,
pumpab NVARCHAR(50),
ReworkNo float,
RecheckNo float,
status NVARCHAR(50)
)

CREATE TABLE #View
(
GroupID NVARCHAR(50) DEFAULT 'Testing',
Parameter NVARCHAR(50) DEFAULT '',
Value FLOAT DEFAULT 0,
status NVARCHAR(50) DEFAULT ''
)

CREATE TABLE #View1
(
GroupID NVARCHAR(50) DEFAULT 'Testing',
PumpModel nvarchar(50),
SlNo nvarchar(50),
PumpType nvarchar(50),
PumpAB NVARCHAR(50),
Parameter NVARCHAR(50) DEFAULT '',
Value FLOAT DEFAULT 0,
status NVARCHAR(50) DEFAULT 'ok'
)

create table #TandemView
(
Machineid nvarchar(50),
Componentid nvarchar(50),
Slno1 nvarchar(50),
SlNo2 nvarchar(50),
updatedts datetime
)

create table #TandemView1
(
Machineid nvarchar(50),
Componentid nvarchar(50),
Slno1 nvarchar(50),
SlNo2 nvarchar(50),
updatedts datetime
)

create table #slno
(
id bigint identity(1,1), 
slno nvarchar(50)
)

DECLARE @PumpType nvarchar(50)
select @PumpType=(select distinct pumptype from PumpModelMaster_Mivin where PumpModel=@PumpModel)
print @PumpType

if @PumpType='Tandem'
begin
print 'Tandem'
insert into #TandemView(Machineid,Componentid,Slno1,SlNo2)
select distinct machineid,componentid,
case when CHARINDEX('/', workorder) > 0  then SUBSTRING(workorder,1,CHARINDEX('/',workorder) - 1) else workorder end,
case when CHARINDEX('/', workorder) > 0 then SUBSTRING(workorder,CHARINDEX('/',workorder)+1,len(workorder)) else workorder end  from WorkOrderDetails_Mivin
where componentid=@PumpModel and workorder like '%'+@SerialNo+'%'




insert into #TandemView1(Machineid,Componentid,Slno1,SlNo2,updatedts)
select machineid,componentid,
 CASE WHEN CHARINDEX('_', slno1) > 0 THEN
    LEFT(slno1, CHARINDEX('_', slno1)-1) ELSE
    slno1 END,
	 CASE WHEN CHARINDEX('_', slno2) > 0 THEN
    LEFT(slno2, CHARINDEX('_', slno2)-1) ELSE
    slno2 END,updatedts from #TandemView

	delete from #TandemView1 where (Slno1<>@SerialNo and SlNo2<>@SerialNo)

	insert into #slno(slno)
	select distinct Slno1  from #TandemView1
	union
	select distinct slno2 from #TandemView1
end

if @PumpType='SOLO'
BEGIN
insert into #test
select * FROM dbo.PumpTestData_Mivin p1 WHERE p1.PumpModel=@PumpModel and Event in ('t1','t4') AND p1.SlNo=@SerialNo
END

IF @PumpType='TANDEM'
BEGIN
insert into #test
select * FROM dbo.PumpTestData_Mivin p1 WHERE p1.PumpModel=@PumpModel and Event in ('t1','t4') AND p1.SlNo IN (SELECT DISTINCT SLNO FROM #slno)
END

insert into #Test1(Machineid,CycleStart,PumpModel,PumpType,pumpab,Slno,Event,Flowval,TempVal,PressureVal,RpmVal,status,MeasuredDatetime,ismasterpump,ReworkNo,RecheckNo)
select distinct p1.MachineID,p1.CycleStart,p1.pumpmodel,p1.pumptype,p1.PumpAB,p1.slno,p1.event,
p1.FlowVal,p1.TempVal,p1.PressureVal,p1.RPMVal,p1.status,p1.MeasuredDatetime,
p1.IsMasterPump,p1.ReWorkNo,p1.ReCheckNo from #test p1
inner join(select PumpModel,PumpType,PumpAB,SlNo,event,max(MeasuredDatetime) as updatedts from #test 
group by PumpModel,PumpType,pumpab,SlNo,event)t on  t.PumpModel=p1.PumpModel and t.PumpType=p1.PumpType and t.SlNo=p1.SlNo and t.Event=p1.Event
and t.updatedts=p1.MeasuredDatetime
order by p1.MeasuredDatetime,PumpAB asc

-----------------------------------------------------------Lsl usl update begins----------------------------------------------------------------------------------------------------------------------------
update #Test1 set flowlsl=isnull(t1.lsl,0),flowusl=isnull(t1.usl,0)
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='flow' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event

update #Test1 set Templsl=isnull(t1.lsl,0),Tempusl=isnull(t1.usl,0)
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='Temperature' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event

update #Test1 set pressurelsl=isnull(t1.lsl,0),pressureusl=isnull(t1.usl,0)
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='Pressure' and Event='t1'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event

update #Test1 set pt4lsl=isnull(t1.lsl,0),pt4usl=isnull(t1.usl,0)
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='Pressure' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event


update #Test1 set rpmlsl=isnull(t1.lsl,0),rpmusl=isnull(t1.usl,0)
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='RPM' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event


-----------------------------------------------------------lsl usl update ends----------------------------------------------------------------------------------------------------------------------------

insert into #view(Parameter)values('Running In Pressure'),('Performance Test'),('Temperature'),('Rpm'),('Lpm'),('FinalPass')


INSERT INTO #View1(PumpModel,SlNo,PumpType,PumpAB,Parameter)
select distinct pumpmodel,Slno,pumptype,pumpab,parameter from #Test1 t1
cross join #View v1

----------------------------------------------------------------------Value Update begins--------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------Value Update for Running In Pressure (t1 event) begins--------------------------------------------------------------------------------------------------------------------------

update #View1 set Value=t1.value,status=t1.status
from
(
select pumpmodel,pumptype,pumpab,slno,PressureVal as value,case when PressureVal >=ISNULL(pressurelsl,0) and PressureVal<=ISNULL(pressureusl,0) then 'Pass' else 'Fail' end as Status  from #test1
where event='t1'
) t1 inner join #View1 on #View1.Parameter='Running In Pressure' and t1.PumpModel=#View1.PumpModel and t1.PumpType=#View1.PumpType and t1.pumpab=#View1.PumpAB and t1.Slno=#View1.SlNo


----------------------------------------------------------------------Value Update for Running In Pressure (t1 event) ends--------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------Value Update for Temperature (t4 event) begins--------------------------------------------------------------------------------------------------------------------------

update #View1 set Value=t1.value,status=t1.sts
from
(
select pumpmodel,pumptype,pumpab,slno,TempVal as value,case when TempVal >=ISNULL(Templsl,0) and TempVal<=ISNULL(Tempusl,0) then 'Pass' when status='ok' then 'Pass' else 'Fail' end as sts  from #test1
where event='t4'
) t1 inner join #View1 on #View1.Parameter='Temperature' and t1.PumpModel=#View1.PumpModel and t1.PumpType=#View1.PumpType and t1.pumpab=#View1.PumpAB and t1.Slno=#View1.SlNo

----------------------------------------------------------------------Value Update for Temperature (t4 event) ends--------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------Value Update for RPM (t4 event) begins--------------------------------------------------------------------------------------------------------------------------

update #View1 set Value=t1.value,status=t1.sts
from
(
select pumpmodel,pumptype,pumpab,slno,RpmVal as value,case when RpmVal >=ISNULL(rpmlsl,0) and RpmVal<=ISNULL(rpmusl,0) then 'Pass' when status='ok' then 'Pass' else 'Fail' end as sts  from #test1
where event='t4'
) t1 inner join #View1 on #View1.Parameter='Rpm' and t1.PumpModel=#View1.PumpModel and t1.PumpType=#View1.PumpType and t1.pumpab=#View1.PumpAB and t1.Slno=#View1.SlNo 

----------------------------------------------------------------------Value Update for RPM (t4 event) ENDS--------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------Value Update for FLOW (t4 event) begins--------------------------------------------------------------------------------------------------------------------------

update #View1 set Value=t1.value,status=t1.status
from
(
select pumpmodel,pumptype,pumpab,slno,Flowval as value,case when Flowval >=ISNULL(flowlsl,0) and Flowval<=ISNULL(flowusl,0) then 'Pass' when status='ok' then 'Pass' else 'Fail' end as Status  from #test1
where event='t4'
) t1 inner join #View1 on #View1.Parameter='Lpm' and t1.PumpModel=#View1.PumpModel and t1.PumpType=#View1.PumpType and t1.pumpab=#View1.PumpAB and t1.Slno=#View1.SlNo
----------------------------------------------------------------------Value Update for FLOW (t4 event) ENDS--------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------Value Update for performance test( pressure t4 event) starts--------------------------------------------------------------------------------------------------------------------------
update #View1 set Value=t1.value,status=t1.Status 
from
(
select pumpmodel,pumptype,pumpab,slno,PressureVal as value,case when PressureVal >=ISNULL(pt4lsl,0) and PressureVal<=ISNULL(pt4usl,0) then 'Pass' when status='ok' then 'Pass' else 'Fail' end as Status  from #test1
where event='t4'
)t1 inner join #View1 on #View1.Parameter='Performance Test'  and t1.PumpModel=#View1.PumpModel and t1.PumpType=#View1.PumpType and t1.pumpab=#View1.PumpAB and t1.Slno=#View1.SlNo

----------------------------------------------------------------------Value Update for performance test( pressure t4 event) starts--------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------Value Update for final pass( pressure t4 event) starts--------------------------------------------------------------------------------------------------------------------------

update #View1 set status=t1.status
from
(
select pumpmodel,pumptype,pumpab,slno,PressureVal as value,case when ((PressureVal >=ISNULL(pt4lsl,0) and PressureVal<=ISNULL(pt4usl,0)) and (Flowval>=ISNULL(flowlsl,0) and Flowval<=ISNULL(flowusl,0))) then 'Pass' when status='ok' then 'Pass' else 'Fail' end as Status  from #test1
where event='t4'
)t1 inner join #View1 on #View1.Parameter='FinalPass'  and t1.PumpModel=#View1.PumpModel and t1.PumpType=#View1.PumpType and t1.pumpab=#View1.PumpAB and t1.Slno=#View1.SlNo

----------------------------------------------------------------------Value Update ends--------------------------------------------------------------------------------------------------------------------------

select DISTINCT GroupID,PumpModel,SlNo,PumpType,PumpAB,Parameter,VALUE,status from #View1


END
