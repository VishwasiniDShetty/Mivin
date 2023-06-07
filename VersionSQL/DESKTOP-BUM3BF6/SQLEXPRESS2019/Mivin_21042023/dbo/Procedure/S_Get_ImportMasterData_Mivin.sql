/****** Object:  Procedure [dbo].[S_Get_ImportMasterData_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
EXEC S_Get_ImportMasterData_Mivin
*/
CREATE procedure [dbo].[S_Get_ImportMasterData_Mivin]
AS
BEGIN


------------------------------------------------------------------------------Comonentinformation insert --------------------------------------------------------------------------------------------
if exists(select * from PumpModelMasterTemp_Mivin A1 WHERE NOT EXISTS(SELECT * FROM componentinformation A2 WHERE A1.PumpModel=A2.componentid))
BEGIN
INSERT INTO componentinformation(componentid,description,customerid,basicvalue,InterfaceID,IsPumpEnabled)
SELECT DISTINCT PUMPMODEL,PUMPDESCRIPTION,CustomerID,0,PUMPMODEL,1 FROM PumpModelMasterTemp_Mivin P1
WHERE NOT EXISTS(SELECT * FROM componentinformation P2 WHERE P1.PumpModel=P2.componentid)
END
ELSE
BEGIN
UPDATE componentinformation SET description=T1.PumpDescription,customerid=T1.CustomerID,basicvalue=0,InterfaceID=T1.Pumpmodel,IsPumpEnabled=1
from
(
Select pumpmodel,PumpDescription,CustomerID from PumpModelMasterTemp_Mivin p1 
		where exists(Select * from componentinformation p2  where p1.pumpmodel=p2.componentid )
	)T1 inner join componentinformation T2 on t1.pumpmodel=t2.componentid
end


------------------------------------------------------------------------------Comonentinformation insert --------------------------------------------------------------------------------------------
------------------------------------------------------------------------------PumpModelMaster_Mivin insert --------------------------------------------------------------------------------------------
IF EXISTS(Select * from PumpModelMasterTemp_Mivin A1 
	where Not exists(Select * from PumpModelMaster_Mivin A2  where A1.PUMPMODEL=A2.PumpModel)
	)
BEGIN
INSERT INTO PumpModelMaster_Mivin(PumpModel,PumpType,PumpCategory,RotationalType,TimeIntervalVal1,TimeIntervalVal2,TimeIntervalVal3,TimeIntervalVal4,TimeIntervalVal5)
Select DISTINCT pumpmodel,PumpType,PumpCategory,RotationalType,TimeIntervalVal1,TimeIntervalVal2,TimeIntervalVal3,TimeIntervalVal4,TimeIntervalVal5 from PumpModelMasterTemp_Mivin p1 
where Not exists(Select * from PumpModelMaster_Mivin p2  where p1.pumpmodel=p2.pumpmodel )
end
else
begin
update PumpModelMaster_Mivin set PumpType=T1.pumptype,PumpCategory=T1.PumpCategory, RotationalType=t1.RotationalType,TimeIntervalVal1=t1.TimeIntervalVal1,TimeIntervalVal2=t1.TimeIntervalVal2,
TimeIntervalVal3=t1.TimeIntervalVal3,TimeIntervalVal4=t1.TimeIntervalVal4,TimeIntervalVal5=t1.TimeIntervalVal5
	from(
		Select pumpmodel,PumpType,PumpCategory,RotationalType,TimeIntervalVal1,TimeIntervalVal2,TimeIntervalVal3,TimeIntervalVal4,TimeIntervalVal5 from PumpModelMasterTemp_Mivin p1 
		where exists(Select * from PumpModelMaster_Mivin p2  where p1.pumpmodel=p2.PumpModel )
	)T1 inner join PumpModelMaster_Mivin T2 on t1.pumpmodel=t2.PumpModel
end

------------------------------------------------------------------------------PumpModelMaster_Mivin ends --------------------------------------------------------------------------------------------

------------------------------------------------------------------------------PumpModelParameterMaster_Mivin insert --------------------------------------------------------------------------------------------
if exists(select * from PumpModelParameterMasterTemp_Mivin a1 where not exists(select * from PumpModelParameterMaster_Mivin a2 where a1.PumpModel=a2.PumpModel and a1.Parameter=a2.Parameter and a1.Event=a2.Event
and a1.PumpAB=a2.PumpAB))
begin
insert into PumpModelParameterMaster_Mivin(PumpModel,PumpType,Parameter,Event,PumpAB,lsl,usl,UpdatedTS)
select DISTINCT p1.pumpmodel,p2.pumptype,Parameter,Event,PumpAB,lsl,usl,UpdatedTS   from PumpModelParameterMasterTemp_Mivin p1
left outer join PumpModelMasterTemp_Mivin p2 on p1.PumpModel=p2.PumpModel
where not exists(select * from PumpModelParameterMaster_Mivin p3 where p3.PumpModel=p1.PumpModel and p3.Parameter=p1.Parameter and p1.Event=p3.Event and p1.PumpAB=p3.PumpAB)

update PumpModelParameterMaster_Mivin set lsl=t1.lsl,usl=t1.usl,PumpType=t1.pumptype
from
(
select p1.pumpmodel,p2.PumpType,Parameter,Event,pumpab,LSL,USL  from PumpModelParameterMasterTemp_Mivin p1
left outer join PumpModelMasterTemp_Mivin p2 on p1.PumpModel=p2.PumpModel
where  exists(select * from PumpModelParameterMaster_Mivin p3 where p1.pumpmodel=p3.pumpmodel and p1.parameter=p3.Parameter and p1.event=p3.Event and p1.pumpab=p3.pumpab)
)t1 inner join PumpModelParameterMaster_Mivin on t1.Pumpmodel=PumpModelParameterMaster_Mivin.PumpModel and t1.Parameter=PumpModelParameterMaster_Mivin.Parameter 
and t1.Event=PumpModelParameterMaster_Mivin.Event and t1.PumpAB=PumpModelParameterMaster_Mivin.PumpAB
end
else
begin
update PumpModelParameterMaster_Mivin set lsl=t1.lsl,usl=t1.usl,PumpType=t1.pumptype
from
(
select p1.pumpmodel,p2.PumpType,Parameter,Event,pumpab,LSL,USL  from PumpModelParameterMasterTemp_Mivin p1
left outer join PumpModelMasterTemp_Mivin p2 on p1.PumpModel=p2.PumpModel
where  exists(select * from PumpModelParameterMaster_Mivin p3 where p1.pumpmodel=p3.pumpmodel and p1.parameter=p3.Parameter and p1.event=p3.Event and p1.pumpab=p3.pumpab)
)t1 inner join PumpModelParameterMaster_Mivin on t1.Pumpmodel=PumpModelParameterMaster_Mivin.PumpModel and t1.Parameter=PumpModelParameterMaster_Mivin.Parameter and t1.Event=PumpModelParameterMaster_Mivin.Event and t1.PumpAB=PumpModelParameterMaster_Mivin.PumpAB

--IF EXISTS(SELECT * FROM PumpModelParameterMasterTemp_Mivin A1
--WHERE NOT EXISTS(SELECT * FROM PumpModelParameterMaster_Mivin a2 where a1.pumpmodel=a2.PumpModel and a1.pumptype=a2.PumpType and a1.PumpCategory=a2.PumpCategory and 
end
END
