/****** Object:  Procedure [dbo].[S_Get_FlowControlDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_Get_FlowControlDetails_Mivin] '706','R979028998','2022-01-17 00:00:00.000',''

[dbo].[S_Get_FlowControlDetails_Mivin] '2064','R983035463','2022-02-10 00:00:00.000',''


*/
CREATE procedure [dbo].[S_Get_FlowControlDetails_Mivin]
@Machineid nvarchar(50)='',
@PumpModel nvarchar(50)='',
@Date datetime='',
@Shift nvarchar(50)=''
as
begin
declare @starttime datetime
declare @endtime datetime
select @starttime= dbo.f_GetLogicalDay(@date,'Start')
select @endtime=dbo.f_GetLogicalDay(@date,'End')

CREATE TABLE #Test1
(
Machineid NVARCHAR(50),
Date datetime,
Shift nvarchar(50),
PumpModel NVARCHAR(50),
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
Operator nvarchar(50),
DeliveryValue float default 0,
PressureValue float default 0
)

create table #shift
(
ShiftDate DateTime,		
Shiftname nvarchar(20),
ShiftID NVARCHAR(50),
ShftSTtime DateTime,
ShftEndTime DateTime
)
DECLARE @startdate DATETIME
DECLARE @Enddate DATETIME

SELECT @startdate=@starttime
SELECT @Enddate=@endtime

while cast(@startdate as date)<cast(@enddate as date)
begin
INSERT INTO #shift(ShiftDate,Shiftname,ShftSTtime,ShftEndTime)
		Exec s_GetShiftTime @startdate,''
		SELECT @startdate = DATEADD(DAY,1,@startdate)
end

Update #shift Set shiftid = isnull(#shift.Shiftid,0) + isnull(T1.shiftid,0) from
(Select SD.shiftid ,SD.shiftname from shiftdetails SD
inner join #shift S on SD.shiftname=S.shiftname where
running=1 )T1 inner join #shift on  T1.shiftname=#shift.shiftname


SELECT * INTO #test
FROM dbo.PumpTestData_Mivin p1 WHERE p1.MachineID=@Machineid and p1.PumpModel=@PumpModel AND p1.MeasuredDatetime>=@starttime and p1.MeasuredDatetime<=@endtime and p1.Event='T4'


insert into #test1(Machineid,PumpModel,Slno,PumpType,Event,MeasuredDatetime)
select machineid,PumpModel,SlNo,PumpType,Event,max(MeasuredDatetime) as MeasuredDatetime   from #test
group BY machineid,PumpModel,SlNo,PumpType,Event

UPDATE #Test1 SET Flowval=T1.FLOWVAL,status=T1.STATUS,Operator=t1.Operator,pumpab=t1.pumpab
FROM
(
SELECT machineid,PumpModel,SlNo,PumpType,EvenT,MeasuredDatetime,FlowVal,FlowLSL,FlowUSL,PressureLSL,PressureUSL, status,Operator,PumpAB FROM #test
) T1 INNER JOIN #Test1 ON #Test1.Machineid=T1.MachineID AND #Test1.PumpModel=T1.PumpModel AND #Test1.Slno=T1.SlNo AND #Test1.PumpType=T1.PumpType AND #Test1.Event=T1.Event AND #Test1.MeasuredDatetime=T1.MeasuredDatetime


update #Test1 set flowlsl=t1.lsl,flowusl=t1.usl
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='flow' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event

update #Test1 set pressurelsl=t1.lsl,pressureusl=t1.usl
from
(select PumpModel,PumpType,PumpAB,Event,lsl,usl  from PumpModelParameterMaster_Mivin
where Parameter='Pressure' and Event='t4'
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event

if exists(select * from PumpModelParameterMaster_Mivin where PumpModel=@PumpModel and Event='t4' and Parameter='Flow')
begin
update #Test1 set status=t1.status
from
(select PumpModel,PumpType,PumpAB,Event,case when((Flowval>=flowlsl and Flowval<=flowusl)) then 'ok' else 'NotOk' end status from #Test1
where  Event='t4'  --and flowusl<>0 or flowlsl<>0
)t1 inner join #test1 on #Test1.PumpModel=t1.PumpModel and #Test1.PumpType=t1.PumpType and #Test1.pumpab=t1.PumpAB and #Test1.Event=t1.Event
end

select @DATE as Date,m.MACHINEID,m.description,PumpModel,PumpType,pumpab,Slno,S.SHIFTID,s.Shiftname,e.Employeeid as OperatorID,Operator AS OpInterface,e.Name as OperatorName,MeasuredDatetime,
Flowval,
case when (#Test1.status)='Ok' then 'Pass' when (#Test1.status)='Not Ok' Then 'Fail' else '' end as status, 
flowlsl as FlowMinSpec,flowusl as FlowMaxSpec,pressurelsl as PressureMinSpec,pressureusl as PressureMaxspec from #test1
cross join #shift s
left outer join employeeinformation e on e.interfaceid=#Test1.Operator
left outer join machineinformation m on m.machineid=#Test1.Machineid
where (MeasuredDatetime>=ShftSTtime and MeasuredDatetime<=ShftEndTime)
and (ShiftID=@Shift or isnull(@shift,'')='')
order by shiftid asc
end
