/****** Object:  Procedure [dbo].[s_GetCockpitData_WithTempTable_eshopx_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
exec s_GetCockpitData_WithTempTable_eshopx_Mivin @StartTime=N'2021-08-02 06:00:00',@EndTime=N'2021-08-03 06:00:00',@MachineId=N'',@PlantId=N'Rexroth-HejP',@SortOrder=N'',
@GroupID=N'Testing',@param=N'FirstScreen' 

exec s_GetCockpitData_WithTempTable_eshopx_Mivin @StartTime=N'2021-08-02 06:00:00.000',@EndTime=N'2021-08-03 06:00:00',@MachineId=N'',@PlantId=N'Rexroth-HejP',@SortOrder=N'',
@GroupID=N'',@param=N'SecondScreen' 

exec s_GetCockpitData_WithTempTable_eshopx_Mivin @StartTime=N'2021-08-02 06:00:00.000',@EndTime=N'2021-08-03 06:00:00',@MachineId=N'',@PlantId=N'Rexroth-HejP',@SortOrder=N'',
@GroupID=N'',@param=N'ThirdScreen' 

exec s_GetCockpitData_WithTempTable_eshopx_Mivin @StartTime=N'2021-08-02 06:00:00.000',@EndTime=N'2021-08-03 06:00:00',@MachineId=N'',@PlantId=N'Rexroth-HejP',@SortOrder=N'',
@GroupID=N'',@param=N'FourthScreen' 

exec s_GetCockpitData_WithTempTable_eshopx_Mivin @StartTime=N'2021-08-02 06:00:00.000',@EndTime=N'2021-08-03 06:00:00',@MachineId=N'',@PlantId=N'Rexroth-HejP',@SortOrder=N'',
@GroupID=N'Testing',@SubGroup=N'AZPF', @param=N'FifthScreen' 

exec s_GetCockpitData_WithTempTable_eshopx_Mivin @StartTime=N'2021-08-02 06:00:00',@EndTime=N'2021-08-03 06:00:00',@MachineId=N'',@PlantId=N'Rexroth-HejP',@SortOrder=N'',
@GroupID=N'Testing',@SubGroup=N'AZPW', @param=N'FifthScreen' 


exec s_GetCockpitData_WithTempTable_eshopx_Mivin @StartTime=N'2021-01-01 06:00:00.000',@EndTime=N'2021-08-16 06:00:00.000',@MachineId=N'',@PlantId=N'',@SortOrder=N'',
@GroupID=N'Testing',@param=N'FirstScreen' 

*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[s_GetCockpitData_WithTempTable_eshopx_Mivin]
	@StartTime DATETIME OUTPUT,
	@EndTime DATETIME OUTPUT,
	@MachineID NVARCHAR(50) = '',
	@PlantID NVARCHAR(50)='',
	@SortOrder NVARCHAR(50)='',
	@GroupID NVARCHAR(50)='',
	@SubGroup NVARCHAR(50)='',
	@SortType NVARCHAR(50)='',
	@param NVARCHAR(50)=''
	
AS
BEGIN
DECLARE @strPlantID AS NVARCHAR(255)
DECLARE @strSql AS NVARCHAR(4000)
DECLARE @strMachine AS NVARCHAR(255)
DECLARE @timeformat AS NVARCHAR(2000)
DECLARE @StrTPMMachines AS NVARCHAR(500)		
DECLARE @StrExMachine AS NVARCHAR(255)
DECLARE @StrGroupID AS NVARCHAR(255)
DECLARE @strsubgroup AS NVARCHAR(255)

SELECT @StrTPMMachines=''					
SELECT @strMachine = ''
SELECT @strPlantID = ''
SELECT @timeformat ='ss'
SELECT @StrExMachine=''
SELECT @StrGroupID=''
SELECT @timeformat = ISNULL((SELECT valueintext FROM cockpitdefaults WHERE parameter='timeformat'),'ss')
IF (@timeformat <>'hh:mm:ss' AND @timeformat <>'hh' AND @timeformat <>'mm'AND @timeformat <>'ss')
BEGIN
	SELECT @timeformat = 'ss'
END

IF ISNULL(@SortOrder,'')='' AND (ISNULL(@param,'')='' OR @param='FourthScreen' OR @param='Fifthscreen' )
BEGIN
	SET @SortOrder = 'MachineID ASC'
END



DECLARE @Strsortorder AS NVARCHAR(MAX)
SELECT @Strsortorder= ''
IF @SortType='CustomSortorder'
BEGIN
	SELECT @Strsortorder= ' inner join MachinewiseSortOrder MS on C.Machineid=MS.Machineid Order By MS.SortOrder '
END
ELSE
BEGIN
	SELECT @Strsortorder= ' order by C.' + @SortOrder + ' '
END  

CREATE TABLE #CockPitData 
(
	MachineID NVARCHAR(50),
	MachineInterface NVARCHAR(50) PRIMARY KEY,
	ProductionEfficiency FLOAT,
	AvailabilityEfficiency FLOAT,
	QualityEfficiency FLOAT,
	OverallEfficiency FLOAT,
	Components FLOAT,
	RejCount FLOAT,  
	TotalTime FLOAT,
	UtilisedTime FLOAT,
	ManagementLoss FLOAT,
	DownTime FLOAT,
	CN FLOAT,
	Lastcycletime DATETIME,
	PEGreen SMALLINT,
	PERed SMALLINT,
	AEGreen SMALLINT,
	AERed SMALLINT,
	OEGreen SMALLINT,
	OERed SMALLINT,
	QEGreen SMALLINT, 
	QERed SMALLINT,
	MaxDownReason NVARCHAR(50) DEFAULT ('')
	,MLDown FLOAT,
	LastCycleCO NVARCHAR(100),
	LastCycleStart DATETIME,
	LastCycleEnd DATETIME,
	ElapsedTime INT,
	OperatorName NVARCHAR(50),
    ReworkCount FLOAT DEFAULT 0,
	TotalTestParts FLOAT DEFAULT 0,
	TotalOk FLOAT DEFAULT 0,
    TotalNotOk FLOAT DEFAULT 0,
	Holidays FLOAT DEFAULT 0,
	Working_days FLOAT DEFAULT 0,
	AvgProduction FLOAT DEFAULT 0,
	PDTInDays FLOAT DEFAULT 0,
	Remarks1 NVARCHAR(50),
	MachineLiveStatus NVARCHAR(50)

)

CREATE TABLE #Test
(
GroupID NVARCHAR(50),
Machineid NVARCHAR(50),
MachineInterface NVARCHAR(50),
PumpModel NVARCHAR(50),
subgroup NVARCHAR(50),
MeasuredDateTime DATETIME,
SlNo NVARCHAR(50),
ReCheckNo INT,
ReworkNo INT,
RejBit INT DEFAULT 0,
Total FLOAT
)


CREATE TABLE #PLD
(
	MachineID NVARCHAR(50),
	MachineInterface NVARCHAR(50) NOT NULL, --ER0374
	pPlannedDT FLOAT DEFAULT 0,
	dPlannedDT FLOAT DEFAULT 0,
	MPlannedDT FLOAT DEFAULT 0,
	IPlannedDT FLOAT DEFAULT 0,
	DownID NVARCHAR(50)
)
CREATE TABLE #PlannedDownTimes
(
	MachineID NVARCHAR(50) NOT NULL, 
	MachineInterface NVARCHAR(50) NOT NULL, 
	StartTime DATETIME NOT NULL, 
	EndTime DATETIME NOT NULL 
)

ALTER TABLE #PLD
	ADD PRIMARY KEY CLUSTERED
		(   [MachineInterface]
						
		) ON [PRIMARY]


ALTER TABLE #PlannedDownTimes
	ADD PRIMARY KEY CLUSTERED
		(   [MachineInterface],
			[StartTime],
			[EndTime]
						
		) ON [PRIMARY]

CREATE TABLE #T_autodata(
	[mc] [NVARCHAR](50)NOT NULL,
	[comp] [NVARCHAR](50) NULL,
	[opn] [NVARCHAR](50) NULL,
	[opr] [NVARCHAR](50) NULL,
	[dcode] [NVARCHAR](50) NULL,
	[sttime] [DATETIME] NOT NULL,
	[ndtime] [DATETIME] NOT NULL,
	[datatype] [TINYINT] NULL ,
	[cycletime] [INT] NULL,
	[loadunload] [INT] NULL ,
	[msttime] [DATETIME] NOT NULL,
	[PartsCount] DECIMAL(18,5) NULL ,
	id  BIGINT NOT NULL
)

ALTER TABLE #T_autodata

ADD PRIMARY KEY CLUSTERED
(
	mc,sttime,ndtime,msttime ASC
)ON [PRIMARY]

DECLARE @T_ST AS DATETIME 
DECLARE @T_ED AS DATETIME 

SELECT @T_ST=dbo.f_GetLogicalDaystart(@StartTime)
SELECT @T_ED=dbo.f_GetLogicalDayend(@EndTime)

SELECT @strsql=''
SELECT @strsql ='insert into #T_autodata '
SELECT @strsql = @strsql + 'SELECT mc, comp, opn, opr, dcode,sttime,'
	SELECT @strsql = @strsql + 'ndtime, datatype, cycletime, loadunload, msttime, PartsCount,id'
SELECT @strsql = @strsql + ' from autodata where (( sttime >='''+ CONVERT(NVARCHAR(25),@T_ST,120)+''' and ndtime <= '''+ CONVERT(NVARCHAR(25),@T_ED,120)+''' ) OR '
SELECT @strsql = @strsql + '( sttime <'''+ CONVERT(NVARCHAR(25),@T_ST,120)+''' and ndtime >'''+ CONVERT(NVARCHAR(25),@T_ED,120)+''' )OR '
SELECT @strsql = @strsql + '( sttime <'''+ CONVERT(NVARCHAR(25),@T_ST,120)+''' and ndtime >'''+ CONVERT(NVARCHAR(25),@T_ST,120)+'''
					and ndtime<='''+CONVERT(NVARCHAR(25),@T_ED,120)+''' )'
SELECT @strsql = @strsql + ' OR ( sttime >='''+CONVERT(NVARCHAR(25),@T_ST,120)+''' and ndtime >'''+ CONVERT(NVARCHAR(25),@T_ED,120)+''' and sttime<'''+CONVERT(NVARCHAR(25),@T_ED,120)+''' ) )'
PRINT @strsql
EXEC (@strsql)


DECLARE @startdate AS DATETIME
DECLARE @enddate AS DATETIME

SELECT @startdate = dbo.f_GetLogicalDaystart(@StartTime)
SELECT @enddate = dbo.f_GetLogicalDaystart(@endtime)

CREATE TABLE #shift
(
	ShiftDate DATETIME, 
	shiftname NVARCHAR(20),
	Shiftstart DATETIME,
	Shiftend DATETIME,
	shiftid INT
)

WHILE @startdate<=@enddate
BEGIN

	INSERT INTO #shift(shiftdate,shiftname,shiftstart,shiftend)
	EXEC s_getshifttime @startdate,''
	SELECT @startdate = DATEADD(DAY,1,@startdate)
END

UPDATE #shift SET shiftid = ISNULL(#shift.Shiftid,0) + ISNULL(T1.shiftid,0) FROM
(SELECT SD.shiftid ,SD.shiftname FROM shiftdetails SD
INNER JOIN #shift S ON SD.shiftname=S.shiftname WHERE
running=1 )T1 INNER JOIN #shift ON  T1.shiftname=#shift.shiftname



CREATE TABLE #Testing
(
	Plantid NVARCHAR(50),
	Groupid NVARCHAR(50),
	MachineID NVARCHAR(50),
	MachineInterface NVARCHAR(50),
	ProductionEfficiency FLOAT,
	AvailabilityEfficiency FLOAT,
	QualityEfficiency FLOAT, 
	OverallEfficiency FLOAT,
	Components FLOAT,
	RejCount FLOAT,  
	TotalTime FLOAT,
	UtilisedTime FLOAT,
	ManagementLoss FLOAT,
	DownTime FLOAT,
	CN FLOAT,
	MaxDownReason NVARCHAR(50) DEFAULT (''),
	GroupDescription NVARCHAR(150),
	PlantDescription NVARCHAR(150),
	ReworkCount FLOAT,
	TotalTestParts FLOAT,
	TotalOk FLOAT,
    TotalNotOk FLOAT,
	holidays INT,
	Working_days FLOAT,
	AvgProduction FLOAT,
	PDTInDays FLOAT DEFAULT 0
)

CREATE TABLE #TestingSubGroup
(
	Plantid NVARCHAR(50),
	Groupid NVARCHAR(50),
	SubGroup NVARCHAR(50),
	MachineID NVARCHAR(50),
	MachineInterface NVARCHAR(50),
	ProductionEfficiency FLOAT,
	AvailabilityEfficiency FLOAT,
	QualityEfficiency FLOAT, 
	OverallEfficiency FLOAT,
	Components FLOAT,
	RejCount FLOAT,  
	TotalTime FLOAT,
	UtilisedTime FLOAT,
	ManagementLoss FLOAT,
	DownTime FLOAT,
	CN FLOAT,
	MaxDownReason NVARCHAR(50) DEFAULT (''),
	GroupDescription NVARCHAR(150),
	PlantDescription NVARCHAR(150),
	ReworkCount FLOAT,
	TotalTestParts FLOAT,
	TotalOk FLOAT,
    TotalNotOk FLOAT,
	holidays INT,
	Working_days FLOAT,
	AvgProduction FLOAT,
	PDTInDays FLOAT DEFAULT 0
)

CREATE TABLE #DownStream
(
	Plantid NVARCHAR(50),
	MachineID NVARCHAR(50),
	MachineInterface NVARCHAR(50),
	ProductionEfficiency FLOAT,
	AvailabilityEfficiency FLOAT,
	QualityEfficiency FLOAT, 
	OverallEfficiency FLOAT,
	Components FLOAT,
	RejCount FLOAT,  
	TotalTime FLOAT,
	UtilisedTime FLOAT,
	ManagementLoss FLOAT,
	DownTime FLOAT,
	CN FLOAT,
	MaxDownReason NVARCHAR(50) DEFAULT (''),
	Description NVARCHAR(150),
	PlantDescription NVARCHAR(150),
	ReworkCount FLOAT,
	TotalTestParts FLOAT,
	TotalOk FLOAT,
    TotalNotOk FLOAT,
	holidays INT,
	Working_days FLOAT,
	AvgProduction FLOAT,
	PDTInDays FLOAT DEFAULT 0
)

CREATE TABLE #PlantCellwiseSummary
(
	Plantid NVARCHAR(50),
	Groupid NVARCHAR(50),
	MachineID NVARCHAR(50),
	MachineInterface NVARCHAR(50),
	ProductionEfficiency FLOAT,
	AvailabilityEfficiency FLOAT,
	QualityEfficiency FLOAT, 
	OverallEfficiency FLOAT,
	Components FLOAT,
	RejCount FLOAT,  
	TotalTime FLOAT,
	UtilisedTime FLOAT,
	ManagementLoss FLOAT,
	DownTime FLOAT,
	CN FLOAT,
	MaxDownReason NVARCHAR(50) DEFAULT (''),
	GroupDescription NVARCHAR(150),
	PlantDescription NVARCHAR(150),
	ReworkCount FLOAT,
	TotalTestParts FLOAT,
	TotalOk FLOAT,
    TotalNotOk FLOAT,
	holidays INT,
	Working_days FLOAT,
	AvgProduction FLOAT,
	PDTInDays FLOAT DEFAULT 0
)

CREATE TABLE #TestTemp
(
machineid NVARCHAR(50),
MachineInterface NVARCHAR(50),
PumpModel NVARCHAR(50),
SlNo NVARCHAR(50),
CycleStart DATETIME,
MeasuredDateTime DATETIME,
ReworkNo INT,
RecheckNo INT,
Status NVARCHAR(50),
IsMasterPump BIT DEFAULT 0
)

CREATE TABLE #MachineRunningStatus
(
	MachineID NVARCHAR(50),
	MachineInterface NVARCHAR(50),
	sttime DATETIME,
	ndtime DATETIME,
	DataType SMALLINT,
	ColorCode VARCHAR(10),
	Comp NVARCHAR(50), 
	Opn NVARCHAR(50), 
	StartTime DATETIME,
	Downtime FLOAT, 
	Totaltime INT, 
	ManagementLoss FLOAT, 
	UT FLOAT,
	PDT FLOAT,
	LastRecorddatatype INT, 
	AutodataMaxtime DATETIME, 
	PingStatus NVARCHAR(50)
)

CREATE TABLE #Focas_MachineRunningStatus
(
	[Machineid] [NVARCHAR](50) NULL,
	[Datatype] [NVARCHAR](50) NULL,
	[LastCycleTS] [DATETIME] NULL,
	[AlarmStatus] [NVARCHAR](50) NULL,
	[SpindleStatus] [INT] NULL,
	[SpindleCycleTS] [DATETIME] NULL,
	[PowerOnOrOff] [INT] NULL,
	Machinestatus NVARCHAR(50)
)

CREATE TABLE #MachineOnlineStatus
(
Machineid NVARCHAR(50),
LastConnectionOKTime DATETIME,
LastConnectionFailedTime DATETIME,
LastPingFailedTime DATETIME,
LastPingOkTime DATETIME,
LastPLCCommunicationOK DATETIME,
LastPLCCommunicationFailed DATETIME
)



DECLARE @CurrTime AS DATETIME
SET @CurrTime = CONVERT(NVARCHAR(20),GETDATE(),120)
PRINT @CurrTime


IF ( SELECT TOP 1 ValueInText FROM  CockpitDefaults WHERE Parameter='TpmEnbMac')='E'
BEGIN
	SET  @StrTPMMachines = 'AND MachineInformation.TPMTrakEnabled = 1'
END
ELSE
BEGIN
	SET  @StrTPMMachines = ' '
END
IF ISNULL(@machineid,'')<> ''
BEGIN
	SET @strMachine = ' AND MachineInformation.MachineID = N''' + @machineid + ''''
END
IF ISNULL(@PlantID,'')<> ''
BEGIN
	SET @strPlantID = ' AND PlantMachine.PlantID = N''' + @PlantID + ''''
END
IF ISNULL(@GroupID,'')<> ''
BEGIN
	SET @strGroupID = ' AND PlantMachineGroups.GroupID = N''' + @GroupID + ''''
END

IF ISNULL(@SubGroup,'')<> ''
BEGIN
	SET @strsubgroup = ' AND PlantMachineGroupSubgroup.subgroups = N''' + @SubGroup + ''''
END



SET @strSql = 'INSERT INTO #CockpitData (
	MachineID ,
	MachineInterface,
	ProductionEfficiency ,
	AvailabilityEfficiency,
	QualityEfficiency, --ER0368
	OverallEfficiency,
	Components ,
	RejCount, --ER0368
	TotalTime ,
	UtilisedTime ,	
	ManagementLoss,
	DownTime ,
	CN,
	PEGreen ,
	PERed,
	AEGreen ,
	AERed ,
	OEGreen ,
	OERed,
	QERed,  
	QEGreen, 
	--SpindleRuntime,
	TotalTestParts,
	TotalOk,
    TotalNotOk,
	Working_days,
	AvgProduction,
	Remarks1
	) '
SET @strSql = @strSql + ' SELECT MachineInformation.MachineID, MachineInformation.interfaceid ,0,0,0,0,0,0,0,0,0,0,0,PEGreen ,PERed,AEGreen ,AERed ,OEGreen ,OERed,isnull(QERed,0),isnull(QEGreen,0),0,0,0,0,0,0 FROM MachineInformation --ER0368 --ER0417(To include Plantid in Remarks2 column)
			  LEFT OUTER JOIN PlantMachine ON machineinformation.machineid = PlantMachine.MachineID
			  LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID
 WHERE MachineInformation.interfaceid > ''0'' '
SET @strSql =  @strSql + @strMachine + @strPlantID + @StrTPMMachines + @StrGroupID
EXEC(@strSql)


--mod 4 Get the Machines into #PLD
SET @strSql = ''
SET @strSql = 'INSERT INTO #PLD(MachineID,MachineInterface,pPlannedDT,dPlannedDT)
	SELECT machineinformation.MachineID ,Interfaceid,0  ,0 FROM MachineInformation
		LEFT OUTER JOIN PlantMachine ON machineinformation.machineid = PlantMachine.MachineID 
    LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID
	 WHERE  MachineInformation.interfaceid > ''0'' '
SET @strSql =  @strSql + @strMachine + @StrTPMMachines + @StrGroupID
EXEC(@strSql)

/* Planned Down times for the given time period */
SET @strSql = ''
SET @strSql = 'Insert into #PlannedDownTimes
	SELECT Machine,InterfaceID,
		CASE When StartTime<''' + convert(nvarchar(20),@StartTime,120)+''' Then ''' + convert(nvarchar(20),@StartTime,120)+''' Else StartTime End As StartTime,
		CASE When EndTime>''' + convert(nvarchar(20),@EndTime,120)+''' Then ''' + convert(nvarchar(20),@EndTime,120)+''' Else EndTime End As EndTime
	FROM PlannedDownTimes inner join MachineInformation on PlannedDownTimes.machine = MachineInformation.MachineID
	LEFT OUTER JOIN PlantMachine ON machineinformation.machineid = PlantMachine.MachineID 
    LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID 
	and PlantMachineGroups.machineid = PlantMachine.MachineID
	WHERE PDTstatus =1 and(
	(StartTime >= ''' + convert(nvarchar(20),@StartTime,120)+''' AND EndTime <=''' + convert(nvarchar(20),@EndTime,120)+''')
	OR ( StartTime < ''' + convert(nvarchar(20),@StartTime,120)+'''  AND EndTime <= ''' + convert(nvarchar(20),@EndTime,120)+''' AND EndTime > ''' + convert(nvarchar(20),@StartTime,120)+''' )
	OR ( StartTime >= ''' + convert(nvarchar(20),@StartTime,120)+'''   AND StartTime <''' + convert(nvarchar(20),@EndTime,120)+''' AND EndTime > ''' + convert(nvarchar(20),@EndTime,120)+''' )
	OR ( StartTime < ''' + convert(nvarchar(20),@StartTime,120)+'''  AND EndTime > ''' + convert(nvarchar(20),@EndTime,120)+''')) '
