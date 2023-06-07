/****** Object:  Procedure [dbo].[S_Get_LoadScheduleDetails]    Committed by VersionSQL https://www.versionsql.com ******/

/*
EXEC [dbo].[S_Get_LoadScheduleDetails] '2020-08-01','2020-08-01','HMC-13','''3906749-DX04'',''5687341-DX02''','''20''','','','','','','View'
exec S_Get_LoadScheduleDetails @StartDate=N'2020-08-03',@EndDate=N'2020-08-04',@MachineId=N'',@ComponentId=N'''''',@OperationId=N'''20''',@Param=N'view'
*/

CREATE PROCEDURE [dbo].[S_Get_LoadScheduleDetails]
@StartDate DateTime,
@EndDate DateTime,

@MachineId nvarchar(50)='',
@ComponentId nvarchar(50)='',
@OperationId nvarchar(50)='',
@Shift nvarchar(50)='',
@PDT int=0,
@StdCycleTime float=0,
@ShiftTarget float=0,
@IdealCount float=0,
@Param nvarchar(50)=''

AS
Begin
Declare @Strsql nvarchar(4000),   
	 @Strmachine nvarchar(255),
	 @StrmachineID nvarchar(255), 
	 @StrComponent as nvarchar(255),
	 @StrOperation as nvarchar(255)
    
Select @Strsql = ''      
Select @Strmachine = '' 
Select @StrmachineID = ''
Select @StrComponent=''
Select @StrOperation=''

