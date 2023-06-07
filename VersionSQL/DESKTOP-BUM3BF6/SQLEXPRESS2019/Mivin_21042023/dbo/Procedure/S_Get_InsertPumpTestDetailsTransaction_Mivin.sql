/****** Object:  Procedure [dbo].[S_Get_InsertPumpTestDetailsTransaction_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
[dbo].[S_Get_INSERTPumpTestDetailsTransaction_Mivin] '2089','R983042897','180358361','T3','2021-12-31 17:00:00.000','2021-12-31 17:32:00.000','10',
'PCT','12.0','14.7','11.8','33.8','A','','','','','','','','','','','','','','','','M'
*/
CREATE procedure [dbo].[S_Get_InsertPumpTestDetailsTransaction_Mivin]
@MachineID nvarchar(50)='',
@PumpModel nvarchar(50)='',
@SlNo nvarchar(50)='',
@Event nvarchar(50)='',
@CycleStart datetime='',
@MeasuredDatetime datetime='',
@OperationNo nvarchar(50)='',
@Operator nvarchar(50)='',
@FlowVal float=0,
@TempVal float=0,
@PressureVal float=0,
@RPMVal float=0,
@PumpAB nvarchar(50),
@ReCheckNo int=0,
@ReWorkNo int=0,
@IsMasterPump bit=0,
@Status nvarchar(50)='',
@TorqueVal float=0,
@TorqueMin float=0,
@TorqueMax float=0,
@Flow_LSL float=0,
@Flow_USL float=0,
@Temp_LSL float=0,
@Temp_USL float=0,
@Pressure_LSL float=0,
@Pressure_USL float=0,
@RPM_LSL float=0,
@RPM_USL float=0,
@ModelType nvarchar(50)='',
@RotationalType nvarchar(50)=''

AS