SET @strSql =  @strSql + @strMachine + @StrGroupID + @StrTPMMachines + ' ORDER BY Machine,StartTime'
EXEC(@strSql)



IF @GroupID='Testing' OR @GroupID=''
BEGIN

--INSERT INTO #TestTemp(machineid,PumpModel,SlNo,CycleStart,MeasuredDateTime,ReworkNo,RecheckNo,Status,IsMasterPump)
--SELECT MachineID,PumpModel,SlNo,CycleStart,MeasuredDatetime,ReWorkNo,ReCheckNo,Status,IsMasterPump FROM dbo.PumpTestData_Mivin
--WHERE MeasuredDatetime>=@StartTime AND MeasuredDatetime<=@EndTime

insert into #Test(machineid,MachineInterface,PumpModel,SlNo,MeasuredDateTime)
select distinct  M.machineid,m.MachineInterface,p.PumpModel,P.slno, max(MeasuredDatetime) as MeasuredDatetime from dbo.PumpTestData_Mivin P
INNER JOIN #CockPitData M ON M.MachineInterface=P.MachineID 
INNER JOIN dbo.machineinformation M1 ON M1.machineid=M.MachineID AND M1.IsTestBenchMachine=1
INNER JOIN dbo.PlantMachineGroups P1 ON P1.MachineID=M.machineid
where  (MeasuredDatetime>=@StartTime and MeasuredDatetime<=@EndTime) AND P1.GroupID='Testing' AND ISNULL(p.IsMasterPump,0)<>1
group by P1.GroupID,M.machineid,m.MachineInterface,PumpModel,P.SlNo

end

--update #Test set ReworkNo=isnull(t1.rewrk,0),ReCheckNo=isnull(t1.rechk,0)
--from
--(select distinct machineid,pumpmodel,slno,MeasuredDatetime,reworkno as rewrk,ReCheckNo as rechk  from PumpTestData_Mivin
--where  (MeasuredDatetime>=@StartTime and MeasuredDatetime<=@EndTime)
--) t1 inner join #Test on t1.MachineID=#Test.Machineid and t1.PumpModel=#Test.PumpModel and t1.SlNo=#Test.SlNo and t1.MeasuredDatetime=#Test.MeasuredDatetime

--update #Test set RejBit=(tt.Rej)
--from
--( select a.mc,a.WorkOrderNumber,1 as Rej from #Test t1 inner join AutodataRejections a  ON t1.MachineInterface=a.mc and a.WorkOrderNumber =
--            CASE
--               WHEN t1.ReworkNo IN (0)
--                   THEN  t1.SlNo
--               WHEN t1.ReworkNo IN (1,2,3,4,5,6,7,8,9,10)
--                   THEN ((t1.SlNo+'_'+CAST(t1.ReworkNo AS NVARCHAR(10))))
--               END
--)tt inner join #Test on #Test.MachineInterface=tt.mc and WorkOrderNumber =
--            CASE
--               WHEN ReworkNo IN (0)
--                   THEN  SlNo
--               WHEN ReworkNo IN (1,2,3,4,5,6,7,8,9,10)
--                   THEN ((SlNo+'_'+CAST(ReworkNo AS NVARCHAR(10))))
--               END
--end

/*******************************      Utilised Calculation Starts ***************************************************/

UPDATE #CockpitData SET UtilisedTime = isnull(UtilisedTime,0) + isNull(t2.cycle,0)
from
(select      mc,sum(cycletime+loadunload) as cycle
from #T_autodata autodata 
where (autodata.msttime>=@StartTime)
and (autodata.ndtime<=@EndTime)
and (autodata.datatype=1)
group by autodata.mc
) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
-- Type 2
UPDATE #CockpitData SET UtilisedTime = isnull(UtilisedTime,0) + isNull(t2.cycle,0)
from
(select  mc,SUM(DateDiff(second, @StartTime, ndtime)) cycle
from #T_autodata autodata 
where (autodata.msttime<@StartTime)
and (autodata.ndtime>@StartTime)
and (autodata.ndtime<=@EndTime)
and (autodata.datatype=1)
group by autodata.mc
) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
-- Type 3
UPDATE  #CockpitData SET UtilisedTime = isnull(UtilisedTime,0) + isNull(t2.cycle,0)
from
(select  mc,sum(DateDiff(second, mstTime, @Endtime)) cycle
from #T_autodata autodata 
where (autodata.msttime>=@StartTime)
and (autodata.msttime<@EndTime)
and (autodata.ndtime>@EndTime)
and (autodata.datatype=1)
group by autodata.mc
) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
-- Type 4
UPDATE #CockpitData SET UtilisedTime = isnull(UtilisedTime,0) + isnull(t2.cycle,0)
from
(select mc,
sum(DateDiff(second, @StartTime, @EndTime)) cycle from #T_autodata autodata --ER0374
where (autodata.msttime<@StartTime)
and (autodata.ndtime>@EndTime)
and (autodata.datatype=1)
group by autodata.mc
)as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
/* Fetching Down Records from Production Cycle  */
/* If Down Records of TYPE-2*/
UPDATE  #CockpitData SET UtilisedTime = isnull(UtilisedTime,0) - isNull(t2.Down,0)
FROM
(Select AutoData.mc ,
SUM(
CASE
	When autodata.sttime <= @StartTime Then datediff(s, @StartTime,autodata.ndtime )
	When autodata.sttime > @StartTime Then datediff(s , autodata.sttime,autodata.ndtime)
END) as Down
From #T_autodata AutoData INNER Join 
	(Select mc,Sttime,NdTime From #T_autodata AutoData
		Where DataType=1 And DateDiff(Second,sttime,ndtime)>CycleTime And
		(msttime < @StartTime)And (ndtime > @StartTime) AND (ndtime <= @EndTime)) as T1
ON AutoData.mc=T1.mc
Where AutoData.DataType=2
And ( autodata.Sttime > T1.Sttime )
And ( autodata.ndtime <  T1.ndtime )
AND ( autodata.ndtime >  @StartTime )
GROUP BY AUTODATA.mc)AS T2 Inner Join #CockpitData on t2.mc = #CockpitData.machineinterface
/* If Down Records of TYPE-3*/
UPDATE  #CockpitData SET UtilisedTime = isnull(UtilisedTime,0) - isNull(t2.Down,0)
FROM
(Select AutoData.mc ,
SUM(CASE
	When autodata.ndtime > @EndTime Then datediff(s,autodata.sttime, @EndTime )
	When autodata.ndtime <=@EndTime Then datediff(s , autodata.sttime,autodata.ndtime)
END) as Down 
From #T_autodata AutoData INNER Join 
	(Select mc,Sttime,NdTime From #T_autodata AutoData
		Where DataType=1 And DateDiff(Second,sttime,ndtime)>CycleTime And
		(sttime >= @StartTime)And (ndtime > @EndTime) and (sttime<@EndTime) ) as T1
ON AutoData.mc=T1.mc
Where AutoData.DataType=2
And (T1.Sttime < autodata.sttime  )
And ( T1.ndtime >  autodata.ndtime)
AND (autodata.sttime  <  @EndTime)
GROUP BY AUTODATA.mc)AS T2 Inner Join #CockpitData on t2.mc = #CockpitData.machineinterface
/* If Down Records of TYPE-4*/
UPDATE  #CockpitData SET UtilisedTime = isnull(UtilisedTime,0) - isNull(t2.Down,0)
FROM
(Select AutoData.mc ,
SUM(CASE
	When autodata.sttime >= @StartTime AND autodata.ndtime <= @EndTime Then datediff(s , autodata.sttime,autodata.ndtime)
	When autodata.sttime < @StartTime AND autodata.ndtime > @StartTime AND autodata.ndtime<=@EndTime Then datediff(s, @StartTime,autodata.ndtime )
	When autodata.sttime>=@StartTime And autodata.sttime < @EndTime AND autodata.ndtime > @EndTime Then datediff(s,autodata.sttime, @EndTime )
	When autodata.sttime<@StartTime AND autodata.ndtime>@EndTime   Then datediff(s , @StartTime,@EndTime)
--DR0236 - KarthikG - 19/Jun/2010 :: Till Here
END) as Down
From #T_autodata AutoData INNER Join --ER0374
	(Select mc,Sttime,NdTime From #T_autodata AutoData
		Where DataType=1 And DateDiff(Second,sttime,ndtime)>CycleTime And
		(msttime < @StartTime)And (ndtime > @EndTime) ) as T1
ON AutoData.mc=T1.mc
Where AutoData.DataType=2
And (T1.Sttime < autodata.sttime  )
And ( T1.ndtime >  autodata.ndtime)
AND (autodata.ndtime  >  @StartTime)
AND (autodata.sttime  <  @EndTime)
GROUP BY AUTODATA.mc
)AS T2 Inner Join #CockpitData on t2.mc = #CockpitData.machineinterface