IF @Param = 'View'
BEGIN
		If isnull(@MachineId,'') <> ''    
		Begin    
		 Select @Strmachine = ' and ( mi.MachineID = N''' + @MachineID + ''')'  
		 print @Strmachine
		End 

		If isnull(@MachineId,'') <> ''    
		Begin    
		 Select @StrmachineID = ' And ( MachineInformation.MachineID = N''' + @MachineID + ''')'    
		End 

		If isnull(@ComponentId,'') <> ''    
		Begin    
		 Select @StrComponent = ' And ( c2.componentid in (' + @ComponentId + '))' 
		 print @StrComponent
		End  

		If isnull(@OperationId,'') <> ''    
		Begin    
		 Select @StrOperation = ' And ( c1.operationno in (' + @OperationId + '))' 
		 print @StrOperation
		End 

		CREATE TABLE #Target
		(
			MachineId nvarchar(50),
			ComponentId nvarchar(50),
			OperationId int,
			FromDate DateTime,
			ToDate DateTime,
			Shift nvarchar(50),
			PDT int default 0,
			StdCycleTime float,
			ShiftTarget float,
			Target float,
			TotalTarget float,
			dDate DateTime,
			SubOperations nvarchar(50),
			TargetPercent nvarchar(50),
		)

		CREATE TABLE #ShiftDetails
		( 
			dDate datetime,
			Shift nvarchar(50),
			Starttime datetime ,
			Endtime datetime,
			Shiftid int 
		)  
	
		Create table #PlannedDownTimes
		(
			MachineID nvarchar(50) NOT NULL,
			MachineInterface nvarchar(50) NOT NULL, 
			StartTime DateTime NOT NULL, 
			EndTime DateTime NOT NULL 
		)
		
		ALTER TABLE #PlannedDownTimes
			ADD PRIMARY KEY CLUSTERED
				(   [MachineInterface],
					[StartTime],
					[EndTime]
						
				) ON [PRIMARY]

		while @StartDate<=@Enddate
		Begin
			INSERT INTO #ShiftDetails(dDate,Shift,Starttime,Endtime)
			EXEC s_GetShiftTime @StartDate
			select @StartDate=DATEADD(day,1,@Startdate)
		END

		SET @strSql = ''
		SET @strSql = 'Insert into #PlannedDownTimes
			SELECT Machine,InterfaceID,
				CASE When StartTime<''' + convert(nvarchar(20),@StartDate,120)+''' Then ''' + convert(nvarchar(20),@StartDate,120)+''' Else StartTime End As StartTime,
				CASE When EndTime>''' + convert(nvarchar(20),@EndDate,120)+''' Then ''' + convert(nvarchar(20),@EndDate,120)+''' Else EndTime End As EndTime
			FROM PlannedDownTimes inner join MachineInformation on PlannedDownTimes.machine = MachineInformation.MachineID
			LEFT OUTER JOIN PlantMachine ON machineinformation.machineid = PlantMachine.MachineID 
			LEFT OUTER JOIN PlantMachineGroups ON PlantMachineGroups.PlantID = PlantMachine.PlantID 
			and PlantMachineGroups.machineid = PlantMachine.MachineID
			WHERE PDTstatus =1 and(
			(StartTime >= ''' + convert(nvarchar(20),@StartDate,120)+''' AND EndTime <=''' + convert(nvarchar(20),@EndDate,120)+''')
			OR ( StartTime < ''' + convert(nvarchar(20),@StartDate,120)+'''  AND EndTime <= ''' + convert(nvarchar(20),@EndDate,120)+''' AND EndTime > ''' + convert(nvarchar(20),@StartDate,120)+''' )
			OR ( StartTime >= ''' + convert(nvarchar(20),@StartDate,120)+'''   AND StartTime <''' + convert(nvarchar(20),@EndDate,120)+''' AND EndTime > ''' + convert(nvarchar(20),@EndDate,120)+''' )
			OR ( StartTime < ''' + convert(nvarchar(20),@StartDate,120)+'''  AND EndTime > ''' + convert(nvarchar(20),@EndDate,120)+''')) '
		SET @strSql =  @strSql + @StrmachineID  + ' ORDER BY Machine,StartTime'
		EXEC(@strSql)


		Select @Strsql =''    
		Select @Strsql ='Insert into #Target(MachineId,ComponentId, OperationId,FromDate,ToDate,Shift,StdCycleTime,SubOperations,TargetPercent,dDate)
						select mi.machineid, c2.componentid, c1.operationno,sd.Starttime,sd.Endtime,sd.Shift,c1.machiningtime,c1.SubOperations, c1.TargetPercent,sd.dDate
						from machineinformation mi 
						inner join componentoperationpricing c1 on mi.machineid = c1.machineid
						inner join componentinformation  c2 on c2.componentid = c1.componentid
						cross join #ShiftDetails sd where mi.interfaceid <> 0'
		
		Select @Strsql =@Strsql + @Strmachine + @StrComponent + @StrOperation
		print @Strsql
		Exec(@Strsql) 
	
		UPDATE #Target set PDT =isnull(PDT,0) + isnull(TT.PPDT ,0)
		FROM(

			SELECT #Target.machineID,SUM
			(CASE
			WHEN #Target.FromDate >= T.StartTime AND #Target.ToDate <=T.EndTime THEN DateDiff(second,#Target.fromdate,#Target.todate)
			WHEN ( #Target.FromDate < T.StartTime AND #Target.ToDate <= T.EndTime AND #Target.ToDate > T.StartTime ) THEN DateDiff(second,T.StartTime,#Target.todate)
			WHEN ( #Target.FromDate >= T.StartTime AND #Target.FromDate <T.EndTime AND #Target.ToDate > T.EndTime ) THEN DateDiff(second,#Target.fromdate,T.EndTime )
			WHEN ( #Target.FromDate < T.StartTime AND #Target.ToDate > T.EndTime ) THEN DateDiff(second,T.StartTime,T.EndTime )
			END) as PPDT
			FROM #Target 
			Inner join machineinformation M ON #Target.MachineID = M.machineid
			inner jOIN #PlannedDownTimes T on T.MachineInterface=M.InterfaceID
			WHERE
			(
			(#Target.fromdate >= T.StartTime AND #Target.todate <=T.EndTime)
			OR ( #Target.fromdate < T.StartTime AND #Target.todate <= T.EndTime AND #Target.todate > T.StartTime )
			OR ( #Target.fromdate >= T.StartTime AND #Target.fromdate <T.EndTime AND #Target.todate > T.EndTime )
			OR ( #Target.fromdate < T.StartTime AND #Target.todate > T.EndTime) )
			group by #Target.machineID
		)as TT  INNER JOIN #Target ON TT.machineID = #Target.MachineId

		UPDATE #Target set ShiftTarget =Round(isNull(TT.tcount ,0),0)
		From(
		SELECT T.machineID,T.ComponentId,T.OperationId,T.Ddate,
			(((datediff(second,T.FromDate,T.ToDate)-T.PDT)*T.SubOperations)/T.StdCycleTime)*isnull(T.TargetPercent,100) /100 as tcount
			FROM #Target  T
		) TT inner join #Target on TT.MachineId = #Target.MachineId and TT.ComponentId=#Target.ComponentId and TT.OperationId=#Target.OperationId and TT.dDate=#Target.dDate

		update #Target set Target = Isnull(T.IdealCount,0)
		From(
		select T1.MachineId,T1.ComponentId,T1.OperationId,T1.dDate,T1.Shift,L.IdealCount  from  #Target T1
		left join  LoadSchedule L on L.Machine = T1.MachineId and  L.Component = T1.componentid and L.Operation = T1.OperationId and L.date = T1.dDate and L.Shift = T1.Shift
		) T inner join #Target  on  T.MachineId = #Target.MachineId  and  T.ComponentId = #Target.componentid and T.OperationId = #Target.OperationId and T.dDate = #Target.dDate and T.Shift = #Target.Shift

		update #Target set TotalTarget = isnull(T.TotalTarget,0)
		From(
		select T1.MachineId,T1.ComponentId,T1.OperationId,T1.dDate, sum(isnull(Target,0)) as ToTalTarget from  #Target T1
		group by T1.MachineId,T1.ComponentId,T1.OperationId,T1.dDate
		) T inner join #Target  on  T.MachineId = #Target.MachineId  and  T.ComponentId = #Target.componentid and T.OperationId = #Target.OperationId and T.dDate = #Target.dDate

		select MachineId,ComponentId,OperationId,FromDate,ToDate,Shift,StdCycleTime,PDT,ShiftTarget,Target,TotalTarget from #Target

		--Declare 
		--	@columns NVARCHAR(MAX) = '',
		--	@sql     NVARCHAR(MAX) = '';

		--SELECT @columns = @columns + QUOTENAME(T.Shift) + ',' FROM #Target T group by T.Shift
		--SET @columns = LEFT(@columns, LEN(@columns) - 1);

		--print @columns

		--set @sql = ''
		--SET @sql ='
		--SELECT MachineId,ComponentId,OperationId,FromDate,ToDate,StdCycleTime,'+ @columns +',ShiftTarget,Target FROM   
		--(
		--	SELECT MachineId,ComponentId,OperationId,FromDate,ToDate,StdCycleTime,PDT as s1,ShiftTarget,Target,Shift
		--	FROM #Target 
		--) AS t 
		--PIVOT(max(s1) FOR Shift IN ('+ @columns + ')) AS pivot_table
		--order by  FromDate,MachineId,ComponentId,OperationId'

		--EXECUTE sp_executesql @sql;

		--set @sql =''
		--SET @sql ='
		--SELECT MachineId,ComponentId,OperationId,FromDate,ToDate,StdCycleTime,PDT,ShiftTarget,'+ @columns +' FROM   
		--(
		--	SELECT MachineId,ComponentId,OperationId,FromDate,ToDate,StdCycleTime,PDT,ShiftTarget,Target as s1,Shift
		--	FROM #Target 
		--) AS t 
		--PIVOT(max(s1) FOR Shift IN ('+ @columns + ')) AS pivot_table
		--order by  FromDate,MachineId,ComponentId,OperationId'

		--EXECUTE sp_executesql @sql;

		--set @sql =''
		--SET @sql ='
		--SELECT MachineId,ComponentId,OperationId,FromDate,ToDate,StdCycleTime,PDT,'+ @columns +',Target FROM   
		--(
		--	SELECT MachineId,ComponentId,OperationId,FromDate,ToDate,StdCycleTime,PDT,ShiftTarget as s1,Target,Shift
		--	FROM #Target 
		--) AS t 
		--PIVOT(max(s1) FOR Shift IN ('+ @columns + ')) AS pivot_table
		--order by  FromDate,MachineId,ComponentId,OperationId'

		--EXECUTE sp_executesql @sql;

END
    
IF @Param = 'Save'
BEGIN
		IF NOT EXISTS (SELECT * FROM LoadSchedule WHERE Machine=@MachineId AND Component=@ComponentId AND Operation=@OperationId AND date=@StartDate AND Shift=@Shift)
		BEGIN
			Insert into LoadSchedule(Machine,Component,Operation,date,Shift,IdealCount,PDT,StdCycleTime,ShiftTarget)
			Values (@MachineId,@ComponentId,@OperationId,@StartDate,@Shift,@IdealCount,@PDT,@StdCycleTime,@ShiftTarget)
		END
		ELSE
		BEGIN 
			Update LoadSchedule set PDT=@PDT, StdCycleTime=@StdCycleTime, ShiftTarget=@ShiftTarget, IdealCount=@IdealCount
			where Machine=@MachineId AND Component=@ComponentId AND Operation=@OperationId AND date=@StartDate AND Shift=@Shift
		END

END

ELSE IF @Param = 'Delete'
BEGIN
	Delete from LoadSchedule where Machine=@MachineId AND Component=@ComponentId AND Operation=@OperationId AND date=@StartDate AND Shift=@Shift
END

END
