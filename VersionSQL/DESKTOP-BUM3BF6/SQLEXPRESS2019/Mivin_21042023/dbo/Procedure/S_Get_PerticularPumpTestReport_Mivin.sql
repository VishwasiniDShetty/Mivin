/****** Object:  Procedure [dbo].[S_Get_PerticularPumpTestReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_Get_PerticularPumpTestReport_Mivin] '2022-02-01 00:00:00.000','2022-02-28 00:00:00.000','','','',''
EXEC [dbo].[S_Get_PerticularPumpTestReport_Mivin] @StartDate=N'2023-04-01 00:00:00',@EndDate=N'2023-04-04 00:00:00',@PumpModel=N'',@MachineID=N'',@SlNo=N''
*/
CREATE procedure [dbo].[S_Get_PerticularPumpTestReport_Mivin]
@StartDate datetime='',
@EndDate datetime='',
@MachineID nvarchar(50)='',
@PumpModel nvarchar(50)='',
@PumpCat nvarchar(50)='',
@SlNo nvarchar(50)=''

AS

BEGIN
	DECLARE @StartTime datetime
	DECLARE @EndTime datetime
	SELECT @StartTime= dbo.f_GetLogicalDay(@StartDate,'Start')
	SELECT @EndTime=dbo.f_GetLogicalDay(@EndDate,'End')

	CREATE TABLE #Shift
	(
		ShiftDate datetime,		
		ShiftName nvarchar(20),
		ShiftID nvarchar(50),
		ShftSTtime datetime,
		ShftEndTime datetime
	)

	CREATE TABLE #Test1
	(
		MachineID nvarchar(50),
		[Date] datetime,
		[Shift] nvarchar(50),
		PumpModel nvarchar(50),
		Slno nvarchar(50),
		PumpType nvarchar(50),
		PumpCategory nvarchar(50),
		[Event] nvarchar(50),
		CycleStart datetime,
		MeasuredDateTime datetime,
		FlowVal float default 0,
		TempVal float default 0,
		PressureVal float default 0,
		RpmVal float default 0,
		FlowLSL float default 0,
		FlowUSL float default 0,
		TempLSL float default 0,
		TempUSL float default 0,
		PressureLSL float default 0,
		PressureUSL float default 0,
		RPMLSL float  default 0,
		RPMUSL float default 0,
		IsMasterPump bit,
		PumpAB nvarchar(50),
		[Status] nvarchar(50),
		Operator nvarchar(50),
		RpmSpec float,
		TempSpec float,
		PressureSpec float,
		FlowSpec float,
		TorqueVal float default 0,
		TorqueMin float default 0,
		TorqueMax float default 0,
		RotationalType nvarchar(100),
		ModelType nvarchar(50)
	)

	DECLARE @Start datetime
	DECLARE @End datetime

	SELECT @Start=@StartTime
	SELECT @End=@EndTime

	WHILE CAST(@Start AS date) < CAST(@end AS date)
	BEGIN
		INSERT INTO #Shift(ShiftDate,ShiftName,ShftSTtime,ShftEndTime)
		EXEC s_GetShiftTime @Start,''
		SELECT @Start = DATEADD(DAY,1,@Start)
	END

	UPDATE #Shift SET ShiftID = ISNULL(T1.ShiftID,0) + ISNULL(T1.ShiftID,0) 
	FROM
	(
		SELECT SD.ShiftID,SD.ShiftName FROM shiftdetails SD
		INNER JOIN #Shift S ON SD.ShiftName=S.ShiftName 
		WHERE Running=1
	) T1 
	INNER JOIN #Shift T2 ON T1.ShiftName=T1.ShiftName

	--SELECT * FROM PumpTestData_Mivin

	SELECT * INTO #TestNew FROM PumpTestData_Mivin 
	WHERE (MachineID=@MachineID OR ISNULL(@MachineID,'')='') AND (PumpModel=@PumpModel OR ISNULL(@PumpModel,'')='') AND (SlNo LIKE '%' + @SlNo + '%')
	AND (MeasuredDatetime>=@StartTime AND MeasuredDatetime<=@EndTime) AND [Event]='T4'

	INSERT INTO #Test1(MachineID,PumpModel,Slno,PumpType,PumpAB,[Event],MeasuredDatetime,ModelType)
	SELECT A2.MachineID,PumpModel,SlNo,PumpType,PumpAB,[Event],MAX(Measureddatetime) AS MeasuredDatetime,ModelType FROM #TestNew A1
	INNER JOIN MachineInformation A2 ON A2.InterfaceID=A1.MachineID
	WHERE [Event]='T4' AND IsTestBenchMachine=1
	GROUP BY A2.MachineID,PumpModel,SlNo,PumpType,[Event],PumpAB,ModelType

	UPDATE #Test1 SET PumpCategory=T1.PumpCategory,CycleStart=T1.CycleStart,FlowVal=T1.FlowVal,TempVal=T1.TempVal,PressureVal=T1.PressureVal,
	RpmVal=T1.RPMVal,IsMasterPump=T1.IsMasterPump,PumpAB=T1.PumpAB,[Status]=T1.[Status],Operator=T1.Operator
	FROM
	(
		SELECT MachineID,A1.PumpModel,A2.PumpType,A1.[Event],A2.PumpCategory,SlNo,CycleStart,MeasuredDatetime,FlowVal,TempVal,PressureVal,RPMVal,
		IsMasterPump,PumpAB,[Status],Operator
		FROM #TestNew A1
		INNER JOIN PumpModelMaster_Mivin A2 ON A1.PumpModel=A2.PumpModel AND A1.PumpType=A2.PumpType
		WHERE A1.MachineID<>'2089'
	) T1 
	INNER JOIN #Test1 T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PumpModel AND T1.SlNo=T2.Slno AND T1.PumpType=T2.PumpType 
	AND T1.PumpAB=T2.PumpAB AND T1.[Event]=T2.[Event] AND T1.Measureddatetime=T2.MeasuredDateTime AND T1.MachineID<>'2089'

	UPDATE #Test1 SET FlowLSL=T1.LSL,FlowUSL=T1.USL
	FROM
	(
		SELECT A1.PumpModel,A1.PumpType,A1.PumpAB,A1.[Event],LSL,USL,A2.MachineID FROM PumpModelParameterMaster_Mivin A1
		INNER JOIN #Test1 A2 ON A1.PumpModel=A2.PumpModel AND A1.PumpType=A2.PumpType AND A1.PumpAB=A2.PumpAB AND A1.[Event]=A2.[Event]
		WHERE Parameter='Flow' AND A1.[Event]='T4' AND A2.MachineID<>'2089'
	) T1 
	INNER JOIN #Test1 T2 ON T1.PumpModel=T2.PumpModel AND T1.PumpType=T2.PumpType AND T1.PumpAB=T2.PumpAB AND T1.[Event]=T2.[Event] AND
	T1.MachineID<>'2089'

	UPDATE #Test1 SET TempLSL=T1.LSL,TempUSL=T1.USL
	FROM
	(
		SELECT A1.PumpModel,A1.PumpType,A1.PumpAB,A1.[Event],LSL,USL FROM PumpModelParameterMaster_Mivin A1
		INNER JOIN #Test1 A2 ON A1.PumpModel=A2.PumpModel AND A1.PumpType=A2.PumpType AND A1.PumpAB=A2.PumpAB AND A1.[Event]=A2.[Event]
		WHERE Parameter='Temperature' AND A1.[Event]='T4' AND A2.MachineID<>'2089'
	) T1 
	INNER JOIN #Test1 T2 ON T1.PumpModel=T2.PumpModel AND T1.PumpType=T2.PumpType AND T1.PumpAB=T2.PumpAB AND T1.[Event]=T2.[Event]
	AND T2.MachineID<>'2089'

	UPDATE #Test1 SET PressureLSL=T1.LSL,PressureUSL=T1.USL
	FROM
	(
		SELECT A1.PumpModel,A1.PumpType,A1.PumpAB,A1.[Event],LSL,USL FROM PumpModelParameterMaster_Mivin A1
		INNER JOIN #Test1 A2 ON A1.PumpModel=A2.PumpModel AND A1.PumpType=A2.PumpType AND A1.PumpAB=A2.PumpAB AND A1.[Event]=A2.[Event]
		WHERE Parameter='Pressure' AND A1.[Event]='T4' AND MachineID<>'2089'
	) T1 
	INNER JOIN #Test1 T2 ON T1.PumpModel=T2.PumpModel AND T1.PumpType=T2.PumpType AND T1.PumpAB=T2.PumpAB AND T1.[Event]=T2.[Event] 
	AND T2.MachineID<>'2089'

	UPDATE #Test1 SET RPMLSL=T1.LSL,RPMUSL=T1.USL
	FROM
	(
		SELECT A1.PumpModel,A1.PumpType,A1.PumpAB,A1.[Event],LSL,USL  FROM PumpModelParameterMaster_Mivin A1
		INNER JOIN #Test1 A2 ON A1.PumpModel=A2.PumpModel AND A1.PumpType=A2.PumpType AND A1.PumpAB=A2.PumpAB AND A1.[Event]=A2.[Event] 
		WHERE Parameter='RPM' AND A1.[Event]='T4'
	) T1 
	INNER JOIN #Test1 T2 ON T1.PumpModel=T2.PumpModel AND T1.PumpType=T2.PumpType AND T1.PumpAB=T2.PumpAB AND T1.[Event]=T2.[Event] 
	AND T2.MachineID<>'2089'

	------------ Torque -------------

	UPDATE #Test1 SET PumpCategory=T1.PumpType,CycleStart=T1.CycleStart,FlowVal=T1.FlowVal,FlowLSL=T1.FlowLSL,FlowUSL=T1.FlowUSL,TempVal=T1.TempVal,
	TempLSl=T1.TempLSL,TempUSL=T1.TempUSL,PressureVal=T1.PressureVal,PressureLSL=T1.PressureLSL,PressureUSL=T1.PressureUSL,RPMLSL=T1.RPMLSL,
	RPMUSL=T1.RPMUSL,RpmVal=T1.RPMVal,IsMasterPump=T1.IsMasterPump,PumpAB=T1.PumpAB,[Status]=T1.[Status],Operator=T1.Operator,
	RotationalType=T1.RotationalType
	FROM
	(
		SELECT A2.MachineID,A2.PumpModel,A2.PumpType,A1.[Event],A2.SlNo,A2.CycleStart,A2.MeasuredDatetime,A2.FlowVal,A2.FlowLSL,A2.FlowUSL,A2.TempVal,
		A2.TempLSL,A2.TempUSL,A2.PressureVal,A2.PressureLSL,A2.PressureUSL,A2.RPMVal,A2.RPMLSL,A2.RPMUSL,A2.IsMasterPump,A2.PumpAB,A2.[Status],
		A2.Operator,A1.RotationalType FROM #TestNew A1
		INNER JOIN PumpTestData_Mivin A2 ON A1.PumpModel=A2.PumpModel AND A1.PumpType=A2.PumpType
		WHERE A1.MachineID='2089'
	) T1 
	INNER JOIN #Test1 T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PumpModel AND T1.SlNo=T2.Slno AND T1.PumpType=T2.PumpType 
	AND T1.PumpAB=T2.PumpAB AND T1.[Event]=T2.[Event] AND T1.Measureddatetime=T2.MeasuredDateTime AND T1.MachineID='2089'

	---------------------------------

	SELECT CAST(Measureddatetime AS date) AS Date,A2.ShiftID,A2.ShiftName,MachineID,ModelType,PumpModel,PumpType,PumpCategory,PumpAB,Slno,Operator 
	AS OpInterface,A3.[Name] AS OperatorName,A3.Employeeid AS OperatorID,RpmVal AS RpmActual,RPMLSL AS RpmMinSpec,RPMUSL AS RpmMaxSpec,TempVal 
	AS TempActual,TempLSL AS TempMinSpec,TempUSL AS TempMaxSpec,PressureVal AS PressureActual,PressureLSL AS PressureMinSpec,PressureUSL AS PressurMaxSpec,
	FlowVal AS FlowActual,FlowLSL AS FlowMinSpec,FlowUSL AS FlowMaxSpec,MeasuredDateTime,--,TorqueVal,TorqueMin,TorqueMax,
	(CASE WHEN (A1.[Status])='OK' THEN 'Pass' WHEN (A1.[Status])='Not OK' THEN 'Fail' ELSE '' END) AS [Status] FROM #Test1 A1
	CROSS JOIN #Shift A2
	LEFT OUTER JOIN (SELECT DISTINCT Employeeid,[Name],interfaceid FROM employeeinformation) A3 ON A3.interfaceid=A1.Operator
	WHERE (MeasuredDateTime>=ShftSTtime AND MeasuredDateTime<=ShftEndTime) AND (PumpCategory=@PumpCat OR ISNULL(@PumpCat,'')='') AND MachineID<>'2089'
	ORDER BY MachineID,[Date]

	SELECT CAST(Measureddatetime AS date) AS Date,A2.ShiftID,A2.ShiftName,MachineID,ModelType,PumpModel,PumpType,PumpCategory,PumpAB,Slno,Operator 
	AS OpInterface,A3.[Name] AS OperatorName,A3.Employeeid AS OperatorID,RpmVal AS RpmActual,RPMLSL AS RpmMinSpec,RPMUSL AS RpmMaxSpec,TempVal 
	AS TempActual,TempLSL AS TempMinSpec,TempUSL AS TempMaxSpec,PressureVal AS PressureActual,PressureLSL AS PressureMinSpec,PressureUSL AS PressurMaxSpec,
	FlowVal AS FlowActual,FlowLSL AS FlowMinSpec,FlowUSL AS FlowMaxSpec,MeasuredDateTime,TorqueVal,TorqueMin,TorqueMax,RotationalType,
	(CASE WHEN (A1.[Status])='OK' THEN 'Pass' WHEN (A1.[Status])='Not OK' THEN 'Fail' ELSE '' END) AS [Status] FROM #Test1 A1
	CROSS JOIN #Shift A2
	LEFT OUTER JOIN (SELECT DISTINCT Employeeid,[Name],interfaceid FROM employeeinformation) A3 ON A3.interfaceid=A1.Operator
	WHERE (MeasuredDateTime>=ShftSTtime AND MeasuredDateTime<=ShftEndTime) AND (PumpCategory=@PumpCat OR ISNULL(@PumpCat,'')='') AND MachineID='2089'
	ORDER BY MachineID,[Date]
END