--mod 4:Get utilised time over lapping with PDT.
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Ptime_4m_PLD')='Y'
BEGIN

	UPDATE #PLD set pPlannedDT =isnull(pPlannedDT,0) + isNull(TT.PPDT ,0)
	FROM(
		--Production Time in PDT
		SELECT autodata.MC,SUM
			(CASE
--			WHEN autodata.msttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN (autodata.cycletime+autodata.loadunload) --DR0325 Commented
			WHEN autodata.msttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN DateDiff(second,autodata.msttime,autodata.ndtime) --DR0325 Added
			WHEN ( autodata.msttime < T.StartTime  AND autodata.ndtime <= T.EndTime  AND autodata.ndtime > T.StartTime ) THEN DateDiff(second,T.StartTime,autodata.ndtime)
			WHEN ( autodata.msttime >= T.StartTime   AND autodata.msttime <T.EndTime  AND autodata.ndtime > T.EndTime  ) THEN DateDiff(second,autodata.msttime,T.EndTime )
			WHEN ( autodata.msttime < T.StartTime  AND autodata.ndtime > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END)  as PPDT
			FROM (select M.machineid,mc,msttime,ndtime from #T_autodata autodata
				inner join machineinformation M on M.interfaceid=Autodata.mc
				 where autodata.DataType=1 And 
				((autodata.msttime >= @starttime  AND autodata.ndtime <=@Endtime)
				OR ( autodata.msttime < @starttime  AND autodata.ndtime <= @Endtime AND autodata.ndtime > @starttime )
				OR ( autodata.msttime >= @starttime   AND autodata.msttime <@Endtime AND autodata.ndtime > @Endtime )
				OR ( autodata.msttime < @starttime  AND autodata.ndtime > @Endtime))
				)
		AutoData inner jOIN #PlannedDownTimes T on T.Machineid=AutoData.machineid
		WHERE 
			(
			(autodata.msttime >= T.StartTime  AND autodata.ndtime <=T.EndTime)
			OR ( autodata.msttime < T.StartTime  AND autodata.ndtime <= T.EndTime AND autodata.ndtime > T.StartTime )
			OR ( autodata.msttime >= T.StartTime   AND autodata.msttime <T.EndTime AND autodata.ndtime > T.EndTime )
			OR ( autodata.msttime < T.StartTime  AND autodata.ndtime > T.EndTime) )
		group by autodata.mc
	)
	 as TT INNER JOIN #PLD ON TT.mc = #PLD.MachineInterface


		--mod 4(4):Handle intearction between ICD and PDT for type 1 production record for the selected time period.
		UPDATE  #PLD set IPlannedDT =isnull(IPlannedDT,0) + isNull(T2.IPDT ,0) 	FROM	(
		Select T1.mc,SUM(
			CASE 	
				When T1.sttime >= T.StartTime  AND T1.ndtime <=T.EndTime  Then datediff(s , T1.sttime,T1.ndtime) ---type 1
				When T1.sttime < T.StartTime  and  T1.ndtime <= T.EndTime AND T1.ndtime > T.StartTime Then datediff(s, T.StartTime,T1.ndtime ) ---type 2
				When T1.sttime >= T.StartTime   AND T1.sttime <T.EndTime AND T1.ndtime > T.EndTime Then datediff(s, T1.sttime,T.EndTime ) ---type 3
				when T1.sttime < T.StartTime  AND T1.ndtime > T.EndTime Then datediff(s, T.StartTime,T.EndTime ) ---type 4
			END) as IPDT from
		(Select A.mc,(select machineid from machineinformation where interfaceid = A.mc)as machine, A.sttime, ndtime, A.datatype from #T_autodata A
		Where A.DataType=2
		and exists 
			(
			Select B.Sttime,B.NdTime,B.mc From #T_autodata B
			Where B.mc = A.mc and
			B.DataType=1 And DateDiff(Second,B.sttime,B.ndtime)> B.CycleTime And
			(B.msttime >= @starttime AND B.ndtime <= @Endtime) and
			--(B.sttime < A.sttime) AND (B.ndtime > A.ndtime) 
			  (B.sttime <= A.sttime) AND (B.ndtime >= A.ndtime)
			)
		 )as T1 inner join
		(select  machine,Case when starttime<@starttime then @starttime else starttime end as starttime, 
		case when endtime> @Endtime then @Endtime else endtime end as endtime from dbo.PlannedDownTimes 
		where ((( StartTime >=@starttime) And ( EndTime <=@Endtime))
		or (StartTime < @starttime  and  EndTime <= @Endtime AND EndTime > @starttime)
		or (StartTime >= @starttime  AND StartTime <@Endtime AND EndTime > @Endtime)
		or (( StartTime <@starttime) And ( EndTime >@Endtime )) )
		)T
		on T1.machine=T.machine AND
		((( T.StartTime >=T1.Sttime) And ( T.EndTime <=T1.ndtime ))
		or (T.StartTime < T1.Sttime  and  T.EndTime <= T1.ndtime AND T.EndTime > T1.Sttime)
		or (T.StartTime >= T1.Sttime   AND T.StartTime <T1.ndtime AND T.EndTime > T1.ndtime )
		or (( T.StartTime <T1.Sttime) And ( T.EndTime >T1.ndtime )) )group by T1.mc
		)AS T2  INNER JOIN #PLD ON T2.mc = #PLD.MachineInterface
		---mod 4(4)
	
	/* Fetching Down Records from Production Cycle  */
	/* If production  Records of TYPE-2*/
	UPDATE  #PLD set IPlannedDT =isnull(IPlannedDT,0) + isNull(T2.IPDT ,0) 	FROM	(
		Select T1.mc,SUM(
		CASE 	
			When T1.sttime >= T.StartTime  AND T1.ndtime <=T.EndTime  Then datediff(s , T1.sttime,T1.ndtime) ---type 1
			When T1.sttime < T.StartTime  and  T1.ndtime <= T.EndTime AND T1.ndtime > T.StartTime Then datediff(s, T.StartTime,T1.ndtime ) ---type 2
			When T1.sttime >= T.StartTime   AND T1.sttime <T.EndTime AND T1.ndtime > T.EndTime Then datediff(s, T1.sttime,T.EndTime ) ---type 3
			when T1.sttime < T.StartTime  AND T1.ndtime > T.EndTime Then datediff(s, T.StartTime,T.EndTime ) ---type 4
		END) as IPDT from
		(Select A.mc,(select machineid from machineinformation where interfaceid = A.mc)as machine, A.sttime, ndtime, A.datatype from #T_autodata A
		Where A.DataType=2
		and exists 
		(
		Select B.Sttime,B.NdTime From #T_autodata B
		Where B.mc = A.mc and
		B.DataType=1 And DateDiff(Second,B.sttime,B.ndtime)> B.CycleTime And
		(B.msttime < @StartTime And B.ndtime > @StartTime AND B.ndtime <= @EndTime) 
		And ((A.Sttime > B.Sttime) And ( A.ndtime < B.ndtime) AND ( A.ndtime > @StartTime ))
		)
		)as T1 inner join
		(select  machine,Case when starttime<@starttime then @starttime else starttime end as starttime, 
		case when endtime> @Endtime then @Endtime else endtime end as endtime from dbo.PlannedDownTimes 
		where ((( StartTime >=@starttime) And ( EndTime <=@Endtime))
		or (StartTime < @starttime  and  EndTime <= @Endtime AND EndTime > @starttime)
		or (StartTime >= @starttime  AND StartTime <@Endtime AND EndTime > @Endtime)
		or (( StartTime <@starttime) And ( EndTime >@Endtime )) )
		)T
		on T1.machine=T.machine AND
		(( T.StartTime >= @StartTime ) And ( T.StartTime <  T1.ndtime )) group by T1.mc
	)AS T2  INNER JOIN #PLD ON T2.mc = #PLD.MachineInterface
	
	/* If production Records of TYPE-3*/
	UPDATE  #PLD set IPlannedDT =isnull(IPlannedDT,0) + isNull(T2.IPDT ,0)FROM (
	Select T1.mc,SUM(
		CASE 	
			When T1.sttime >= T.StartTime  AND T1.ndtime <=T.EndTime  Then datediff(s , T1.sttime,T1.ndtime) ---type 1
			When T1.sttime < T.StartTime  and  T1.ndtime <= T.EndTime AND T1.ndtime > T.StartTime Then datediff(s, T.StartTime,T1.ndtime ) ---type 2
			When T1.sttime >= T.StartTime   AND T1.sttime <T.EndTime AND T1.ndtime > T.EndTime Then datediff(s, T1.sttime,T.EndTime ) ---type 3
			when T1.sttime < T.StartTime  AND T1.ndtime > T.EndTime Then datediff(s, T.StartTime,T.EndTime ) ---type 4
		END) as IPDT from
		(Select A.mc,(select machineid from machineinformation where interfaceid = A.mc)as machine, A.sttime, ndtime, A.datatype from #T_autodata A
		Where A.DataType=2
		and exists 
		(
		Select B.Sttime,B.NdTime From #T_autodata B
		Where B.mc = A.mc and
		B.DataType=1 And DateDiff(Second,B.sttime,B.ndtime)> B.CycleTime And
		(B.sttime >= @StartTime And B.ndtime > @EndTime and B.sttime <@EndTime) and
		((B.Sttime < A.sttime  )And ( B.ndtime > A.ndtime) AND (A.msttime < @EndTime))
		)
		)as T1 inner join
--		Inner join #PlannedDownTimes T
		(select  machine,Case when starttime<@starttime then @starttime else starttime end as starttime, 
		case when endtime> @Endtime then @Endtime else endtime end as endtime from dbo.PlannedDownTimes 
		where ((( StartTime >=@starttime) And ( EndTime <=@Endtime))
		or (StartTime < @starttime  and  EndTime <= @Endtime AND EndTime > @starttime)
		or (StartTime >= @starttime  AND StartTime <@Endtime AND EndTime > @Endtime)
		or (( StartTime <@starttime) And ( EndTime >@Endtime )) )
		)T
		on T1.machine=T.machine
		AND (( T.EndTime > T1.Sttime )And ( T.EndTime <=@EndTime )) group by T1.mc
		)AS T2  INNER JOIN #PLD ON T2.mc = #PLD.MachineInterface
	
	
	/* If production Records of TYPE-4*/
	UPDATE  #PLD set IPlannedDT =isnull(IPlannedDT,0) + isNull(T2.IPDT ,0)FROM (
	Select T1.mc,SUM(
	CASE 	
		When T1.sttime >= T.StartTime  AND T1.ndtime <=T.EndTime  Then datediff(s , T1.sttime,T1.ndtime) ---type 1
		When T1.sttime < T.StartTime  and  T1.ndtime <= T.EndTime AND T1.ndtime > T.StartTime Then datediff(s, T.StartTime,T1.ndtime ) ---type 2
		When T1.sttime >= T.StartTime   AND T1.sttime <T.EndTime AND T1.ndtime > T.EndTime Then datediff(s, T1.sttime,T.EndTime ) ---type 3
		when T1.sttime < T.StartTime  AND T1.ndtime > T.EndTime Then datediff(s, T.StartTime,T.EndTime ) ---type 4
	END) as IPDT from
	(Select A.mc,(select machineid from machineinformation where interfaceid = A.mc)as machine, A.sttime, ndtime, A.datatype from #T_autodata A
	Where A.DataType=2
	and exists 
	(
	Select B.Sttime,B.NdTime From #T_autodata B
	Where B.mc = A.mc and
	B.DataType=1 And DateDiff(Second,B.sttime,B.ndtime)> B.CycleTime And
	(B.msttime < @StartTime And B.ndtime > @EndTime)
	And ((B.Sttime < A.sttime)And ( B.ndtime >  A.ndtime)AND (A.ndtime  >  @StartTime) AND (A.sttime  <  @EndTime))
	)
	)as T1 inner join
		(select  machine,Case when starttime<@starttime then @starttime else starttime end as starttime, 
		case when endtime> @Endtime then @Endtime else endtime end as endtime from dbo.PlannedDownTimes 
		where ((( StartTime >=@starttime) And ( EndTime <=@Endtime))
		or (StartTime < @starttime  and  EndTime <= @Endtime AND EndTime > @starttime)
		or (StartTime >= @starttime  AND StartTime <@Endtime AND EndTime > @Endtime)
		or (( StartTime <@starttime) And ( EndTime >@Endtime )) )
		)T
		on T1.machine=T.machine AND
	(( T.StartTime >=@StartTime) And ( T.EndTime <=@EndTime )) group by T1.mc
	)AS T2  INNER JOIN #PLD ON T2.mc = #PLD.MachineInterface
  ------------------------------------ ER0374 Added Till Here ---------------------------------


