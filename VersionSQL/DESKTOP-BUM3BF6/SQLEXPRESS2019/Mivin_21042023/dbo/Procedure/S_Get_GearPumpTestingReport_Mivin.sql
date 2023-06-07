/****** Object:  Procedure [dbo].[S_Get_GearPumpTestingReport_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
EXEC [dbo].[S_Get_GearPumpTestingReport_Mivin] '2089','R983041554','2023-04-01 10:30:00.000',''	
*/
CREATE PROCEDURE [dbo].[S_Get_GearPumpTestingReport_Mivin]
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
		Result nvarchar(50)
	)

	CREATE TABLE #Temp2
	(
		MinFlow float,
		Direction nvarchar(50),
		MaxBar float,
		MaxRPM float
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
	INNER JOIN #Temp T2 ON T1.SlNo=T2.PumpSlNo AND T1.MachineID=T2.MachineID AND T1.PartNo=T2.PartNo AND T1.RotationalType=T2.RotationalType

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
		SELECT A2.[Date],A2.PumpSlNo,A1.Operator,A1.MachineID,A1.PumpModel FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.[MeasuredDatetime]=A2.[Date] AND A1.SlNo=A2.PumpSlNo AND A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo
		WHERE A1.[Event]='T4'
	) T1
	INNER JOIN #Temp T2 ON T1.[Date]=T2.[Date] AND T1.PumpSlNo=T2.PumpSlNo AND T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo

	
	UPDATE #Temp SET EmployeeName=T1.[Name],EmployeeID=T1.EmployeeID
	FROM
	(
		SELECT A2.MachineID,A2.PumpSlNo,A1.EmployeeID,A1.[Name],A2.EInterfaceID FROM employeeinformation A1
		INNER JOIN #Temp A2 ON A1.interfaceid=A2.EInterfaceID
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpSlNo=T2.PumpSlNo AND T1.EInterfaceID=T2.EInterfaceID


	UPDATE #Temp SET AssemblyChecking_Torque=T1.TorqueVal,AssemblyChecking_RPM=T1.RPMVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.TorqueVal,A1.RPMVal,A1.MeasuredDatetime FROM #PumpTestData_Mivin A1
		INNER JOIN (SELECT DISTINCT MachineID,PumpModel,SlNo,MAX(MeasuredDatetime) AS [Date] FROM #PumpTestData_Mivin WHERE [Event]='T1' 
		GROUP BY MachineID,PumpModel,SlNo) A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PumpModel AND A1.[MeasuredDatetime]=A2.[Date] 
		AND A1.SlNo=A2.SlNo 
		WHERE A1.[Event]='T1'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo

	UPDATE #Temp SET RunningInOne_Torque=T1.TorqueVal,RunningInOne_RPM=T1.RPMVal,RunningInOne_Pressure=T1.PressureVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.TorqueVal,A1.RPMVal,A1.PressureVal FROM #PumpTestData_Mivin A1
		INNER JOIN (SELECT DISTINCT MachineID,PumpModel,SlNo,MAX(MeasuredDatetime) AS [Date] FROM #PumpTestData_Mivin WHERE [Event]='T2' 
		GROUP BY MachineID,PumpModel,SlNo) A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PumpModel AND A1.[MeasuredDatetime]=A2.[Date] 
		AND A1.SlNo=A2.SlNo 
		WHERE A1.[Event]='T2'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo

	UPDATE #Temp SET RunningInTwo_Torque=T1.TorqueVal,RunningInTwo_RPM=T1.RPMVal,RunningInTwo_Pressure=T1.PressureVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.TorqueVal,A1.RPMVal,A1.PressureVal FROM #PumpTestData_Mivin A1
		INNER JOIN (SELECT DISTINCT MachineID,PumpModel,SlNo,MAX(MeasuredDatetime) AS [Date] FROM #PumpTestData_Mivin WHERE [Event]='T3' 
		GROUP BY MachineID,PumpModel,SlNo) A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PumpModel AND A1.[MeasuredDatetime]=A2.[Date] 
		AND A1.SlNo=A2.SlNo 
		WHERE A1.[Event]='T3'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo

	UPDATE #Temp SET Performance_Torque=T1.TorqueVal,Performance_RPM=T1.RPMVal,Performance_Pressure=T1.PressureVal,Performance_Temp=T1.TempVal,
	Performance_Flow=T1.FlowVal
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,A1.TorqueVal,A1.RPMVal,A1.PressureVal,A1.TempVal,A1.FlowVal FROM #PumpTestData_Mivin A1
		INNER JOIN (SELECT DISTINCT MachineID,PumpModel,SlNo,MAX(MeasuredDatetime) AS [Date] FROM #PumpTestData_Mivin WHERE [Event]='T4' 
		GROUP BY MachineID,PumpModel,SlNo) A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PumpModel AND A1.[MeasuredDatetime]=A2.[Date] 
		AND A1.SlNo=A2.SlNo 
		WHERE A1.[Event]='T4'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo

	UPDATE #Temp SET Result=T1.Result
	FROM
	(
		SELECT DISTINCT A1.MachineID,A1.PumpModel,A1.SlNo,(CASE WHEN A1.[Status]='OK' THEN 'Pass' ELSE 'Fail' END) AS Result
		FROM #PumpTestData_Mivin A1
		INNER JOIN #Temp A2 ON A1.MachineID=A2.MachineID AND A1.PumpModel=A2.PartNo AND A1.[MeasuredDatetime]=A2.[Date] AND A1.SlNo=A2.PumpSlNo 
		WHERE A1.[Event]='T4'
	) T1
	INNER JOIN #Temp T2 ON T1.MachineID=T2.MachineID AND T1.PumpModel=T2.PartNo AND T1.SlNo=T2.PumpSlNo

	INSERT INTO #Temp2(MinFlow,Direction,MaxRPM,MaxBar)
	SELECT (SELECT MIN(FlowVal) FROM #PumpTestData_Mivin),(SELECT DISTINCT RotationalType FROM #PumpTestData_Mivin),
	(SELECT MAX(RPMVal) - 50 FROM #PumpTestData_Mivin),(SELECT MAX(PressureVal) -5 FROM #PumpTestData_Mivin)

	SELECT * FROM #Temp
	ORDER BY [Date]

	SELECT * FROM #Temp2
END