BEGIN
	CREATE TABLE #Temp
	(
		Machineid nvarchar(50),
		PumpModel nvarchar(50),
		SlNo nvarchar(50),
		[Event] nvarchar(50),
		CycleStart datetime,
		MeasuredDatetime datetime,
		OperationNo nvarchar(50),
		Operator nvarchar(50) ,
		FlowVal float DEFAULT 0,
		TempVal float DEFAULT 0,
		PressureVal float DEFAULT 0,
		RPMVal float DEFAULT 0,
		PumpAB nvarchar(50),
		PumpType nvarchar(50),
		RotationalType nvarchar(50),
		FlowLSL float DEFAULT 0,
		FlowUSL float DEFAULT 0,
		TempLSL float DEFAULT 0,
		TempUSL float DEFAULT 0,
		PressureLSL float DEFAULT 0,
		PressureUSL float DEFAULT 0,
		RPMLsl float DEFAULT 0,
		RPMUsl float DEFAULT 0,
		TorqueVal float DEFAULT 0,
		TorqueMin float DEFAULT 0,
		TorqueMax float DEFAULT 0,
		ReCheckNo int DEFAULT 0,
		ReWorkNo int DEFAULT 0,
		IsMasterPump bit DEFAULT 0,
		[Status] nvarchar(50),
		ModelType nvarchar(50)
	)

	IF @MachineID='2089'
	BEGIN
		INSERT INTO #Temp(Machineid,PumpModel,PumpAB,SlNo,[Event],CycleStart,MeasuredDatetime,OperationNo,Operator,FlowVal,TempVal,PressureVal,RPMVal,
		ReCheckNo,ReWorkNo,IsMasterPump,[Status],TorqueVal,TorqueMax,TorqueMin,FlowLSL,FlowUSL,TempLSL,TempUSL,PressureLSL,PressureUSL,RPMLsl,RPMUsl,
		ModelType)
		SELECT @MachineID,@PumpModel,@PumpAB,@SlNo,@Event,@CycleStart,@MeasuredDatetime,@OperationNo,@Operator,@FlowVal,@TempVal,@PressureVal,@RPMVal,
		@ReCheckNo,@ReWorkNo,@IsMasterPump,@Status,@TorqueVal,@TorqueMax,@TorqueMin,@Flow_LSL,@Flow_USL,@Temp_LSL,@Temp_USL,@Pressure_LSL,@Pressure_USL,
		@RPM_LSL,@RPM_USL,(CASE WHEN @ModelType='P' THEN 'AZPF' WHEN @ModelType='M' THEN 'AZMF' ELSE '' END)
	END
	ELSE
	BEGIN
		INSERT INTO #Temp(Machineid,PumpModel,PumpAB,SlNo,[Event],CycleStart,MeasuredDatetime,OperationNo,Operator,FlowVal,TempVal,PressureVal,RPMVal,
		ReCheckNo,ReWorkNo,IsMasterPump,[Status],FlowLSL,FlowUSL,TempLSL,TempUSL,PressureLSL,PressureUSL,RPMLsl,RPMUsl,ModelType)
		SELECT @MachineID,@PumpModel,@PumpAB,@SlNo,@Event,@CycleStart,@MeasuredDatetime,@OperationNo,@Operator,@FlowVal,@TempVal,@PressureVal,@RPMVal,
		@ReCheckNo,@ReWorkNo,@IsMasterPump,@Status,@Flow_LSL,@Flow_USL,@Temp_LSL,@Temp_USL,@Pressure_LSL,@Pressure_USL,
		@RPM_LSL,@RPM_USL,(CASE WHEN @ModelType='P' THEN 'AZPF' WHEN @ModelType='M' THEN 'AZMF' ELSE '' END)

		UPDATE #Temp SET PumpType=ISNULL(T1.[Type],'SOLO'),RotationalType=T1.RotType
		FROM
		(
			SELECT DISTINCT pumpmodel,RotationalType AS RotType,pumptype AS [Type] 
			FROM PumpModelMaster_Mivin
		) T1 
		INNER JOIN #Temp T2 ON T2.PumpModel=T1.PumpModel

		UPDATE #Temp SET FlowLSL=ISNULL(T1.flsl,0),FlowUSL=ISNULL(T1.fusl,0)
		FROM
		(
			SELECT PumpModel,PumpType,[Event],PumpAB,lsl AS flsl,usl AS fusl 
			FROM PumpModelParameterMaster_Mivin
			WHERE Parameter='Flow'
		) T1 
		INNER JOIN #Temp T2 ON T2.PumpModel=T1.PumpModel AND T2.PumpType=T1.PumpType AND T2.[Event]=T1.[Event] AND T2.PumpAB=T1.PumpAB

		UPDATE #Temp SET TempLSL=ISNULL(T1.tlsl,0),TempUSL=ISNULL(T1.tusl,0)
		FROM
		(
			SELECT PumpModel,PumpType,[Event],PumpAB,lsl AS tlsl,usl AS tusl 
			FROM PumpModelParameterMaster_Mivin
			WHERE Parameter='Temperature'
		) T1 
		INNER JOIN #Temp T2 ON T2.PumpModel=T1.PumpModel AND T2.PumpType=T1.PumpType AND T2.[Event]=T1.[Event] AND T2.PumpAB=T1.PumpAB

		UPDATE #Temp SET PressureLSL=ISNULL(T1.plsl,0),PressureUSL=ISNULL(T1.pusl,0)
		FROM
		(
			SELECT PumpModel,PumpType,[Event],PumpAB,lsl AS plsl,usl AS pusl 
			FROM PumpModelParameterMaster_Mivin
			WHERE Parameter='Pressure'
		) T1 
		INNER JOIN #Temp T2 ON T2.PumpModel=T1.PumpModel AND T2.PumpType=T1.PumpType AND T2.[Event]=T1.[Event] AND T2.PumpAB=T1.PumpAB

		UPDATE #Temp SET RPMLsl=ISNULL(T1.rplsl,0),RPMUsl=ISNULL(T1.rpusl,0)
		FROM
		(
			SELECT PumpModel,PumpType,[Event],PumpAB,lsl AS rplsl,usl AS rpusl 
			FROM PumpModelParameterMaster_Mivin
			WHERE Parameter='RPM'
		) T1 
		INNER JOIN #Temp T2 ON T2.PumpModel=T1.PumpModel AND T2.PumpType=T1.PumpType AND T2.[Event]=T1.[Event] AND T2.PumpAB=T1.PumpAB
	END

	IF NOT EXISTS(SELECT * FROM PumpTestData_Mivin WHERE MachineID=@MachineID AND PumpModel=@PumpModel AND SlNo=@SlNo AND [Event]=@Event 
	AND CycleStart=@CycleStart AND MeasuredDatetime=@MeasuredDatetime AND OperationNo=@OperationNo AND Operator=@Operator)
	BEGIN
		INSERT INTO PumpTestData_Mivin(MachineID,PumpModel,SlNo,[Event],CycleStart,MeasuredDatetime,OperationNo,Operator,FlowVal,TempVal,PressureVal,
		RPMVal,PumpAB,PumpType,RotationalType,FlowLSL,FlowUSL,TempLSL,TempUSL,PressureLSL,PressureUSL,RPMLsl,RPMUsl,ReCheckNo,ReWorkNo,IsMasterPump,
		[Status],TorqueVal,TorqueMin,TorqueMax,ModelType)
		SELECT Machineid,PumpModel,SlNo,[Event],CycleStart,MeasuredDatetime,OperationNo,Operator,FlowVal,TempVal,PressureVal,RPMVal,PumpAB,
		ISNULL(PumpType,'SOLO') AS PumpType,RotationalType,ISNULL(FlowLSL,0),ISNULL(FlowUSL,0),ISNULL(TempLSL,0),ISNULL(TempUSL,0),ISNULL(PressureLSL,0),
		ISNULL(PressureUSL,0),ISNULL(RPMLsl,0),ISNULL(RPMUsl,0),ISNULL(ReCheckNo,0),ISNULL(ReWorkNo,0),ISNULL(IsMasterPump,0),ISNULL(Status,''),
		ISNULL(TorqueVal,0),ISNULL(TorqueMin,0),ISNULL(TorqueMax,0),ModelType
		FROM #Temp
		PRINT('Inserted Successfully')
	END
END