END
--mod 4
/*******************************      Utilised Calculation Ends ***************************************************/
/*******************************Down Record***********************************/
--**************************************** ManagementLoss and Downtime Calculation Starts **************************************
---Below IF condition added by Mrudula for mod 4. TO get the ML if 'Ignore_Dtime_4m_PLD'<>"Y"
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='N' or ((SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'N' and (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'Y')
BEGIN
		-- Type 1
		UPDATE #CockpitData SET ManagementLoss = isnull(ManagementLoss,0) + isNull(t2.loss,0)
		from
		(select mc,sum(
		CASE
		WHEN (loadunload) > isnull(downcodeinformation.Threshold,0) and isnull(downcodeinformation.Threshold,0) > 0
		THEN isnull(downcodeinformation.Threshold,0)
		ELSE loadunload
		END) AS LOSS
		from #T_autodata autodata  --ER0374
		INNER JOIN downcodeinformation ON autodata.dcode = downcodeinformation.interfaceid
		where (autodata.msttime>=@StartTime)
		and (autodata.ndtime<=@EndTime)
		and (autodata.datatype=2)
		and (downcodeinformation.availeffy = 1) 
		and (downcodeinformation.ThresholdfromCO <>1) --NR0097
		group by autodata.mc) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
		-- Type 2
		UPDATE #CockpitData SET ManagementLoss = isnull(ManagementLoss,0) + isNull(t2.loss,0)
		from
		(select      mc,sum(
		CASE WHEN DateDiff(second, @StartTime, ndtime) > isnull(downcodeinformation.Threshold,0) and isnull(downcodeinformation.Threshold,0) > 0
		then isnull(downcodeinformation.Threshold,0)
		ELSE DateDiff(second, @StartTime, ndtime)
		END)loss
		--DateDiff(second, @StartTime, ndtime)
		from #T_autodata autodata  --ER0374
		INNER JOIN downcodeinformation ON autodata.dcode = downcodeinformation.interfaceid
		where (autodata.sttime<@StartTime)
		and (autodata.ndtime>@StartTime)
		and (autodata.ndtime<=@EndTime)
		and (autodata.datatype=2)
		and (downcodeinformation.availeffy = 1)
		and (downcodeinformation.ThresholdfromCO <>1) 
		group by autodata.mc
		) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
		-- Type 3
		UPDATE #CockpitData SET ManagementLoss = isnull(ManagementLoss,0) + isNull(t2.loss,0)
		from
		(select      mc,SUM(
		CASE WHEN DateDiff(second,stTime, @Endtime) > isnull(downcodeinformation.Threshold,0) and isnull(downcodeinformation.Threshold,0) > 0
		then isnull(downcodeinformation.Threshold,0)
		ELSE DateDiff(second, stTime, @Endtime)
		END)loss
		-- sum(DateDiff(second, stTime, @Endtime)) loss
		from #T_autodata autodata --ER0374
		INNER JOIN downcodeinformation ON autodata.dcode = downcodeinformation.interfaceid
		where (autodata.msttime>=@StartTime)
		and (autodata.sttime<@EndTime)
		and (autodata.ndtime>@EndTime)
		and (autodata.datatype=2)
		and (downcodeinformation.availeffy = 1)
		and (downcodeinformation.ThresholdfromCO <>1) --NR0097
		group by autodata.mc
		) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
		-- Type 4
		UPDATE #CockpitData SET ManagementLoss = isnull(ManagementLoss,0) + isNull(t2.loss,0)
		from
		(select mc,sum(
		CASE WHEN DateDiff(second, @StartTime, @Endtime) > isnull(downcodeinformation.Threshold,0) and isnull(downcodeinformation.Threshold,0) > 0
		then isnull(downcodeinformation.Threshold,0)
		ELSE DateDiff(second, @StartTime, @Endtime)
		END)loss
		--sum(DateDiff(second, @StartTime, @Endtime)) loss
		from #T_autodata autodata --ER0374
		INNER JOIN downcodeinformation ON autodata.dcode = downcodeinformation.interfaceid
		where autodata.msttime<@StartTime
		and autodata.ndtime>@EndTime
		and (autodata.datatype=2)
		and (downcodeinformation.availeffy = 1)
		and (downcodeinformation.ThresholdfromCO <>1) --NR0097
		group by autodata.mc
		) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
		---get the downtime for the time period
		UPDATE #CockpitData SET downtime = isnull(downtime,0) + isNull(t2.down,0)
		from
		(select mc,sum(
				CASE
				WHEN  autodata.msttime>=@StartTime  and  autodata.ndtime<=@EndTime  THEN  loadunload
				WHEN (autodata.sttime<@StartTime and  autodata.ndtime>@StartTime and autodata.ndtime<=@EndTime)  THEN DateDiff(second, @StartTime, ndtime)
				WHEN (autodata.msttime>=@StartTime  and autodata.sttime<@EndTime  and autodata.ndtime>@EndTime)  THEN DateDiff(second, stTime, @Endtime)
				WHEN autodata.msttime<@StartTime and autodata.ndtime>@EndTime   THEN DateDiff(second, @StartTime, @EndTime)
				END
			)AS down
		from #T_autodata autodata --ER0374
		inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		where autodata.datatype=2 AND
		(
		(autodata.msttime>=@StartTime  and  autodata.ndtime<=@EndTime)
		OR (autodata.sttime<@StartTime and  autodata.ndtime>@StartTime and autodata.ndtime<=@EndTime)
		OR (autodata.msttime>=@StartTime  and autodata.sttime<@EndTime  and autodata.ndtime>@EndTime)
		OR (autodata.msttime<@StartTime and autodata.ndtime>@EndTime )
		)
		group by autodata.mc
		) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface
--mod 4
End
--mod 4
---mod 4: Handling interaction between PDT and downtime . Also interaction between PDT and Management Loss
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='Y'
BEGIN
	---step 1
	
	UPDATE #CockpitData SET downtime = isnull(downtime,0) + isNull(t2.down,0)
	from
	(select mc,sum(
			CASE
	        WHEN  autodata.msttime>=@StartTime  and  autodata.ndtime<=@EndTime  THEN  loadunload
			WHEN (autodata.sttime<@StartTime and  autodata.ndtime>@StartTime and autodata.ndtime<=@EndTime)  THEN DateDiff(second, @StartTime, ndtime)
			WHEN (autodata.msttime>=@StartTime  and autodata.sttime<@EndTime  and autodata.ndtime>@EndTime)  THEN DateDiff(second, stTime, @Endtime)
			WHEN autodata.msttime<@StartTime and autodata.ndtime>@EndTime   THEN DateDiff(second, @StartTime, @EndTime)
			END
		)AS down
	from #T_autodata autodata --ER0374
	inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
	where autodata.datatype=2 AND
	(
	(autodata.msttime>=@StartTime  and  autodata.ndtime<=@EndTime)
	OR (autodata.sttime<@StartTime and  autodata.ndtime>@StartTime and autodata.ndtime<=@EndTime)
	OR (autodata.msttime>=@StartTime  and autodata.sttime<@EndTime  and autodata.ndtime>@EndTime)
	OR (autodata.msttime<@StartTime and autodata.ndtime>@EndTime )
	) AND (downcodeinformation.availeffy = 0)
	group by autodata.mc
	) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface

	UPDATE #PLD set dPlannedDT =isnull(dPlannedDT,0) + isNull(TT.PPDT ,0)
	FROM(
		--Production PDT
		SELECT autodata.MC, SUM
		   (CASE
			WHEN autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime  AND autodata.ndtime > T.StartTime ) THEN DateDiff(second,T.StartTime,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime  AND autodata.ndtime > T.EndTime  ) THEN DateDiff(second,autodata.sttime,T.EndTime )
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END ) as PPDT
		FROM #T_autodata AutoData --ER0374
		CROSS jOIN #PlannedDownTimes T inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND
			(
			(autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime)
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime AND autodata.ndtime > T.StartTime )
			OR ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime AND autodata.ndtime > T.EndTime )
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime)
			)
			 AND (downcodeinformation.availeffy = 0)
		group by autodata.mc
	) as TT INNER JOIN #PLD ON TT.mc = #PLD.MachineInterface
	
	UPDATE #CockpitData SET  ManagementLoss = isnull(ManagementLoss,0) + isNull(t4.Mloss,0),MLDown=isNull(MLDown,0)+isNull(t4.Dloss,0)
	from
	(select T3.mc,sum(T3.Mloss) as Mloss,sum(T3.Dloss) as Dloss from (
	select   t1.id,T1.mc,T1.Threshold,
	case when DateDiff(second,T1.sttime,T1.ndtime)-isnull(T2.PPDT,0)> isnull(T1.Threshold ,0) and isnull(T1.Threshold ,0)>0
	then DateDiff(second,T1.sttime,T1.ndtime)-isnull(T2.PPDT,0)- isnull(T1.Threshold ,0)
	else 0 End  as Dloss,
	case when DateDiff(second,T1.sttime,T1.ndtime)-isnull(T2.PPDT,0)> isnull(T1.Threshold ,0) and isnull(T1.Threshold ,0)>0
	then isnull(T1.Threshold,0)
	else (DateDiff(second,T1.sttime,T1.ndtime)-isnull(T2.PPDT,0)) End  as Mloss
	 from
	
	(   select id,mc,comp,opn,opr,D.threshold,
		case when autodata.sttime<@StartTime then @StartTime else sttime END as sttime,
	       	case when ndtime>@EndTime then @EndTime else ndtime END as ndtime
		from #T_autodata autodata --ER0374
		inner join downcodeinformation D
		on autodata.dcode=D.interfaceid where autodata.datatype=2 AND
		(
		(autodata.sttime>=@StartTime  and  autodata.ndtime<=@EndTime)
		OR (autodata.sttime<@StartTime and  autodata.ndtime>@StartTime and autodata.ndtime<=@EndTime)
		OR (autodata.sttime>=@StartTime  and autodata.sttime<@EndTime  and autodata.ndtime>@EndTime)
		OR (autodata.sttime<@StartTime and autodata.ndtime>@EndTime )
		) AND (D.availeffy = 1) 		
		and (D.ThresholdfromCO <>1)) as T1 	 --NR0097
	left outer join
	(SELECT autodata.id,
		       sum(CASE
			WHEN autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime  AND autodata.ndtime > T.StartTime ) THEN DateDiff(second,T.StartTime,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime  AND autodata.ndtime > T.EndTime  ) THEN DateDiff(second,autodata.sttime,T.EndTime )
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END ) as PPDT
		FROM #T_autodata AutoData --ER0374
		CROSS jOIN #PlannedDownTimes T inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND
			(
			(autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime)
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime AND autodata.ndtime > T.StartTime )
			OR ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime AND autodata.ndtime > T.EndTime )
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime)
			)
			AND (downcodeinformation.availeffy = 1) 
			AND (downcodeinformation.ThresholdfromCO <>1) --NR0097 
			group  by autodata.id ) as T2 on T1.id=T2.id ) as T3  group by T3.mc
	) as t4 inner join #CockpitData on t4.mc = #CockpitData.machineinterface


	---mod 4 checking for (downcodeinformation.availeffy = 1) to get the overlapping PDT and Downs which is ML
	UPDATE #PLD set MPlannedDT =isnull(MPlannedDT,0) + isNull(TT.PPDT ,0)
	FROM(
		--Production PDT
		SELECT autodata.MC, SUM
		   (CASE
			WHEN autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime  AND autodata.ndtime > T.StartTime ) THEN DateDiff(second,T.StartTime,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime  AND autodata.ndtime > T.EndTime  ) THEN DateDiff(second,autodata.sttime,T.EndTime )
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END ) as PPDT
		FROM #T_autodata AutoData --ER0374
		CROSS jOIN #PlannedDownTimes T inner join downcodeinformation on autodata.dcode=downcodeinformation.interfaceid
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND
			(
			(autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime)
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime AND autodata.ndtime > T.StartTime )
			OR ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime AND autodata.ndtime > T.EndTime )
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime)
			)
			 AND (downcodeinformation.availeffy = 1) 
			AND (downcodeinformation.ThresholdfromCO <>1) --NR0097 
		group by autodata.mc
	) as TT INNER JOIN #PLD ON TT.mc = #PLD.MachineInterface

	UPDATE #CockpitData SET downtime = isnull(downtime,0)+isnull(ManagementLoss,0)+isNull(MLDown,0)
	
END


---mod 4: Till here Handling interaction between PDT and downtime . Also interaction between PDT and Management Loss
---mod 4:If Ignore_Dtime_4m_PLD<> Y and Ignore_Dtime_4m_PLD<> N
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'Y' AND (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'N'
BEGIN
	UPDATE #PLD set dPlannedDT =isnull(dPlannedDT,0) + isNull(TT.PPDT ,0)
	FROM(
		--Production PDT
		SELECT autodata.MC, SUM
		       (CASE
			WHEN autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime  AND autodata.ndtime > T.StartTime ) THEN DateDiff(second,T.StartTime,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime  AND autodata.ndtime > T.EndTime  ) THEN DateDiff(second,autodata.sttime,T.EndTime )
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END ) as PPDT
		FROM #T_autodata AutoData  
		CROSS jOIN #PlannedDownTimes T
		Inner Join DownCodeInformation D ON AutoData.DCode = D.InterfaceID
		WHERE autodata.DataType=2 AND T.MachineInterface=autodata.mc AND D.DownID=(SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD') AND
			(
			(autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime)
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime AND autodata.ndtime > T.StartTime )
			OR ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime AND autodata.ndtime > T.EndTime )
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime)
			)
		group by autodata.mc
	) as TT INNER JOIN #PLD ON TT.mc = #PLD.MachineInterface
END
---mod 4:If Ignore_Dtime_4m_PLD<> Y and Ignore_Dtime_4m_PLD<> N
--************************************ Down and Management  Calculation Ends ******************************************
---mod 4
-- Get the value of CN
-- Type 1


