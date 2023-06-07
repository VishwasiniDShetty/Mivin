/****** Object:  Procedure [dbo].[S_Get_GearMotorTestingReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
EXEC [dbo].[S_Get_GearMotorTestingReport_Mivin] '2089','R983032297','2023-02-01 10:30:00.000',''	

EXEC [dbo].[S_Get_GearMotorTestingReport_Mivin] '2089','R983041554','2023-04-01 10:30:00.000',''	

EXEC [dbo].[S_Get_GearMotorTestingReport_Mivin] '2089','R983032297','2023-04-01 10:30:00.000',''	
*/
CREATE PROCEDURE [dbo].[S_Get_GearMotorTestingReport_Mivin]
@MachineID nvarchar(50)='',
@PumpModel nvarchar(50)='',
@Date datetime='',
@Shift nvarchar(50)=''

AS

BEGIN
	DECLARE @MinDate AS DateTime
	DECLARE @MaxDate AS DateTime

	CREATE TABLE #Shift
	(
		ShiftDate DateTime,		
		ShiftName nvarchar(max),
		ShiftStartTime DateTime,
		ShiftEndTime DateTime,
		ShiftID int
	)

	INSERT INTO #Shift(ShiftDate,ShiftName,ShiftStartTime,ShiftEndTime)
	EXEC s_GetShiftTime @Date,''

	IF @Shift <> ''
	BEGIN
		DELETE FROM #Shift WHERE ShiftName NOT IN (SELECT Item FROM SplitStrings(@Shift,','))
	END

	SELECT @MinDate=MIN(ShiftStartTime) FROM #Shift
	SELECT @MaxDate=MAX(ShiftEndTime) FROM #Shift

	UPDATE #Shift SET ShiftID=T1.shiftid
	FROM
	(
		SELECT DISTINCT A1.ShiftName,A1.shiftid FROM ShiftDetails A1
		INNER JOIN #Shift A2 on A1.ShiftName=A2.ShiftName
		WHERE Running=1
	) T1 
	INNER JOIN #Shift T2 on T1.ShiftName=T2.ShiftName

	SELECT * INTO #PumpTestData_Mivin FROM PumpTestData_Mivin A1 WHERE MachineID=@MachineID AND PumpModel=@PumpModel AND (MeasuredDatetime>=@MinDate 
	AND MeasuredDatetime<=@MaxDate) 

	CREATE TABLE #Temp
	(
		[Date] datetime,
		ShiftID int,
		ShiftName nvarchar(50),
		MachineID nvarchar(50),
		ModelType nvarchar(50),
		PartNo nvarchar(50),
		RotationalType nvarchar(50),
		EInterfaceID nvarchar(50),
		EmployeeID nvarchar(50),
		EmployeeName nvarchar(100),
		PumpSlNo nvarchar(50),
		AssemblyChecking_Torque float,
		AssemblyChecking_RPM float,
		RunningInOne_Torque float,
		RunningInOne_RPM float,
		RunningInOne_Pressure float,
		RunningInTwo_Torque float,
		RunningInTwo_RPM float,
		RunningInTwo_Pressure float,
		Performance_Torque float,
		Performance_RPM float,
		Performance_Pressure float,
		Performance_Temp float,
		Performance_Flow float,
		BreakAwayPressure float,
		OutletFlow float,
		Result nvarchar(50)
	)

	CREATE TABLE #Temp2
	(
		MinFlow float,
		Direction nvarchar(50),
		MaxBar float,
		MaxRPM float,
		TorqueMax float,
		TorqueMin float
	)

	INSERT INTO #Temp(PumpSlNo,RotationalType,MachineID,PartNo,ModelType)
	SELECT DISTINCT SlNo,RotationalType,MachineID,PumpModel,ModelType FROM #PumpTestData_Mivin 

	UPDATE #Temp SET [Date]=T1.DT
	FROM
	(
		SELECT DISTINCT A1.MachineID,PartNo,SlNo,A1.RotationalType,MAX(MeasuredDatetime) AS DT FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.SlNo=A2.PumpSlNo AND A1.RotationalType=A2.RotationalType
		WHERE A1.[Event]='T4'
		GROUP BY A1.MachineID,PartNo,SlNo,A1.RotationalType
	) T1
	INNER JOIN #Temp T2 ON T1.SlNo=T2.PumpSlNo AND T1.RotationalType=T2.RotationalType AND T1.MachineID=T2.MachineID AND T1.PartNo=T2.PartNo

	UPDATE #Temp SET ShiftID=T1.ShiftID,ShiftName=T1.ShiftName
	FROM
	(
		SELECT DISTINCT A1.[Date],A2.ShiftID,A2.ShiftName FROM #Temp A1
		CROSS JOIN #Shift A2
		WHERE (A1.[Date]>=A2.ShiftStartTime AND A1.[Date]<=A2.ShiftEndTime)
	) T1
	INNER JOIN #Temp T2 ON T1.[Date]=T2.[Date]

	UPDATE #Temp SET EInterfaceID=T1.Operator
	FROM
	(
		SELECT A2.[Date],A2.PumpSlNo,A2.RotationalType,A1.MachineID,A1.PumpModel,A1.Operator FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.[MeasuredDatetime]=A2.[Date] AND A1.SlNo=A2.PumpSlNo AND A1.RotationalType=A2.RotationalType
		WHERE A1.[Event]='T4'
	) T1
	INNER JOIN #Temp T2 ON T1.[Date]=T2.[Date] AND T1.PumpSlNo=T2.PumpSlNo AND T1.RotationalType=T2.RotationalType AND T1.MachineID=T2.MachineID
	AND T1.PumpModel=T2.PartNo

	UPDATE #Temp SET EmployeeName=T1.[Name],EmployeeID=T1.EmployeeID
	FROM
	(
		SELECT A2.MachineID,A2.PumpSlNo,A1.EmployeeID,A2.RotationalType,A1.[Name],A2.EInterfaceID FROM employeeinformation A1
		INNER JOIN #Temp A2 ON A1.interfaceid=A2.EInterfaceID
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpSlNo=T2.PumpSlNo AND T1.EInterfaceID=T2.EInterfaceID AND T1.RotationalType=T2.RotationalType

	UPDATE #Temp SET AssemblyChecking_Torque=T1.TorqueVal,AssemblyChecking_RPM=T1.RPMVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.RotationalType,A1.SlNo,A1.TorqueVal,A1.RPMVal FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo AND A1.SlNo=A2.PumpSlNo AND A1.RotationalType=A2.RotationalType
		WHERE A1.[Event]='T1'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo AND T1.RotationalType=T2.RotationalType

	UPDATE #Temp SET RunningInOne_Torque=T1.TorqueVal,RunningInOne_RPM=T1.RPMVal,RunningInOne_Pressure=T1.PressureVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.TorqueVal,A2.RotationalType,A1.RPMVal,A1.PressureVal FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo AND A1.SlNo=A2.PumpSlNo AND A1.RotationalType=A2.RotationalType
		WHERE A1.[Event]='T2'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo AND T1.RotationalType=T2.RotationalType

	UPDATE #Temp SET RunningInTwo_Torque=T1.TorqueVal,RunningInTwo_RPM=T1.RPMVal,RunningInTwo_Pressure=T1.PressureVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.TorqueVal,A1.RPMVal,A1.RotationalType,A1.PressureVal FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo AND A1.SlNo=A2.PumpSlNo AND A1.RotationalType=A2.RotationalType
		WHERE A1.[Event]='T3'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo AND T1.RotationalType=T2.RotationalType

	UPDATE #Temp SET Performance_Torque=T1.TorqueVal,Performance_RPM=T1.RPMVal,Performance_Pressure=T1.PressureVal,Performance_Temp=T1.TempVal,
	Performance_Flow=T1.FlowVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.TorqueVal,A1.RPMVal,A1.PressureVal,A1.TempVal,A1.FlowVal,A1.RotationalType 
		FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo AND A1.SlNo=A2.PumpSlNo AND A1.RotationalType=A2.RotationalType
		WHERE A1.[Event]='T4'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo AND T1.RotationalType=T2.RotationalType

	UPDATE #Temp SET BreakAwayPressure=PressureVal,OutletFlow=T1.FlowVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.PressureVal,A1.FlowVal,A1.RotationalType 
		FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo AND A1.SlNo=A2.PumpSlNo AND A1.RotationalType=A2.RotationalType
		WHERE A1.[Event]='T5'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo AND T1.RotationalType=T2.RotationalType

	UPDATE #Temp SET Result=T1.Result
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,(CASE WHEN A1.[Status]='OK' THEN 'Pass' ELSE 'Fail' END) AS Result
		FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo AND A1.SlNo=A2.PumpSlNo
		WHERE A1.[Event]='T4'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo

	INSERT INTO #Temp2(MinFlow,Direction,MaxRPM,MaxBar,TorqueMin,TorqueMax)
	SELECT (SELECT MIN(FlowVal) FROM #PumpTestData_Mivin),'Bidirectional',(SELECT MAX(PressureVal) - 50 FROM #PumpTestData_Mivin),
	(SELECT MAX(TempVal) -5 FROM #PumpTestData_Mivin),(SELECT MIN(TorqueMin) FROM #PumpTestData_Mivin WHERE [event]='T4'),
	(SELECT MAX(TorqueMax) FROM #PumpTestData_Mivin WHERE [event]='T4')

	SELECT * FROM #Temp
	ORDER BY [Date]

	SELECT * FROM #Temp2
END
