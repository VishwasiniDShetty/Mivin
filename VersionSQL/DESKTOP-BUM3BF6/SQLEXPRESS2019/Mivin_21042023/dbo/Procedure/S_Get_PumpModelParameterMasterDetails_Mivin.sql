/****** Object:  Procedure [dbo].[S_Get_PumpModelParameterMasterDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
exec [dbo].[S_Get_PumpModelParameterMasterDetails_Mivin] 'F000000000','A'
exec [dbo].[S_Get_PumpModelParameterMasterDetails_Mivin] 'R979030526','A'
*/
CREATE procedure [dbo].[S_Get_PumpModelParameterMasterDetails_Mivin]
@PumpModel nvarchar(50)='',
@PumpAB NVARCHAR(50)=''
as
begin

create table #temp1
(
PumpModel nvarchar(50),
PumpType nvarchar(50),
Parameter nvarchar(50),
PumpAB NVARCHAR(50),
Event nvarchar(50),
T1 float,
T2 float,
T3 float,
T4 float,
T5 float,
LSL NVARCHAR(50),
USL NVARCHAR(50),
UpdatedTS DATETIME
)

create table #temp2
(
id bigint identity(1,1),
Event nvarchar(50)
)


insert into #temp2(Event)values('T1'),('T2'),('T3'),('T4'),('T5')


insert into #temp1(PumpModel,PumpType,Parameter,Event)
select p1.PumpModel,p1.PumpType,p2.parameter,T2.Event from PumpModelMaster_Mivin p1
CROSS JOIN PumpParameterMaster_Mivin p2
CROSS JOIN #temp2 T2
WHERE P1.PumpModel=@PumpModel


update #temp1 set T1=t1.val1,T2=t1.val2,T3=t1.val3,T4=t1.val4,T5=t1.val5
from
(
select PumpModel,pumptype, TimeIntervalVal1 as val1,TimeIntervalVal2 as val2,TimeIntervalVal3 as val3,TimeIntervalVal4 as val4,TimeIntervalVal5 as val5  from PumpModelMaster_Mivin
)t1 inner join #temp1 on t1.PumpModel=#temp1.PumpModel and t1.PumpType=#temp1.PumpType

UPDATE #temp1 SET LSL=T1.LOWERSL,USL=T1.UPPERSL
FROM
(SELECT PumpModel,PumpType,Parameter,Event,PUMPAB,LSL AS LOWERSL,USL AS UPPERSL FROM PumpModelParameterMaster_Mivin
)T1 INNER JOIN #temp1 ON T1.PumpModel=#temp1.PumpModel AND T1.PumpType=#temp1.PumpType AND T1.Parameter=#temp1.Parameter AND T1.Event=#temp1.Event AND T1.PumpAB=#temp1.PumpAB

UPDATE #temp1 SET PumpAB=@PumpAB

--SELECT T1.PumpModel,T1.PumpType,T1.Parameter,T1.PumpAB,T1.Event,T1.T1,T1.T2,T1.T3,T1.T4,T1.T5,T1.LSL,T1.USL,P1.UpdatedTS FROM #temp1 T1
--LEFT JOIN PumpModelParameterMaster_Mivin P1 ON T1.PumpModel=P1.PumpModel AND T1.PumpType=P1.PumpType AND T1.Parameter=P1.Parameter AND T1.Event=P1.Event AND T1.PumpAB=P1.PumpAB
--WHERE T1.PumpModel=@PumpModel AND T1.PumpAB=@PumpAB

UPDATE #temp1 SET LSL=T1.LOWERSL,USL=T1.UPPERSL
FROM
(SELECT PumpModel,PumpType,Parameter,Event,PUMPAB,LSL AS LOWERSL,USL AS UPPERSL FROM PumpModelParameterMaster_Mivin
)T1 INNER JOIN #temp1 ON T1.PumpModel=#temp1.PumpModel AND T1.PumpType=#temp1.PumpType AND T1.Parameter=#temp1.Parameter AND T1.Event=#temp1.Event AND T1.PumpAB=#temp1.PumpAB

select * from #temp1

--UPDATE #temp1 SET PumpAB=T1.Pump
--FROM
--(SELECT PumpModel,PumpType,Parameter,Event,@PumpAB as Pump FROM PumpModelParameterMaster_Mivin
--)T1 INNER JOIN #temp1 ON T1.PumpModel=#temp1.PumpModel AND T1.PumpType=#temp1.PumpType AND T1.Parameter=#temp1.Parameter AND T1.Event=#temp1.Event


--SELECT * FROM #TEMP1 where (PumpAB=@PumpAB OR ISNULL(@PumpAB,'')='')

--DECLARE @vAL1 NVARCHAR(50)
--DECLARE @VAL2 NVARCHAR(50)
--DECLARE @VAL3 NVARCHAR(50)
--DECLARE @VAL4 NVARCHAR(50)
--DECLARE @VAL5 NVARCHAR(50)


--SELECT @vAL1 =(SELECT DISTINCT T1 FROM #temp1)
--SELECT @vAL2 =(SELECT DISTINCT T2 FROM #temp1)
--SELECT @vAL3 =(SELECT DISTINCT T3 FROM #temp1)
--SELECT @vAL4 =(SELECT DISTINCT T4 FROM #temp1)
--SELECT @vAL5 =(SELECT DISTINCT T5 FROM #temp1)

--select T1.PumpModel,T1.PumpType,T1.parameter,T2.Event from #temp1 T1
--CROSS JOIN #temp2 T2 
end