UPDATE #CockpitData SET CN = isnull(CN,0) + isNull(t2.C1N1,0)
from
(select mc,
SUM((componentoperationpricing.cycletime/ISNULL(componentoperationpricing.SubOperations,1))* autodata.partscount) C1N1
FROM  #T_autodata autodata
INNER JOIN machineinformation on machineinformation.interfaceid=autodata.mc INNER join
componentinformation ON autodata.comp = componentinformation.InterfaceID INNER JOIN 
ComponentOperationPricing  ON autodata.Opn=ComponentOperationPricing.interfaceid AND 
componentinformation.Componentid=ComponentOperationPricing.componentid  and componentoperationpricing.machineid=machineinformation.machineid
where (((autodata.sttime>=@StartTime)and (autodata.ndtime<=@EndTime)) or
((autodata.sttime<@StartTime)and (autodata.ndtime>@StartTime)and (autodata.ndtime<=@EndTime)) )
and (autodata.datatype=1)
group by autodata.mc
) as t2 inner join #CockpitData on t2.mc = #CockpitData.machineinterface

-- mod 4 Ignore count from CN calculation which is over lapping with PDT

If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN
	UPDATE #CockpitData SET CN = isnull(CN,0) - isNull(t2.C1N1,0)
	From
	(
		select mc,SUM((O.cycletime * ISNULL(Autodata.PartsCount,1))/ISNULL(O.SubOperations,1))  C1N1
		From #T_autodata autodata 
		Inner join machineinformation M on M.interfaceid=autodata.mc
		Inner join componentinformation C ON autodata.Comp=C.interfaceid
		Inner join ComponentOperationPricing O ON autodata.Opn=O.interfaceid AND C.Componentid=O.componentid And O.MachineID = M.MachineID
		Cross jOIN #PlannedDownTimes T
		WHERE autodata.DataType=1 AND T.MachineInterface=autodata.mc
		AND(Autodata.ndtime > T.StartTime  AND Autodata.ndtime <=T.EndTime)
		AND(Autodata.ndtime > @StartTime  AND Autodata.ndtime <=@EndTime)
		Group by mc
	) as T2
	inner join #CockpitData  on t2.mc = #CockpitData.machineinterface
END

--Mod 4
--Calculation of PartsCount Begins..
UPDATE #CockpitData SET components = ISNULL(components,0) + ISNULL(t2.comp,0)
From
(
	--Select mc,SUM(CEILING (CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) As Comp --NR0097
	  Select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) As Comp --NR0097
		   From (select mc,SUM(autodata.partscount)AS OrginalCount,comp,opn 
			from #T_autodata autodata --ER0374
		   where (autodata.ndtime>@StartTime) and (autodata.ndtime<=@EndTime) and (autodata.datatype=1)
		   Group By mc,comp,opn) as T1
	Inner join componentinformation C on T1.Comp = C.interfaceid
	Inner join ComponentOperationPricing O ON  T1.Opn = O.interfaceid and C.Componentid=O.componentid
	---mod 2
	inner join machineinformation on machineinformation.machineid =O.machineid
	and T1.mc=machineinformation.interfaceid
	---mod 2
	GROUP BY mc
) As T2 Inner join #CockpitData on T2.mc = #CockpitData.machineinterface



--Mod 4 Apply PDT for calculation of Count
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN
	UPDATE #CockpitData SET components = ISNULL(components,0) - ISNULL(T2.comp,0) from(
		--select mc,SUM(CEILING (CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) as comp From ( --NR0097
		select mc,SUM((CAST(T1.OrginalCount AS Float)/ISNULL(O.SubOperations,1))) as comp From ( --NR0097
			select mc,Sum(ISNULL(PartsCount,1))AS OrginalCount,comp,opn 
			from #T_autodata autodata --ER0374
			CROSS JOIN #PlannedDownTimes T
			WHERE autodata.DataType=1 And T.MachineInterface = autodata.mc
			AND (autodata.ndtime > T.StartTime  AND autodata.ndtime <=T.EndTime)
			AND (autodata.ndtime > @StartTime  AND autodata.ndtime <=@EndTime)
		    Group by mc,comp,opn
		) as T1
	Inner join Machineinformation M on M.interfaceID = T1.mc
	Inner join componentinformation C on T1.Comp=C.interfaceid
	Inner join ComponentOperationPricing O ON T1.Opn=O.interfaceid and C.Componentid=O.componentid and O.MachineID = M.MachineID
	GROUP BY MC
	) as T2 inner join #CockpitData on T2.mc = #CockpitData.machineinterface
END


UPDATE #CockpitData
	SET UtilisedTime=(UtilisedTime-ISNULL(#PLD.pPlannedDT,0)+isnull(#PLD.IPlannedDT,0)),
	   DownTime=(DownTime-ISNULL(#PLD.dPlannedDT,0)) 
	From #CockpitData Inner Join #PLD on #PLD.Machineid=#CockpitData.Machineid



---- Calculate efficiencies

UPDATE #CockpitData
SET
	TotalTime = DateDiff(SECOND, @StartTime, @EndTime)

UPDATE #CockpitData
SET
	ProductionEfficiency = (CN/UtilisedTime) ,
	AvailabilityEfficiency = (UtilisedTime)/(UtilisedTime + DownTime - ManagementLoss) 
WHERE UtilisedTime <> 0


--NR0090 From Here
If (SELECT ValueInText From CockpitDefaults Where Parameter ='DisplayTTFormat')='Display TotalTime - Less PDT' 
BEGIN
	UPDATE #CockpitData SET TotalTime = Totaltime - isnull(T1.PDT,0) 
	from
	(Select Machine,SUM(datediff(S,Starttime,endtime))as PDT from Planneddowntimes
	 where starttime>=@starttime and endtime<=@endtime group by machine)T1
	 Inner Join #CockpitData on T1.Machine=#CockpitData.Machineid WHERE UtilisedTime <> 0	
----------------------------------- DR0330 Till Here -----------------------------------------------------
END

	UPDATE #CockpitData SET PDTInDays =ISNULL(pdt,0)
	from
	(Select MachineID,SUM(datediff(day,Starttime,endtime))as PDT from #PlannedDownTimes
	 where starttime>=@starttime and endtime<=@endtime group by MachineID)T1
	 Inner Join #CockpitData on T1.MachineID=#CockpitData.Machineid WHERE UtilisedTime <> 0	


CREATE TABLE #DownTimeData
(
	MachineID nvarchar(50) NOT NULL,
	McInterfaceid nvarchar(50), --ER0459
	DownID nvarchar(50) NOT NULL,
	DownTime float,
	DownFreq int
)
ALTER TABLE #DownTimeData
	ADD PRIMARY KEY CLUSTERED
	(
		[MachineId], [DownID]
	)ON [PRIMARY]

select @strsql = ''
select @strsql = 'INSERT INTO #DownTimeData (MachineID,McInterfaceid, DownID, DownTime,DownFreq) SELECT Machineinformation.MachineID AS MachineID,Machineinformation.interfaceid, downcodeinformation.downid AS DownID, 0,0'
select @strsql = @strsql+' FROM Machineinformation CROSS JOIN downcodeinformation LEFT OUTER JOIN PlantMachine ON PlantMachine.MachineID=Machineinformation.MachineID 
LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID '
select @strsql = @strsql+' Where MachineInformation.interfaceid > ''0'' '
select @strsql = @strsql + @strPlantID +@strmachine + @StrTPMMachines + @StrGroupID + ' ORDER BY  downcodeinformation.downid, Machineinformation.MachineID'
exec (@strsql)
--********************************************* Get Down Time Details *******************************************************
--Type 1,2,3 and 4.
select @strsql = ''
select @strsql = @strsql + 'UPDATE #DownTimeData SET downtime = isnull(DownTime,0) + isnull(t2.down,0) '
select @strsql = @strsql + ' FROM'
select @strsql = @strsql + ' (SELECT mc,--count(mc)as dwnfrq,
SUM(CASE
WHEN (autodata.sttime>='''+convert(varchar(20),@starttime)+''' and autodata.ndtime<='''+convert(varchar(20),@endtime)+''' ) THEN loadunload
WHEN (autodata.sttime<'''+convert(varchar(20),@starttime)+''' and autodata.ndtime>'''+convert(varchar(20),@starttime)+'''and autodata.ndtime<='''+convert(varchar(20),@endtime)+''') THEN DateDiff(second, '''+convert(varchar(20),@StartTime)+''', ndtime)
WHEN (autodata.sttime>='''+convert(varchar(20),@starttime)+'''and autodata.sttime<'''+convert(varchar(20),@endtime)+''' and autodata.ndtime>'''+convert(varchar(20),@endtime)+''') THEN DateDiff(second, stTime, '''+convert(varchar(20),@Endtime)+''')
ELSE DateDiff(second,'''+convert(varchar(20),@starttime)+''','''+convert(varchar(20),@endtime)+''')
END) as down
,downcodeinformation.downid as downid'
select @strsql = @strsql + ' from'
select @strsql = @strsql + ' #T_autodata autodata INNER JOIN' --ER0374
select @strsql = @strsql + ' machineinformation ON autodata.mc = machineinformation.InterfaceID 
Left Outer Join PlantMachine ON PlantMachine.MachineID=machineinformation.MachineID 
LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID
INNER JOIN'
select @strsql = @strsql + ' componentinformation ON autodata.comp = componentinformation.InterfaceID INNER JOIN'
select @strsql = @strsql + ' employeeinformation ON autodata.opr = employeeinformation.interfaceid INNER JOIN'
select @strsql = @strsql + ' downcodeinformation ON autodata.dcode = downcodeinformation.interfaceid'
select @strsql = @strsql + ' where  datatype=2 AND ((autodata.sttime>='''+convert(varchar(20),@starttime)+''' and autodata.ndtime<='''+convert(varchar(20),@endtime)+''' )OR
(autodata.sttime<'''+convert(varchar(20),@starttime)+''' and autodata.ndtime>'''+convert(varchar(20),@starttime)+'''and autodata.ndtime<='''+convert(varchar(20),@endtime)+''')OR
(autodata.sttime>='''+convert(varchar(20),@starttime)+'''and autodata.sttime<'''+convert(varchar(20),@endtime)+''' and autodata.ndtime>'''+convert(varchar(20),@endtime)+''')OR
(autodata.sttime<'''+convert(varchar(20),@starttime)+''' and autodata.ndtime>'''+convert(varchar(20),@endtime)+'''))'
select @strsql = @strsql  + @strPlantID + @strmachine + @StrGroupID
select @strsql = @strsql + ' group by autodata.mc,downcodeinformation.downid )'
select @strsql = @strsql + ' as t2 inner join #DownTimeData on t2.mc=#DownTimeData.McInterfaceid and t2.downid=#DownTimeData.downid'
exec (@strsql)
--*********************************************************************************************************************
--mod 4
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')='Y'
BEGIN
	UPDATE #DownTimeData set DownTime =isnull(DownTime,0) - isNull(TT.PPDT ,0)
	FROM(
		--Production PDT
		SELECT autodata.MC,DownID, SUM
		       (CASE
			WHEN autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime  AND autodata.ndtime > T.StartTime ) THEN DateDiff(second,T.StartTime,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime  AND autodata.ndtime > T.EndTime  ) THEN DateDiff(second,autodata.sttime,T.EndTime )
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END ) as PPDT
		FROM #T_autodata AutoData --ER0374
		CROSS jOIN #PlannedDownTimes T
		Inner Join DownCodeInformation On AutoData.DCode=DownCodeInformation.InterfaceID
		WHERE autodata.DataType=2 AND T.MachineInterface = AutoData.mc And
			(
			(autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime)
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime AND autodata.ndtime > T.StartTime )
			OR ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime AND autodata.ndtime > T.EndTime )
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime)
			)
		group by autodata.mc,DownID
	) as TT INNER JOIN #DownTimeData ON TT.mc = #DownTimeData.McInterfaceid AND #DownTimeData.DownID=TT.DownId
	Where #DownTimeData.DownTime>0
END
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'Y' AND (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'N'
BEGIN
	UPDATE #DownTimeData set DownTime =isnull(DownTime,0) - isNull(TT.PPDT ,0)
	FROM(
		--Production PDT
		SELECT autodata.MC,DownId, SUM
		       (CASE
			WHEN autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime  THEN (autodata.loadunload)
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime  AND autodata.ndtime > T.StartTime ) THEN DateDiff(second,T.StartTime,autodata.ndtime)
			WHEN ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime  AND autodata.ndtime > T.EndTime  ) THEN DateDiff(second,autodata.sttime,T.EndTime )
			WHEN ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END ) as PPDT
		FROM #T_autodata AutoData --ER0374
		CROSS jOIN #PlannedDownTimes T
		Inner Join DownCodeInformation D ON AutoData.DCode = D.InterfaceID
		WHERE autodata.DataType=2 And T.MachineInterface = AutoData.mc AND D.DownID=(SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD') AND
			(
			(autodata.sttime >= T.StartTime  AND autodata.ndtime <=T.EndTime)
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime <= T.EndTime AND autodata.ndtime > T.StartTime )
			OR ( autodata.sttime >= T.StartTime   AND autodata.sttime <T.EndTime AND autodata.ndtime > T.EndTime )
			OR ( autodata.sttime < T.StartTime  AND autodata.ndtime > T.EndTime)
			)
		group by autodata.mc,DownId
	) as TT INNER JOIN #DownTimeData ON TT.mc = #DownTimeData.McInterfaceid AND #DownTimeData.DownID=TT.DownId
	Where #DownTimeData.DownTime>0
END


Update #CockpitData SET MaxDownReason = MaxDownReasonTime
From (select A.MachineID as MachineID,
SUBSTRING(MAx(A.DownID),1,6)+ '-'+ SUBSTRING(dbo.f_FormatTime(A.DownTime,'hh:mm:ss'),1,5) as MaxDownReasonTime
FROM #DownTimeData A
INNER JOIN (SELECT B.machineid,MAX(B.DownTime)as DownTime FROM #DownTimeData B group by machineid) as T2
ON A.MachineId = T2.MachineId and A.DownTime = t2.DownTime
Where A.DownTime > 0
group by A.MachineId,A.DownTime)as T3 inner join #CockpitData on T3.MachineID = #CockpitData.MachineID
---mod 4



Update #Cockpitdata set RejCount = isnull(RejCount,0) + isnull(T1.RejQty,0)
From
( Select A.mc,SUM(A.Rejection_Qty) as RejQty,M.Machineid from AutodataRejections A
inner join Machineinformation M on A.mc=M.interfaceid
inner join #Cockpitdata on #Cockpitdata.machineid=M.machineid 
inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid
where A.CreatedTS>=@StartTime and A.CreatedTS<@Endtime and A.flag = 'Rejection'
and Isnull(A.Rejshift,'a')='a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'
group by A.mc,M.Machineid
)T1 inner join #Cockpitdata B on B.Machineid=T1.Machineid 

If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN
	Update #Cockpitdata set RejCount = isnull(RejCount,0) - isnull(T1.RejQty,0) from
	(Select A.mc,SUM(A.Rejection_Qty) as RejQty,M.Machineid from AutodataRejections A
	inner join Machineinformation M on A.mc=M.interfaceid
	inner join #Cockpitdata on #Cockpitdata.machineid=M.machineid 
	inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid
	Cross join Planneddowntimes P
	where P.PDTStatus =1 and A.flag = 'Rejection' and P.machine=M.Machineid 
	and Isnull(A.Rejshift,'a')='a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000' and
	A.CreatedTS>=@StartTime and A.CreatedTS<@Endtime And
	A.CreatedTS>=P.Starttime and A.CreatedTS<P.endtime
	group by A.mc,M.Machineid)T1 inner join #Cockpitdata B on B.Machineid=T1.Machineid 
END

Update #Cockpitdata set RejCount = isnull(RejCount,0) + isnull(T1.RejQty,0)
From
( Select A.mc,SUM(A.Rejection_Qty) as RejQty,M.Machineid from AutodataRejections A
inner join Machineinformation M on A.mc=M.interfaceid
inner join #Cockpitdata on #Cockpitdata.machineid=M.machineid 
inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid
inner join #shift S on convert(nvarchar(10),(A.RejDate),126)=CONVERT(NVARCHAR(10),S.shiftdate,126) and A.RejShift=S.shiftid --DR0333
where A.flag = 'Rejection' and A.Rejshift in (S.shiftid) and convert(nvarchar(10),(A.RejDate),126) in (CONVERT(nvarchar(10),(S.shiftdate),126)) and  --DR0333
Isnull(A.Rejshift,'a')<>'a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')<>'1900-01-01 00:00:00.000'
group by A.mc,M.Machineid
)T1 inner join #Cockpitdata B on B.Machineid=T1.Machineid 

If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN
	Update #Cockpitdata set RejCount = isnull(RejCount,0) - isnull(T1.RejQty,0) from
	(Select A.mc,SUM(A.Rejection_Qty) as RejQty,M.Machineid from AutodataRejections A
	inner join Machineinformation M on A.mc=M.interfaceid
	inner join #Cockpitdata on #Cockpitdata.machineid=M.machineid 
	inner join Rejectioncodeinformation R on A.Rejection_code=R.interfaceid
	inner join #shift S on convert(nvarchar(10),(A.RejDate),126)=CONVERT(NVARCHAR(10),S.shiftdate,126) and A.RejShift=S.shiftid --DR0333
	Cross join Planneddowntimes P
	where P.PDTStatus =1 and A.flag = 'Rejection' and P.machine=M.Machineid and
	A.Rejshift in (S.shiftid) and convert(nvarchar(10),(A.RejDate),126) in (CONVERT(nvarchar(10),(S.shiftdate),126)) and --DR0333
	Isnull(A.Rejshift,'a')<>'a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')<>'1900-01-01 00:00:00.000'
	and P.starttime>=S.Shiftstart and P.Endtime<=S.shiftend
	group by A.mc,M.Machineid)T1 inner join #Cockpitdata B on B.Machineid=T1.Machineid 
END

Update #Cockpitdata set ReworkCount = isnull(B.ReworkCount,0) + isnull(T1.ReworkCount,0)
From
( Select A.mc,SUM(A.Rejection_Qty) as ReworkCount,M.Machineid from AutodataRejections A
inner join Machineinformation M on A.mc=M.interfaceid
inner join #Cockpitdata on #Cockpitdata.machineid=M.machineid 
inner join Reworkinformation R on A.Rejection_code=R.Reworkinterfaceid
where A.CreatedTS>=@StartTime and A.CreatedTS<@Endtime and A.flag = 'MarkedforRework'
and Isnull(A.Rejshift,'a')='a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'
group by A.mc,M.Machineid
)T1 inner join #Cockpitdata B on B.Machineid=T1.Machineid 

If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN
	Update #Cockpitdata set ReworkCount = isnull(B.ReworkCount,0) - isnull(T1.ReworkCount,0) from
	(Select A.mc,SUM(A.Rejection_Qty) as ReworkCount,M.Machineid from AutodataRejections A
	inner join Machineinformation M on A.mc=M.interfaceid
	inner join #Cockpitdata on #Cockpitdata.machineid=M.machineid 
	inner join Reworkinformation R on A.Rejection_code=R.Reworkinterfaceid
	Cross join Planneddowntimes P
	where P.PDTStatus =1 and A.flag = 'MarkedforRework' and P.machine=M.Machineid 
	and Isnull(A.Rejshift,'a')='a' and Isnull(A.RejDate,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000' and
	A.CreatedTS>=@StartTime and A.CreatedTS<@Endtime And
	A.CreatedTS>=P.Starttime and A.CreatedTS<P.endtime
	group by A.mc,M.Machineid)T1 inner join #Cockpitdata B on B.Machineid=T1.Machineid 
END



UPDATE #Cockpitdata SET QualityEfficiency= ISNULL(QualityEfficiency,1) + IsNull(T1.QE,1) 
FROM(Select MachineID,
CAST((Sum(Components))As Float)/CAST((Sum(IsNull(Components,0))+Sum(IsNull(RejCount,0))) AS Float)As QE
From #Cockpitdata Where Components<>0 Group By MachineID
)AS T1 Inner Join #Cockpitdata ON  #Cockpitdata.MachineID=T1.MachineID

UPDATE #CockpitData
SET
	OverAllEfficiency = (ProductionEfficiency * AvailabilityEfficiency * ISNULL(QualityEfficiency,1))*100,
	ProductionEfficiency = ProductionEfficiency * 100 ,
	AvailabilityEfficiency = AvailabilityEfficiency * 100,
	QualityEfficiency = QualityEfficiency*100

------------------------------------------------------------- MachineRunningStatus Cal starts-----------------------------------------------------------------------------------------------------------------

Declare @Type40Threshold int
Declare @Type1Threshold int
Declare @Type11Threshold int

Set @Type40Threshold =0
Set @Type1Threshold = 0
Set @Type11Threshold = 0

Set @Type40Threshold = (Select isnull(Valueintext2,5)*60 from shopdefaults where parameter='ANDONStatusThreshold' and valueintext = 'Type40Threshold')
Set @Type1Threshold = (Select isnull(Valueintext2,5)*60 from shopdefaults where parameter='ANDONStatusThreshold' and valueintext = 'Type1Threshold')
Set @Type11Threshold = (Select isnull(Valueintext2,5)*60 from shopdefaults where parameter='ANDONStatusThreshold' and valueintext = 'Type11Threshold')
print @Type40Threshold
print @Type1Threshold
print @Type11Threshold


Insert into #machineRunningStatus(MachineID,MachineInterface,sttime,ndtime,datatype,Colorcode)     
select fd.MachineID,fd.MachineInterface,sttime,ndtime,datatype,ColorCode from MachineRunningStatus mr    
right outer join #CockpitData fd on fd.MachineInterface = mr.MachineInterface
where sttime<@currtime and isnull(ndtime,'1900-01-01')<@currtime
order by fd.MachineInterface
-----ER0464 --g: using MachineRunningStatus table instead of rawdata  


update #machineRunningStatus set ColorCode = case when (datediff(second,sttime,@CurrTime)- @Type11Threshold)>0  then 'Red' else 'Green' end where datatype in (11)
update #machineRunningStatus set ColorCode = 'Green' where datatype in (41)
update #machineRunningStatus set ColorCode = 'Red' where datatype in (42,2)

update #machineRunningStatus set ColorCode = t1.ColorCode from (
Select mrs.MachineID,Case when (
case when datatype = 40 then datediff(second,sttime,@CurrTime)- @Type40Threshold
when datatype = 1 then datediff(second,ndtime,@CurrTime)- @Type1Threshold
end) > 0 then 'Red' else 'Green' end as ColorCode
from #machineRunningStatus mrs 
where  datatype in (40,1)
) as t1 inner join #machineRunningStatus on t1.MachineID = #machineRunningStatus.MachineID

update #machineRunningStatus set ColorCode ='Red' where isnull(sttime,'1900-01-01')='1900-01-01'

update #CockpitData set Remarks1 = T1.MCStatus from 
(select Machineid,
Case when Colorcode='White' then 'Stopped'
when Colorcode='Red' then 'Stopped'
when Colorcode='Green' then 'Running' end as MCStatus from #machineRunningStatus)T1
inner join #CockpitData on T1.MachineID = #CockpitData.MachineID

------------------------------------------------------------- MachineRunningStatus Cal starts-----------------------------------------------------------------------------------------------------------------


---------------------------------- Added to handle Machine Status for Focas Machines ----------------------------------

Select @strsql=''
Select @strsql = @strsql + 'Insert into  #MachineOnlineStatus(Machineid,LastConnectionOKTime,LastConnectionFailedTime,LastPingFailedTime,LastPingOkTime,LastPLCCommunicationOK,LastPLCCommunicationFailed)
select MachineOnlineStatus.Machineid,Max(LastConnectionOKTime) as LastConnectionOKTime,Max(LastConnectionFailedTime) as LastConnectionFailedTime,
Max(LastPingFailedTime) as LastPingFailedTime,Max(LastPingOkTime)as LastPingOkTime,
MAX(LastPLCCommunicationOK),MAX(LastPLCCommunicationFailed) from MachineOnlineStatus
inner join machineinformation on machineinformation.machineid = MachineOnlineStatus.machineid 
inner join plantmachine on machineinformation.machineid=plantmachine.machineid
where machineinformation.TPMTrakEnabled=1 and machineinformation.DNCTransferEnabled=0 '
SET @strSql =  @strSql + @strMachine + @strPlantID
SET @strSql =  @strSql + ' group by MachineOnlineStatus.MachineID'
EXEC(@strSql)

update #MachineRunningStatus set PingStatus = T1.PingStatus from
(select Machineid,
Case when ISNULL(LastPingOkTime,'1900-01-01')>ISNULL(LastPingFailedTime,'1900-01-01') then 'OK' else 'NOT OK' end as PingStatus
from #MachineOnlineStatus
)T1 inner join #machineRunningStatus on T1.MachineID = #machineRunningStatus.MachineID

insert into #Focas_MachineRunningStatus(Machineid,Datatype,LastCycleTS,AlarmStatus,SpindleCycleTS,SpindleStatus,PowerOnOrOff)
select distinct machineinformation.machineid,Datatype,LastCycleTS,AlarmStatus,SpindleCycleTS,SpindleStatus,PowerOnOrOff from machineinformation 
left join Focas_MachineRunningStatus F on machineinformation.machineid=F.machineid
inner join plantmachine on machineinformation.machineid=plantmachine.machineid
where machineinformation.TPMTrakEnabled=1 and machineinformation.DNCTransferEnabled=1

update #Focas_MachineRunningStatus set Machinestatus=T.Machinestatus from
(select machineid, 
Case 
when AlarmStatus not in('Alarm','Emergency') and PowerOnOrOff=1 and Datatype=1 and datediff(second,LastCycleTS,@CurrTime)- @Type1Threshold>0 then 'Down'
when AlarmStatus not in('Alarm','Emergency') and PowerOnOrOff=1 and Datatype=2 then 'Down'
when AlarmStatus not in('Alarm','Emergency') and PowerOnOrOff=1 and Datatype=11 and SpindleStatus=2 and datediff(second,SpindleCycleTS,@CurrTime)- @Type40Threshold>0  and datediff(second,LastCycleTS,@CurrTime)>10 then 'ICD'
when AlarmStatus not in('Alarm','Emergency') and PowerOnOrOff=1 and Datatype=11 and datediff(second,LastCycleTS,@CurrTime)<=10 then 'Running'
when AlarmStatus not in('Alarm','Emergency') and PowerOnOrOff=1 and Datatype=11 and SpindleStatus=1 then 'Running'
when AlarmStatus in('Alarm') and PowerOnOrOff=1 then 'Alarm'
when AlarmStatus in('Emergency') and PowerOnOrOff=1 then 'Emergency'
when AlarmStatus not in('Alarm','Emergency') and PowerOnOrOff=1 and Datatype=1 and datediff(second,LastCycleTS,@CurrTime)<@Type1Threshold then 'Load Unload'
when AlarmStatus not in('Alarm','Emergency') and PowerOnOrOff=2 then 'Disconnected'
END as Machinestatus
from #Focas_MachineRunningStatus
)T inner join #Focas_MachineRunningStatus on T.Machineid=#Focas_MachineRunningStatus.Machineid

update #CockPitData set MachineLiveStatus=T.Machinestatus from
(select #MachineRunningStatus.Machineid, 
Case 
when Datatype in(2,42,22) then 'Down'
when Datatype=40 and datediff(second,sttime,@CurrTime)- @Type40Threshold>0 then 'ICD'
when Datatype=11 and (datediff(second,sttime,@CurrTime)<=@Type11Threshold) then 'Running' 
when Datatype=41 then 'Running'
when Datatype=1 and datediff(second,ndtime,@CurrTime)<@Type1Threshold then 'Load Unload'
when PingStatus='NOT OK' then 'Disconnected'
END as Machinestatus
from #MachineRunningStatus
inner join Machineinformation on  machineinformation.machineid=#MachineRunningStatus.machineid
where machineinformation.TPMTrakEnabled=1 and machineinformation.DNCTransferEnabled=0
)T inner join #CockPitData on T.Machineid=#CockPitData.Machineid

update #CockPitData set MachineLiveStatus=T.Machinestatus from
(select Machineid,machinestatus from #Focas_MachineRunningStatus
)T inner join #CockPitData on T.Machineid=#CockPitData.Machineid

---------------------------------- Added to handle Machine Status for Focas Machines ---------------------------------- 



 
Update #CockpitData Set Lastcycletime = T1.LastCycle  from 
(
	Select A.Machineid,A.Endtime as LastCycle from Autodata_MaxTime A
) T1 inner join #CockpitData on T1.MachineID = #CockpitData.machineinterface


UPDATE #CockpitData  
SET 
TotalTime = DateDiff(SECOND, @StartTime, @endtime) Where ISNULL(TotalTime,0)=0

UPDATE #CockPitData SET Holidays=isnull(t1.hday,0)
FROM
	(SELECT MachineID,SUM(DATEDIFF(SECOND,StartTime,EndTime)) AS hday FROM #PlannedDownTimes
	WHERE StartTime>=CONVERT(NVARCHAR(20),@StartTime,120) AND endtime<=CONVERT(NVARCHAR(20),@EndTime,120)  
	GROUP BY machineid
	) t1 INNER JOIN #CockPitData ON t1.MachineID=#CockPitData.MachineID

--UPDATE #CockPitData SET Holidays=isnull(t1.hday,0)
--FROM
--	(SELECT MachineID,(ISNULL(COUNT(DISTINCT holiday),0))*CAST(86400 AS FLOAT) AS hday FROM HolidayList
--	WHERE Holiday>=CAST(@StartTime AS date) AND Holiday<=CAST(@EndTime AS date)
--	GROUP BY machineid
--	) t1 INNER JOIN #CockPitData ON t1.MachineID=#CockPitData.MachineID



UPDATE #CockPitData SET AvgProduction=ISNULL((Components-RejCount),0)/(((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0))/CAST(86400 AS FLOAT))
WHERE ((((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0)))/CAST(86400 AS FLOAT))<>0


IF (@GroupID='Testing' AND @param='FifthScreen')
begin
UPDATE #CockPitData SET TotalTestParts=(t1.testedpart)
FROM
(SELECT machineid,count(DISTINCT slno) AS testedpart  FROM #test
WHERE (MeasuredDateTime>=@StartTime AND MeasuredDateTime<=@EndTime)
GROUP BY machineid
)t1 INNER JOIN #CockPitData ON t1.MachineID=#CockPitData.MachineID	

UPDATE #CockPitData SET TotalOk=ISNULL(ISNULL(TotalTestParts,0)-ISNULL(RejCount,0),0)

--UPDATE #CockPitData SET TotalNotOk=(t1.Notok)
--FROM
--(SELECT machineid,count(DISTINCT slno) AS Notok  FROM #test
--WHERE (MeasuredDateTime>=@StartTime AND MeasuredDateTime<=@EndTime) AND RejBit=1
--GROUP BY machineid
--)t1 INNER JOIN #CockPitData ON t1.MachineID=#CockPitData.MachineID	

END

--SELECT * FROM #CockPitData
--RETURN


IF (@GroupID='Testing') and (@param='FirstScreen')
BEGIN
		Select @strSql=''
		Select @strSql=@strSql+
		'Insert into #Testing(Plantid,Groupid,Components,RejCount,UtilisedTime,DownTime,MaxDownReason,CN,ManagementLoss,GroupDescription,ReworkCount,holidays,PDTInDays)
		Select PlantMachine.Plantid,PlantMachineGroups.Groupid,Isnull(sum(Components),0),Isnull(sum(RejCount),0),
		isnull(sum(UtilisedTime),0),isnull(sum(DownTime),0),Max(MaxDownReason),ISNULL(SUM(CN),0),ISNULL(SUM(ManagementLoss),0),PlantMachineGroups.Description,Isnull(sum(ReworkCount),0),
		round(ISNULL(avg(holidays),0),0),isnull(sum(PDTInDays),0)
		From #CockPitData 
		Left Outer Join PlantMachine ON PlantMachine.MachineID=#CockPitData.MachineID
		LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID
		Where #CockPitData.MachineInterface>''0'' '
		SELECT @StrSql=@StrSql+ @StrPlantID+ @Strmachine+@StrGroupID
		SELECT @StrSql=@StrSql+ ' group By PlantMachine.Plantid,PlantMachineGroups.Groupid,PlantMachineGroups.Description'
		Print @StrSql
		EXEC(@StrSql)

		UPDATE #Testing
		SET
			ProductionEfficiency = (CN/UtilisedTime) ,
			AvailabilityEfficiency = (UtilisedTime)/(UtilisedTime + DownTime - ManagementLoss)
		WHERE UtilisedTime <> 0
		
		UPDATE #Testing SET QualityEfficiency= CAST(Components As Float)/CAST((IsNull(Components,0)+IsNull(RejCount,0)) AS Float)
		Where Components<>0 

		UPDATE #Testing
		SET
			OverAllEfficiency = (ProductionEfficiency * AvailabilityEfficiency * ISNULL(QualityEfficiency,1))*100,
			ProductionEfficiency = ProductionEfficiency * 100 ,
			AvailabilityEfficiency = AvailabilityEfficiency * 100,
			QualityEfficiency = QualityEfficiency*100

		UPDATE #Testing SET TotalTestParts=(t1.testedpart)
		FROM
		(SELECT count(DISTINCT slno) AS testedpart  FROM #test
		)t1

  --       UPDATE #Testing SET TotalNotOk=(t1.Notok)
		-- FROM
		--(SELECT count(DISTINCT slno) AS Notok  FROM #test WHERE RejBit=1
		--)t1

		UPDATE #Testing SET TotalOk=ISNULL(ISNULL(TotalTestParts,0)-ISNULL(RejCount,0),0)

		UPDATE #Testing SET Working_days=(((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0))/CAST(86400 AS FLOAT))

		UPDATE #Testing SET AvgProduction=ISNULL(TotalOk,0)/ISNULL(Working_days,0) WHERE Working_days>0

		If ISNULL(@SortOrder,'')=''
		BEGIN
			SET @SortOrder = 'Plantid,Groupid ASC'
		END
		Select @Strsortorder= ' order by #Testing.' + @SortOrder + ' '

		select @strSql=''
		Select @strSql=@strSql+'
		Select
		Plantid,Groupid,
		Isnull(Components,0) as ProdCount,
		(Isnull(Components,0)-Isnull(RejCount,0)) as AcceptedParts,
		Isnull(RejCount,0) as RejCount,
		Round(Isnull(AvailabilityEfficiency,0),2) as AEffy,
		Round(Isnull(ProductionEfficiency,0),2) as PEffy ,
		Round(Isnull(OverAllEfficiency,0),2) as OEffy,
		Round(Isnull(QualityEfficiency,0),2) as QEffy,
		dbo.f_formattime(isnull(UtilisedTime,0),'''+@timeformat+''') As UtilisedTime  ,
		dbo.f_formattime(isnull(DownTime,0),'''+@timeformat+''') As DownTime,
		dbo.f_formattime(isnull(ManagementLoss,0),'''+@timeformat+''') As ManagementLoss,
		GroupDescription as Description,MaxDownReason as MaxDownReasonTime,ISNULL(PEGreen,0) as PEGreen,ISNULL(PERed,0) as PERed,ISNULL(AEGreen,0) as AEGreen,isnull(AERed,0) as AERed,isnull(OEEGreen,0) as OEGreen,
		isnull(OEERed,0) as OERed,isnull(QERED,0) as QERED,isnull(QEGreen,0) as QEGreen,isnull(TotalTestParts,0) as PumpTestedParts,isnull(RejCount,0) as PumpNotOk,isnull(totalok,0) as PumpOk,
		ROUND(ISNULL(Working_days,0),3) AS Working_days,
		round(ISNULL(AvgProduction,0),3) AS AvgProduction
		From #Testing,TPMWEB_EfficiencyColorCoding where TPMWEB_EfficiencyColorCoding.Type=''CellID'' '
		Select @strSql=@strSql+@Strsortorder
		exec(@strsql)
END

IF (@GroupID='') AND ( @param='SecondScreen')
BEGIN
		Select @strSql=''
		Select @strSql=@strSql+
		'Insert into #TestingSubGroup(Plantid,Groupid,subgroup,Components,RejCount,UtilisedTime,DownTime,MaxDownReason,CN,ManagementLoss,GroupDescription,ReworkCount,holidays,PDTInDays)
		Select PlantMachine.Plantid,PlantMachineGroups.Groupid,PlantMachineGroupSubgroup.SubGroups,Isnull(sum(Components),0),Isnull(sum(RejCount),0),
		isnull(sum(UtilisedTime),0),isnull(sum(DownTime),0),Max(MaxDownReason),ISNULL(SUM(CN),0),ISNULL(SUM(ManagementLoss),0),PlantMachineGroups.Description,Isnull(sum(ReworkCount),0),
		round(ISNULL(avg(holidays),0),0),isnull(sum(PDTInDays),0)
		From #CockPitData 
		Left Outer Join PlantMachine ON PlantMachine.MachineID=#CockPitData.MachineID
		LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID
		left outer join PlantMachineGroupSubgroup on PlantMachineGroupSubgroup.plantid=PlantMachineGroups.PlantID and PlantMachineGroupSubgroup.Groupid=PlantMachineGroups.Groupid
		and PlantMachineGroupSubgroup.machineid=PlantMachineGroups.machineid
		Where #CockPitData.MachineInterface>''0'' and PlantMachineGroups.groupid=''Testing'' '
		SELECT @StrSql=@StrSql+ @StrPlantID+ @Strmachine+@StrGroupID
		SELECT @StrSql=@StrSql+ ' group By PlantMachine.Plantid,PlantMachineGroups.Groupid,PlantMachineGroups.Description,PlantMachineGroupSubgroup.Subgroups'
		Print @StrSql
		EXEC(@StrSql)

		UPDATE #TestingSubGroup
		SET
			ProductionEfficiency = (CN/UtilisedTime) ,
			AvailabilityEfficiency = (UtilisedTime)/(UtilisedTime + DownTime - ManagementLoss)
		WHERE UtilisedTime <> 0
		
		UPDATE #TestingSubGroup SET QualityEfficiency= CAST(Components As Float)/CAST((IsNull(Components,0)+IsNull(RejCount,0)) AS Float)
		Where Components<>0 

		UPDATE #TestingSubGroup
		SET
			OverAllEfficiency = (ProductionEfficiency * AvailabilityEfficiency * ISNULL(QualityEfficiency,1))*100,
			ProductionEfficiency = ProductionEfficiency * 100 ,
			AvailabilityEfficiency = AvailabilityEfficiency * 100,
			QualityEfficiency = QualityEfficiency*100

		UPDATE #TestingSubGroup SET TotalTestParts=(t1.testedpart)
		FROM
		(SELECT DISTINCT p.PumpCategory,count(DISTINCT slno) AS testedpart  FROM #test
		LEFT OUTER JOIN dbo.PumpModelMaster_Mivin p ON p.PumpModel=#Test.PumpModel
		GROUP BY p.PumpCategory
		)t1 INNER JOIN #TestingSubGroup ON t1.PumpCategory=#TestingSubGroup.SubGroup

  --       UPDATE #TestingSubGroup SET TotalNotOk=(t1.Notok)
		-- FROM
		--(SELECT p.PumpCategory,count(DISTINCT slno) AS Notok  FROM #test 
		--LEFT OUTER JOIN dbo.PumpModelMaster_Mivin p ON p.PumpModel=#Test.PumpModel
		--WHERE RejBit=1
		--GROUP BY p.PumpCategory
		--)t1 INNER JOIN #TestingSubGroup ON t1.PumpCategory=#TestingSubGroup.SubGroup

		UPDATE #TestingSubGroup SET TotalOk=ISNULL(ISNULL(TotalTestParts,0)-ISNULL(RejCount,0),0)

		UPDATE #TestingSubGroup SET Working_days=(((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0))/CAST(86400 AS FLOAT))

		UPDATE #TestingSubGroup SET AvgProduction=ISNULL(TotalOk,0)/ISNULL(Working_days,0) WHERE Working_days>0


		If ISNULL(@SortOrder,'')=''
		BEGIN
			SET @SortOrder = 'Plantid,Groupid ASC'
		END
		Select @Strsortorder= ' order by #TestingSubGroup.' + @SortOrder + ' '

		select @strSql=''
		Select @strSql=@strSql+'
		Select
		Plantid,Groupid,Subgroup,
		Isnull(Components,0) as ProdCount,
		(Isnull(Components,0)-Isnull(RejCount,0)) as AcceptedParts,
		Isnull(RejCount,0) as RejCount,
		Round(Isnull(AvailabilityEfficiency,0),2) as AEffy,
		Round(Isnull(ProductionEfficiency,0),2) as PEffy ,
		Round(Isnull(OverAllEfficiency,0),2) as OEffy,
		Round(Isnull(QualityEfficiency,0),2) as QEffy,
		dbo.f_formattime(isnull(UtilisedTime,0),'''+@timeformat+''') As UtilisedTime  ,
		dbo.f_formattime(isnull(DownTime,0),'''+@timeformat+''') As DownTime,
		dbo.f_formattime(isnull(ManagementLoss,0),'''+@timeformat+''') As ManagementLoss,
		GroupDescription as Description,MaxDownReason as MaxDownReasonTime,ISNULL(PEGreen,0) as PEGreen,ISNULL(PERed,0) as PERed,ISNULL(AEGreen,0) as AEGreen,isnull(AERed,0) as AERed,isnull(OEEGreen,0) as OEGreen,
		isnull(OEERed,0) as OERed,isnull(QERED,0) as QERED,isnull(QEGreen,0) as QEGreen,isnull(TotalTestParts,0) as PumpTestedParts,isnull(RejCount,0) as PumpNotOk,isnull(totalok,0) as PumpOk,
		ROUND(ISNULL(Working_days,0),3) AS Working_days,
		round(ISNULL(AvgProduction,0),3) AS AvgProduction
		From #TestingSubGroup,TPMWEB_EfficiencyColorCoding where TPMWEB_EfficiencyColorCoding.Type=''CellID''  '
		Select @strSql=@strSql+@Strsortorder
		EXEC(@strsql)


		SELECT @strSql=''
		SELECT @strSql=@strSql+
		'Insert into #DownStream(Plantid,Components,RejCount,UtilisedTime,DownTime,MaxDownReason,CN,ManagementLoss,Description,ReworkCount,TotalTestParts,TotalOk,TotalNotOk,holidays,PDTInDays)
		Select PlantMachine.Plantid,Isnull(sum(Components),0),Isnull(sum(RejCount),0),
		isnull(sum(UtilisedTime),0),isnull(sum(DownTime),0),Max(MaxDownReason),ISNULL(SUM(CN),0),ISNULL(SUM(ManagementLoss),0),PlantMachine.Plantid,Isnull(sum(ReworkCount),0),ISNULL(SUM(TotalTestParts),0),
		ISNULL(SUM(TotalOk),0),ISNULL(SUM(TotalNotOk),0),
		round(ISNULL(avg(holidays),0),0),isnull(sum(PDTInDays),0)
		From #CockPitData 
		Left Outer Join PlantMachine ON PlantMachine.MachineID=#CockPitData.MachineID
		LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID
		left outer join PlantMachineGroupSubgroup on PlantMachineGroupSubgroup.plantid=PlantMachineGroups.PlantID and PlantMachineGroupSubgroup.Groupid=PlantMachineGroups.Groupid
		and PlantMachineGroupSubgroup.machineid=PlantMachineGroups.machineid
		Where #CockPitData.MachineInterface>''0'' and PlantMachineGroups.groupid not in (''Testing'') '
		SELECT @StrSql=@StrSql+ @StrPlantID+ @Strmachine
		SELECT @StrSql=@StrSql+ ' group By PlantMachine.Plantid'
		PRINT @StrSql
		EXEC(@StrSql)
        
		UPDATE #DownStream
		SET
			ProductionEfficiency = (CN/UtilisedTime) ,
			AvailabilityEfficiency = (UtilisedTime)/(UtilisedTime + DownTime - ManagementLoss)
		WHERE UtilisedTime <> 0
		
		UPDATE #DownStream SET QualityEfficiency= CAST(Components As Float)/CAST((IsNull(Components,0)+IsNull(RejCount,0)) AS Float)
		Where Components<>0 

		UPDATE #DownStream
		SET
			OverAllEfficiency = (ProductionEfficiency * AvailabilityEfficiency * ISNULL(QualityEfficiency,1))*100,
			ProductionEfficiency = ProductionEfficiency * 100 ,
			AvailabilityEfficiency = AvailabilityEfficiency * 100,
			QualityEfficiency = QualityEfficiency*100

		UPDATE #DownStream SET Working_days=(((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0))/CAST(86400 AS FLOAT))


		UPDATE #DownStream SET AvgProduction=ROUND(ISNULL((Components-RejCount),0),2)/ISNULL(Working_days,0)WHERE Working_days>0

		select @strSql=''
		Select @strSql=@strSql+'
		Select
		Plantid,
		Isnull(Components,0) as ProdCount,
		(Isnull(Components,0)-Isnull(RejCount,0)) as AcceptedParts,
		Isnull(RejCount,0) as RejCount,
		Round(Isnull(AvailabilityEfficiency,0),2) as AEffy,
		Round(Isnull(ProductionEfficiency,0),2) as PEffy ,
		Round(Isnull(OverAllEfficiency,0),2) as OEffy,
		Round(Isnull(QualityEfficiency,0),2) as QEffy,
		dbo.f_formattime(isnull(UtilisedTime,0),'''+@timeformat+''') As UtilisedTime  ,
		dbo.f_formattime(isnull(DownTime,0),'''+@timeformat+''') As DownTime,
		dbo.f_formattime(isnull(ManagementLoss,0),'''+@timeformat+''') As ManagementLoss,
		Description as Description,
		MaxDownReason as MaxDownReasonTime,ISNULL(PEGreen,0) as PEGreen,ISNULL(PERed,0) as PERed,ISNULL(AEGreen,0) as AEGreen,isnull(AERed,0) as AERed,isnull(OEEGreen,0) as OEGreen,
		isnull(OEERed,0) as OERed,isnull(QERED,0) as QERED,isnull(QEGreen,0) as QEGreen,
		--isnull(TotalTestParts,0) as PumpTestedParts,isnull(TotalNotOk,0) as PumpNotOk,isnull(totalok,0) as PumpOk,
		ROUND(ISNULL(Working_days,0),3) AS Working_days,
		round(ISNULL(AvgProduction,0),3) AS AvgProduction
		From #DownStream,TPMWEB_EfficiencyColorCoding where TPMWEB_EfficiencyColorCoding.Type=''PlantID'' ORDER BY PLANTID ASC '
		exec(@strsql)
		
END

IF (@GroupID='') AND (@param='ThirdScreen')
BEGIN
		select @strSql=''
		Select @strSql=@strSql+'
		Insert into #PlantCellwiseSummary(Plantid,Groupid,Components,RejCount,UtilisedTime,DownTime,MaxDownReason,CN,ManagementLoss,GroupDescription,ReworkCount,TotalTestParts,TotalOk,TotalNotOk,holidays,PDTInDays)
		Select PlantMachine.Plantid,PlantMachineGroups.Groupid,Isnull(sum(Components),0),Isnull(sum(RejCount),0),
		isnull(sum(UtilisedTime),0),isnull(sum(DownTime),0),Max(MaxDownReason),ISNULL(SUM(CN),0),ISNULL(SUM(ManagementLoss),0),PlantMachineGroups.Description,Isnull(sum(ReworkCount),0),
		ISNULL(SUM(TotalTestParts),0),ISNULL(SUM(TotalOk),0),ISNULL(SUM(TotalNotOk),0),
		round(ISNULL(avg(holidays),0),0),isnull(sum(PDTInDays),0)
		From #CockPitData 
		Left Outer Join PlantMachine ON PlantMachine.MachineID=#CockPitData.MachineID
		LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID and PlantMachineGroups.machineid = PlantMachine.MachineID
		Where #CockPitData.MachineInterface>''0'' and PlantMachineGroups.groupid not in (''Testing'') '
		SELECT @StrSql=@StrSql+ @StrPlantID+ @Strmachine+@StrGroupID
		SELECT @StrSql=@StrSql+ ' group By PlantMachine.Plantid,PlantMachineGroups.Groupid,PlantMachineGroups.Description '
		Print @StrSql
		EXEC(@StrSql)

		UPDATE #PlantCellwiseSummary
		SET
			ProductionEfficiency = (CN/UtilisedTime) ,
			AvailabilityEfficiency = (UtilisedTime)/(UtilisedTime + DownTime - ManagementLoss)
		WHERE UtilisedTime <> 0
		
		UPDATE #PlantCellwiseSummary SET QualityEfficiency= CAST(Components As Float)/CAST((IsNull(Components,0)+IsNull(RejCount,0)) AS Float)
		Where Components<>0 

		UPDATE #PlantCellwiseSummary
		SET
			OverAllEfficiency = (ProductionEfficiency * AvailabilityEfficiency * ISNULL(QualityEfficiency,1))*100,
			ProductionEfficiency = ProductionEfficiency * 100 ,
			AvailabilityEfficiency = AvailabilityEfficiency * 100,
			QualityEfficiency = QualityEfficiency*100

		UPDATE #PlantCellwiseSummary SET Working_days=(((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0))/CAST(86400 AS FLOAT))

		UPDATE #PlantCellwiseSummary SET AvgProduction=ROUND(ISNULL((Components-RejCount),0),2)/ISNULL(Working_days,0)WHERE Working_days>0

		If ISNULL(@SortOrder,'')=''
		BEGIN
			SET @SortOrder = 'Plantid,Groupid ASC'
			Select @Strsortorder= ' order by #PlantCellwiseSummary.' + @SortOrder + ' '  
		END

        select @strSql=''
		Select @strSql=@strSql+'
		SELECT
		Plantid,Groupid,
		Isnull(Components,0) as ProdCount,
		(Isnull(Components,0)-Isnull(RejCount,0)) as AcceptedParts,
		Isnull(RejCount,0) as RejCount,
		Round(Isnull(AvailabilityEfficiency,0),2) as AEffy,
		Round(Isnull(ProductionEfficiency,0),2) as PEffy ,
		Round(Isnull(OverAllEfficiency,0),2) as OEffy,
		Round(Isnull(QualityEfficiency,0),2) as QEffy,
		dbo.f_formattime(isnull(UtilisedTime,0),'''+@timeformat+''') As UtilisedTime  ,
		dbo.f_formattime(isnull(DownTime,0),'''+@timeformat+''') As DownTime,
		dbo.f_formattime(isnull(ManagementLoss,0),'''+@timeformat+''') As ManagementLoss,
		GroupDescription as Description,MaxDownReason as MaxDownReasonTime,ISNULL(PEGreen,0) as PEGreen,ISNULL(PERed,0) as PERed,ISNULL(AEGreen,0) as AEGreen,isnull(AERed,0) as AERed,isnull(OEEGreen,0) as OEGreen,
		isnull(OEERed,0) as OERed,isnull(QERED,0) as QERED,isnull(QEGreen,0) as QEGreen,
		--isnull(TotalTestParts,0) as PumpTestedParts,isnull(TotalNotOk,0) as PumpNotOk,isnull(totalok,0) as PumpOk,
		ROUND(ISNULL(Working_days,0),3) AS Working_days,
		round(ISNULL(AvgProduction,0),3) AS AvgProduction
		From #PlantCellwiseSummary,TPMWEB_EfficiencyColorCoding where TPMWEB_EfficiencyColorCoding.Type=''CellID'' '
		exec(@strsql)
END

IF @param='FourthScreen'
BEGIN

	UPDATE #CockPitData SET Working_days=(((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0))/CAST(86400 AS FLOAT))


	SELECT @strsql=''  
	Select @strsql = 'SELECT 
	C.MachineID,  
   '''+CONVERT(nvarchar(20),@StartTime,120) + ''' as StartTime, 
	Isnull(Components,0) as ProdCount,
	(Isnull(Components,0)-Isnull(RejCount,0)) as AcceptedParts,
	Isnull(RejCount,0) as RejCount,
	Round(Isnull(AvailabilityEfficiency,0),2) as AEffy,
	Round(Isnull(ProductionEfficiency,0),2) as PEffy ,
	Round(Isnull(OverAllEfficiency,0),2) as OEffy,
	Round(Isnull(QualityEfficiency,0),2) as QEffy,
	dbo.f_formattime(isnull(UtilisedTime,0),'''+@timeformat+''') As UtilisedTime  ,
	dbo.f_formattime(isnull(DownTime,0),'''+@timeformat+''') As DownTime,
	dbo.f_formattime(isnull(ManagementLoss,0),'''+@timeformat+''') As ManagementLoss,
	m.Description as Description,MaxDownReason as MaxDownReasonTime,
	ISNULL(c.PEGreen,0) as PEGreen,
	ISNULL(c.PERed,0) as PERed,
	ISNULL(c.AEGreen,0) as AEGreen,
	isnull(c.AERed,0) as AERed,
	isnull(c.OEGreen,0) as OEGreen,
	isnull(c.OERed,0) as OERed,
	isnull(c.QERED,0) as QERED,
	isnull(c.QEGreen,0) as QEGreen,
	--isnull(TotalTestParts,0) as PumpTestedParts,isnull(TotalNotOk,0) as PumpNotOk,isnull(totalok,0) as PumpOk,
	--round((DATEDIFF(day,'''+CONVERT(NVARCHAR(20),@StartTime,120)+''','''+CONVERT(NVARCHAR(20),@EndTime,120)+'''))-ISNULL(holidays,0),0) AS Working_days,
	ROUND(ISNULL(Working_days,0),3) AS Working_days,
	round(ISNULL(AvgProduction,0),3) AS AvgProduction,
	g.Plantid,g.Groupid,
	C.Remarks1,
	ISNULL(C.MachineLivestatus,''NoData'') as MachineLiveStatus
	FROM #CockpitData C Inner Join #PLD on #PLD.Machineid=C.Machineid 
	Inner join Machineinformation M on M.Machineid=C.Machineid 
	Left Outer Join PlantMachine P ON P.MachineID=C.MachineID
	LEFT OUTER JOIN PlantMachineGroups G ON G.PlantID = P.PlantID and G.machineid = P.MachineID
	where g.Groupid<>''Testing'' '
	Select @strSql = @strSql  + @Strsortorder
	print(@strsql)
	exec(@strsql)  
END

IF @param='FifthScreen'
BEGIN

	UPDATE #CockPitData SET Working_days=(((DATEDIFF(SECOND,@StartTime,@EndTime))-ISNULL(Holidays,0))/CAST(86400 AS FLOAT))

	UPDATE #CockPitData SET AvgProduction=ROUND(ISNULL((TotalTestParts-RejCount),0),2)/ISNULL(Working_days,0)WHERE Working_days>0


	Select @strsql=''  
	Select @strsql = 'SELECT 
	C.MachineID,PlantMachineGroupSubgroup.subgroups,  
	''' + Convert(nvarchar(20),@StartTime,120) + ''' as StartTime, 
	Isnull(Components,0) as ProdCount,
	(Isnull(Components,0)-Isnull(RejCount,0)) as AcceptedParts,
	Isnull(RejCount,0) as RejCount,
	Round(Isnull(AvailabilityEfficiency,0),2) as AEffy,
	Round(Isnull(ProductionEfficiency,0),2) as PEffy ,
	Round(Isnull(OverAllEfficiency,0),2) as OEffy,
	Round(Isnull(QualityEfficiency,0),2) as QEffy,
	dbo.f_formattime(isnull(UtilisedTime,0),'''+@timeformat+''') As UtilisedTime  ,
	dbo.f_formattime(isnull(DownTime,0),'''+@timeformat+''') As DownTime,
	dbo.f_formattime(isnull(ManagementLoss,0),'''+@timeformat+''') As ManagementLoss,
	m.Description as Description,MaxDownReason as MaxDownReasonTime,
	ISNULL(c.PEGreen,0) as PEGreen,
	ISNULL(c.PERed,0) as PERed,
	ISNULL(c.AEGreen,0) as AEGreen,
	isnull(c.AERed,0) as AERed,
	isnull(c.OEGreen,0) as OEGreen,
	isnull(c.OERed,0) as OERed,
	isnull(c.QERED,0) as QERED,
	isnull(c.QEGreen,0) as QEGreen,
	isnull(TotalTestParts,0) as PumpTestedParts,isnull(RejCount,0) as PumpNotOk,isnull(totalok,0) as PumpOk,
	--round((DATEDIFF(day,'''+CONVERT(NVARCHAR(20),@StartTime,120)+''','''+CONVERT(NVARCHAR(20),@EndTime,120)+'''))-ISNULL(holidays,0),0) AS Working_days,
	--round(ISNULL(totalok/round((DATEDIFF(day,'''+CONVERT(NVARCHAR(20),@StartTime,120)+''','''+CONVERT(NVARCHAR(20),@EndTime,120)+'''))-ISNULL(holidays,0),2),0),2) AS AvgProduction,
	ROUND(ISNULL(Working_days,0),3) AS Working_days,
	round(ISNULL(AvgProduction,0),3) AS AvgProduction,
	g.Plantid,g.Groupid,
	C.Remarks1,
	ISNULL(C.MachineLivestatus,''NoData'') as MachineLiveStatus
	FROM #CockpitData C Inner Join #PLD on #PLD.Machineid=C.Machineid 
	Inner join Machineinformation M on M.Machineid=C.Machineid 
	inner Join PlantMachine P ON P.MachineID=C.MachineID
	inner JOIN PlantMachineGroups G ON G.PlantID = P.PlantID and G.machineid = P.MachineID
	inner join PlantMachineGroupSubgroup on PlantMachineGroupSubgroup.plantid=g.plantid and PlantMachineGroupSubgroup.groupid=g.groupid and PlantMachineGroupSubgroup.machineid=g.machineid'
	Select @strSql = @strSql + @strsubgroup + @Strsortorder  
	print(@strsql)
	exec(@strsql) 
END


end
