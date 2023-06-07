/****** Object:  Procedure [dbo].[s_GetAggFocasDetailsForMultipleMac]    Committed by VersionSQL https://www.versionsql.com ******/

/***************************************************************************************************
-- Author:		Anjana  C V
-- Create date: 02 June 2020
Description : Focas data from aggregated data
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-07-22',@ShiftName=N'',@plantId=N'天津晟宇',@MachineId=N'',@param=N'' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-07',@ShiftName=N'Day',@plantId=N'天津晟宇',@MachineId=N'',@param=N'' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-06',@ShiftName=N'白班',@plantId=N'天津晟宇',@MachineId=N'',@param=N'Summary' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-06',@ShiftName=N'白班',@plantId=N'天津晟宇',@MachineId=N'',@param=N'Stoppages' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-07',@ShiftName=N'白班',@plantId=N'天津晟宇',@MachineId=N'',@param=N'RuntimeandDowntime' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-07',@ShiftName=N'',@plantId=N'天津晟宇',@MachineId=N'',@param=N'RuntimeandDowntime' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-07',@enddate=N'2020-04-07',@ShiftName=N'白班',@plantId=N'',@MachineId=N'',@param=N'PartsCount' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-06',@enddate=N'2020-04-07',@ShiftName=N'白班',@plantId=N'天津晟宇',@MachineId=N'',@param=N'CycleDetails' 
exec s_GetAggFocasDetailsForMultipleMac @StartDate=N'2020-04-07 07:00:00',@ShiftName=N'白班',@plantId=N'',@MachineId=N'M18-MCV-450',@param=N'OEMruntimechart'
**************************************************************************************************/
CREATE PROCEDURE [dbo].[s_GetAggFocasDetailsForMultipleMac]                
 @StartDate datetime ='',     
 @Enddate datetime = '',         
 @Shiftname nvarchar(50)='',                
 @PlantID nvarchar(50),                
 @Machineid nvarchar(1000)='',                
 @Param nvarchar(50)='' /* Summary , RuntimeAndDownTime , Stoppages, Cycle , Hourly, OEMRuntimechart */
WITH RECOMPILE              
AS              
BEGIN              
               
 SET NOCOUNT ON;  

 DECLARE @shiftstart datetime
 DECLARE @shiftend datetime
 Declare @CurStrtTime as datetime 
  
Create Table #FocasDetails                
(                
 SlNo Bigint Identity(1,1) Not Null,   
 PlantId nvarchar(50),               
 Machineid nvarchar(50),                
 MachineStatus nvarchar(100),              
 RunningProgram nvarchar(100),              
 ShiftDate datetime,                
 ShiftName nvarchar(50),
 Hourid int,        
 Fromtime datetime,                
 ToTime datetime,                
 TotalTime float,              
 Powerontime float,                
 Cuttingtime float,                
 Operatingtime float,              
 PartsCount int,   
 TotalPartsCount int,            
 ProgramNo nvarchar(500),   
 PartNumber nvarchar(500),           
 TotalTimeInPer float,              
 PowerontimeInPer float,                
 CuttingtimeInPer float,              
 OperatingtimeInPer float,    
 FinalTarget float,        
 Target float,            
 OEE float ,
 AvgOEE Float              
)                

             
Create Table #McFocasDetails                
(                  
 SlNo Bigint Identity(1,1) Not Null,                  
 Machineid nvarchar(50),                  
 FromTime datetime,                  
 Totime datetime,                  
 Powerontime float,                  
 Cuttingtime float,                  
 Operatingtime float,              
 ProgramNo nvarchar(100),               
 PartsCount int,              
 Totaltime float,              
 Totalhours float                 
)

CREATE TABLE #ShiftDetails                 
(                
 SlNo bigint identity(1,1) NOT NULL,              
 PDate datetime,                
 Shift nvarchar(20),                
 ShiftStart datetime,                
 ShiftEnd datetime                
)

       
Create Table #CycleDetails          
(          
 [Machineid] nvarchar(50),          
 [ProgramNo] nvarchar(50),       
 [CNCTimestamp] datetime,          
 [ActualCycleTime] float,          
 [IdealCycleTime] float
)          

IF ISNULL(@Enddate, '') = '' select @Enddate = getdate()
IF ISNULL(@Shiftname,'') = 'Day' AND ISNULL(@Param,'')  <> ''  BEGIN SELECT @Shiftname = '' END 
 
  
Select @CurStrtTime=@StartDate              
              
INSERT #ShiftDetails(Pdate, Shift, ShiftStart, ShiftEnd)                 
EXEC s_GetShiftTime @CurStrtTime,@Shiftname  

IF ISNULL(@Param,'')  = '' 
BEGIN
	IF ISNULL(@Shiftname,'') <> 'Day' and ISNULL(@Shiftname,'') <> ''
	BEGIN

		INSERT INTO #FocasDetails ( PlantId ,MachineID,ShiftDate,ShiftName, Fromtime, ToTime, TotalTime,Powerontime ,Cuttingtime,Operatingtime, PartsCount,
			TotalTimeInPer, PowerontimeInPer , CuttingtimeInPer, OperatingtimeInPer,Target,OEE )
		Select F.PlantID,F.MachineID,Convert(Nvarchar(10),F.Date,120) as Tdate, F.Shift,S.ShiftStart,S.ShiftEnd,
			SUM(F.TotalTime),SUM(F.PowerOntime) as POT,SUM(F.CuttingTime) as CT,SUM(F.OperatingTime) as OT,
			SUM(F.PartCount) as partcount, 100 , ISNULL(SUM(F.PowerOntime)/ SUM(F.TotalTime),0) * 100 , 
			ISNULL(SUM(F.CuttingTime)/ SUM(F.TotalTime),0) * 100 , ISNULL(SUM(F.OperatingTime)/ SUM(F.TotalTime),0) * 100 , 0,0
		from FocasWeb_ShiftwiseSummary F
		inner join PlantInformation PIN on F.PlantID=PIN.PlantID
		Inner join PlantMachine P on P.PlantID=PIN.Plantid
		Inner Join Machineinformation M on P.Machineid=M.Machineid and F.Machineid=M.Machineid
		INNER JOIN #ShiftDetails S ON Convert(Nvarchar(10),S.PDate,120)=Convert(Nvarchar(10),F.Date,120) AND S.Shift = F.Shift
		where M.TPMTrakenabled=1 and Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120) 
		AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
		AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID)
		Group by F.Date,F.PlantID,F.MachineID, F.ShiftID, F.Shift,S.ShiftStart,S.ShiftEnd
		order By F.PlantID, F.MachineID, F.Date, F.ShiftID 

		UPDATE #FocasDetails
		SET Target = T.Target
		FROM 
			(
			SELECT  DISTINCT Machineid,Shift,ShiftDate As ShiftDate, SUM(T1.Target) as Target
			FROM 
				(
				select DISTINCT F.Machineid,F.Shift,F.Date As ShiftDate,F.ProgramID,(Fc.PartCount) as PartCount ,
				(Isnull(cast(F.Cycletime as float),0)) as Cycletime,
				(ISNULL(Fc.PartCount,0) *  ISNULL(F.Cycletime,0) ) as target
				from FocasWeb_HourwiseCycles F  
				INNER JOIN (SELECT Machineid,Shift,Date,ProgramID, SUM (ISNULL(PartCount,0)) Partcount 
								FROM FocasWeb_HourwiseCycles 
								GROUP by Machineid,Shift,Date,ProgramID ) FC
					ON F.MachineID = FC.MachineID AND F.Shift = FC.Shift AND F.Date = FC.Date AND F.ProgramID = FC.ProgramID 
				) T1  		 
		    GROUP By Machineid,Shift,ShiftDate
		) T 
		 INNER JOIN #FocasDetails F ON F.Machineid = T.MachineID AND  F.ShiftName = T.Shift AND F.ShiftDate = T.ShiftDate


		UPDATE #FocasDetails
		SET ProgramNo = T.ProgramNo
		FROM ( select DISTINCT F.MachineID , F.ShiftName, F.ShiftDate,
				(
					SELECT  STUFF((SELECT top 4 ', ' + ProgramID+' '+'('+ RIGHT ('   ' + cast(SUM(ISNULL(PartCount,0))  AS varchar(7)),4)+')'
					FROM FocasWeb_HourwiseCycles   FC             
					WHERE MachineID = F.MachineID 
					AND FC.shift = F.ShiftName
					AND Date = F.ShiftDate
					GROUP By Machineid,shift,Date ,ProgramID
					order by SUM(PartCount) desc               
					FOR XML PATH('')), 1, 2,'')
				) ProgramNo
				from #FocasDetails F
			 ) T
		 INNER JOIN #FocasDetails F ON F.Machineid = T.MachineID AND  F.ShiftName = T.ShiftName AND F.ShiftDate = T.ShiftDate
 
	END
	IF ISNULL(@Shiftname,'') = 'Day' or ISNULL(@Shiftname,'') = ''
	BEGIN
		
	  Select @shiftstart = dbo.f_GetLogicalDay(@StartDate,'start')              
	  Select @Shiftend = dbo.f_GetLogicalDay(@StartDate,'End') 

		INSERT INTO #FocasDetails ( PlantId ,MachineID,ShiftDate, Fromtime, ToTime, TotalTime,Powerontime ,Cuttingtime,Operatingtime, PartsCount,
			TotalTimeInPer, PowerontimeInPer , CuttingtimeInPer, OperatingtimeInPer,Target,OEE )
		Select F.PlantID,F.MachineID,Convert(Nvarchar(10),F.Date,120) as Tdate, @shiftstart,@Shiftend,
			SUM(F.TotalTime),SUM(F.PowerOntime) as POT,SUM(F.CuttingTime) as CT,SUM(F.OperatingTime) as OT,
			SUM(F.PartCount) as partcount, 100 , ISNULL(SUM(F.PowerOntime)/ SUM(F.TotalTime),0) * 100 , 
			ISNULL(SUM(F.CuttingTime)/ SUM(F.TotalTime),0) * 100 , ISNULL(SUM(F.OperatingTime)/ SUM(F.TotalTime),0) * 100 ,
			0,0
		from FocasWeb_ShiftwiseSummary F
		inner join PlantInformation PIN on F.PlantID=PIN.PlantID
		Inner join PlantMachine P on P.PlantID=PIN.Plantid
		Inner Join Machineinformation M on P.Machineid=M.Machineid and F.Machineid=M.Machineid
		where M.TPMTrakenabled=1 and Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120) 
		AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
		AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID)
		Group by F.Date,F.PlantID,F.MachineID
		order By F.PlantID, F.MachineID, F.Date 

		UPDATE #FocasDetails
		SET Target = T.Target
		FROM 
			(
			SELECT  DISTINCT Machineid,ShiftDate, SUM(T1.Target) as Target
			FROM 
				(
				select DISTINCT F.Machineid,F.Shift,F.Date As ShiftDate,F.ProgramID,(Fc.PartCount) as PartCount ,
				(Isnull(cast(F.Cycletime as float),0)) as Cycletime,
				(ISNULL(Fc.PartCount,0) *  ISNULL(F.Cycletime,0) ) as target
				from FocasWeb_HourwiseCycles F  
				INNER JOIN (SELECT Machineid,Shift,Date,ProgramID, SUM (ISNULL(PartCount,0)) Partcount 
								FROM FocasWeb_HourwiseCycles 
								GROUP by Machineid,Shift,Date,ProgramID ) FC
					ON F.MachineID = FC.MachineID AND F.Shift = FC.Shift AND F.Date = FC.Date AND F.ProgramID = FC.ProgramID 
				) T1  		 
		    GROUP By Machineid,ShiftDate
		) T           
		 INNER JOIN #FocasDetails F ON F.Machineid = T.MachineID AND F.ShiftDate = T.ShiftDate
 
 
		UPDATE #FocasDetails
		SET ProgramNo = T.ProgramNo
		FROM ( select DISTINCT F.MachineID , F.ShiftDate,
				(SELECT  STUFF((SELECT top 4 ', ' + ProgramID+' '+'('+ RIGHT ('   ' + cast(SUM(PartCount)  AS varchar(7)),4)+')'
				FROM FocasWeb_HourwiseCycles                
				WHERE MachineID = F.MachineID 
				AND Date = F.ShiftDate
				GROUP BY MachineID,Date,ProgramID
				order by SUM(PartCount) desc              
				FOR XML PATH('')), 1, 2,'')) ProgramNo
				from #FocasDetails F
			 ) T
		 INNER JOIN #FocasDetails F ON F.Machineid = T.MachineID AND F.ShiftDate = T.ShiftDate

	END  
		UPDATE #FocasDetails
		SET TotalPartsCount = T.PartCount 
		FROM (
			SELECT MachineId , Sum(PartsCount) as PartCount
				FROM #FocasDetails
				GROUP By MachineId 
		)T  INNER JOIN #FocasDetails F ON F.MachineId = T.MachineId
	  		  
	 --  UPDATE #FocasDetails
		--SET OEE = ISNULL(Target,0) / ISNULL(DATEDIFF (s, Fromtime , ToTime ),0)
		--WHERE ISNULL(DATEDIFF (s, Fromtime , ToTime ),0) <> 0
    
		 UPDATE #FocasDetails
		SET OEE = ISNULL(Target,0) / ISNULL(Operatingtime,0)
		WHERE ISNULL(Operatingtime,0) <> 0
		  
	  UPDATE #FocasDetails
		SET OEE = ROUND((OEE * 100) , 2)
     
	 update #FocasDetails set AvgOEE= T.AvgOEE from                 
			(select ROUND(AVG(OEE),0) as AvgOEE from #FocasDetails)T 

	  Update #FocasDetails 
	  set Powerontime = Powerontime/60.00 ,
	  Cuttingtime = Cuttingtime/60.00 ,
	  Operatingtime = Operatingtime /60.00,
	  TotalTime= TotalTime/60.00
	  
	  
	---------------------------Running Part and status----------------------------------

	--UPDATE #FocasDetails
	--SET RunningProgram = T.RunningProgram
	--FROM 
	--    (SELECT  X.RunningProgram,X.MachineID from               
	--	   (              
	--		 SELECT  t.Programno as RunningProgram,t.MachineID, RANK() OVER(PARTITION BY t.MachineID  ORDER BY t.CNCTimeStamp desc) num              
	--		 FROM focas_livedata t with(NOLOCK)              
	--	    ) X           
	--	  WHERE num = 1
	--	)T 
 --   INNER JOIN #FocasDetails F ON F.Machineid = T.MachineID

	--UPDATE #FocasDetails
	--SET MachineStatus = T.MachineStatus
	--FROM 
	--    (
	--	SELECT  X.MachineStatus,X.MachineID from               
	--		 (              
	--		 SELECT  t.MachineStatus,t.MachineID, RANK() OVER(PARTITION BY t.MachineID  ORDER BY t.CNCTimeStamp desc) num              
	--		 FROM focas_livedata t with(NOLOCK)              
	--		 ) X              
	--		 WHERE num = 1
	--	) T 
 --   INNER JOIN #FocasDetails F ON F.Machineid = T.MachineID


 UPDATE #FocasDetails
 SET MachineStatus = T.MachineStatus,
     RunningProgram = T.RunningProgram  
 FROM 
     (
	 SELECT MachineID,MachineStatus,ProgramNo as RunningProgram
	 FROM Focas_MachineRunningStatus
	 ) T
 INNER JOIN #FocasDetails F ON F.Machineid = T.MachineID
	-----------------------------------------------------------------------------------
	              
	select Machineid,[From Time],[To Time],MachineStatus as MachineStatus,RunningProgram as RunningProgram,
	TotalTime,[Powerontime],[Operating time], [Cutting time],
	PartsCount,OEE,0 AvgOEE,TotalPartsCount ,              
	parsename(ProgramNo,1) as ProgramNo1              
	,parsename(ProgramNo,2) as ProgramNo2              
	,parsename(ProgramNo,3) as ProgramNo3,              
	parsename(ProgramNo,4) as ProgramNo4          
	FROM(
	SELECT DISTINCT  PlantId ,MachineID,MachineStatus,RunningProgram,ShiftDate,ShiftName, Fromtime as [From Time] , ToTime as [To Time],        
			CAST(ROUND(TotalTime,0)  AS varchar(10))+' '+'('+ cast(ROUND(TotalTimeInPer,0)  AS varchar(7))+'%'+')' as TotalTime,
			PartsCount,TotalPartsCount,          
			CAST(ROUND(Powerontime,0)  AS varchar(10))+' '+'('+ cast(ROUND(PowerontimeInPer,0)  AS varchar(7))+'%'+')'  as Powerontime,              
			CAST(ROUND(Cuttingtime,0)  AS varchar(10))+' '+'('+ cast(ROUND(CuttingtimeInPer,0) AS varchar(7))+'%'+')' as [Cutting time],              
			CAST(ROUND(Operatingtime,0)  AS varchar(10))+' '+'('+ cast(ROUND(OperatingtimeInPer,0) AS varchar(7))+'%'+')' as [Operating time],
			Target,OEE,replace(ProgramNo,',','.') as ProgramNo
	FROM #FocasDetails
	) t 
END              

IF ISNULL(@Param,'')  = 'Summary' 
BEGIN

   INSERT INTO #FocasDetails ( PlantId ,MachineID,ShiftDate, Fromtime, ToTime, 
							TotalTime,Powerontime ,Cuttingtime,Operatingtime )
		Select F.PlantID,F.MachineID,Convert(Nvarchar(10),F.Date,120) as Tdate, HourStart,HourEnd,
			ISNULL(DATEDIFF( s,HourStart,HourEnd),0),ISNULL(F.PowerOntime,0) as POT,ISNULL(F.CuttingTime,0) as CT,ISNULL(F.OperatingTime,0) as OT
		from FocasWeb_HourwiseTimeInfo F
		inner join PlantInformation PIN on F.PlantID=PIN.PlantID
		Inner join PlantMachine P on P.PlantID=PIN.Plantid
		Inner Join Machineinformation M on P.Machineid=M.Machineid and F.Machineid=M.Machineid
		INNER JOIN #ShiftDetails S ON Convert(Nvarchar(10),S.PDate,120)=Convert(Nvarchar(10),F.Date,120) AND S.Shift = F.Shift
		where M.TPMTrakenabled=1 and Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120) 
		AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
		AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID)
		--Group by F.Date,F.PlantID,F.MachineID, F.ShiftID, F.Shift,S.ShiftStart,S.ShiftEnd , HourStart,HourEnd
		order By F.PlantID, F.MachineID, F.Date, F.ShiftID

  UPDATE #FocasDetails
   SET PartsCount = T.PartCount
   FROM (
		Select MachineId,HourStart,Sum(ISNULL(PartCount,0)) As PartCount
		from FocasWeb_HourwiseCycles
		GROUP By MachineId,HourStart
		)T
	INNER JOIN #FocasDetails F On F.Machineid = T.MachineId AND F.Fromtime = T.HourStart

 	


----------------total data at Machineid level----------------------

--Insert into #McFocasDetails(Machineid,FromTime,Totime--,Powerontime,Cuttingtime,Operatingtime,Partscount
--							)
--	SELECT MachineId, Min(Fromtime),Max(ToTime)--,0,0,0,0,0
--	FROM #FocasDetails                
--    group by Machineid            
              
              
-- Update #McFocasDetails set Powerontime  = Isnull(Powerontime,0) + ISNULL(T1.PTime,0),                  
-- Cuttingtime  = Isnull(Cuttingtime,0) + ISNULL(T1.CTime,0),                  
-- Operatingtime = Isnull(Operatingtime,0) + ISNULL(T1.OTime,0) from                   
-- (
--	 Select F.machineid,L.FromTime as Fromtime,L.Totime as Totime,Max(F.Powerontime) - Min(F.Powerontime) as Ptime,                  
--	 Max(F.CuttingTime)- Min(F.CuttingTime) as CTime,Max(F.OperatingTime)- Min(F.OperatingTime) as OTime 
--	 from dbo.FocasWeb_HourwiseTimeInfo F                  
--	 inner join #McFocasDetails L on L.machineid=F.machineid and F.HourStart>=L.FromTime and F.HourEnd<=L.ToTime                       
--	 group by F.machineid,L.FromTime,L.Totime
-- )T1                  
-- inner join #McFocasDetails on #McFocasDetails.FromTime = T1.Fromtime and #McFocasDetails.Machineid = T1.MachineID                  
 
--Insert into #McFocasDetails(Machineid,FromTime,Totime,Powerontime,Cuttingtime,Operatingtime,Partscount
--							)
--	SELECT MachineId, Min(Fromtime),Max(ToTime),SUM(Powerontime),SUM(Cuttingtime),SUM(Operatingtime),SUM(Partscount)
--	FROM #FocasDetails                
--    group by Machineid            
              
 
-- Update #McFocasDetails set Powerontime = Powerontime/3600.00 where Powerontime>0              
-- Update #McFocasDetails Set Cuttingtime = Cuttingtime/3600.00 where Cuttingtime>0                   
-- Update #McFocasDetails Set Operatingtime = Operatingtime /3600.00 where Operatingtime>0                 
-- update #McFocasDetails set [TotalTime]=case when FromTime<getdate() then  DATEDIFF( S,FromTime,Totime)/3600 else 0 end              
-- update #McFocasDetails set [TotalHours]=case when FromTime<getdate() then  DATEDIFF( S,FromTime,Totime)/3600 else 0 end             


Insert into #McFocasDetails(Machineid,TotalHours,Totaltime,Powerontime,Cuttingtime,Operatingtime,Partscount )
 Select F.MachineID,SUM(ISNULL(F.TotalTime,0)) as TT,SUM(ISNULL(F.TotalTime,0)) as TT,SUM(ISNULL(F.PowerOntime,0)) as POT,SUM(ISNULL(F.CuttingTime,0)) as CT,SUM(ISNULL(F.OperatingTime,0)) as OT, Sum(partCount)
		from FocasWeb_ShiftwiseSummary F
		where  Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120)
		       AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
			   AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID) 
		       AND (ISNULL ( @Shiftname,'') = '' OR F.Shift = @Shiftname)  
		GROUP By F.PlantID, F.MachineID, F.Date, F.ShiftID             
 
--Insert into #McFocasDetails(Machineid,Powerontime,Cuttingtime,Operatingtime,Partscount )
-- Select F.Machineid,SUM(ISNULL(F.PowerOntime,0)) as POT,
--		SUM(ISNULL(F.CuttingTime,0)) as CT,SUM(ISNULL(F.OperatingTime,0)) as OT, Sum(PartsCount)
--		from #FocasDetails F
--		where (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
--			  -- AND  Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120)
--			   AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID) 
--		      -- AND (ISNULL ( @Shiftname,'') = '' OR F.Shift = @Shiftname)  
--		GROUP By F.PlantID, F.MachineID--, F.Date, F.ShiftID  

UPDATE #McFocasDetails
SET Fromtime = T. Fromtime ,
    ToTime = T.ToTime
FROM (
      SELECT Machineid,Min(Fromtime) as FromTime,Max(ToTime) as Totime
	  FROM #FocasDetails                
      group by Machineid  
	 ) T 
INNER JOIN  #McFocasDetails m ON M.Machineid = T.Machineid

 Update #McFocasDetails 
    set Powerontime = Powerontime/3600.00 
    where Powerontime>0     
	         
 Update #McFocasDetails 
    Set Cuttingtime = Cuttingtime/3600.00 
	where Cuttingtime>0    
	               
 Update #McFocasDetails 
    Set Operatingtime = Operatingtime /3600.00 
	where Operatingtime>0   


Update #McFocasDetails 
    Set Totalhours = Totalhours /3600.00 
	where Totalhours>0   


Update #McFocasDetails 
    Set Totaltime = Totaltime /3600.00 
	where Totaltime>0   

	        
 --update #McFocasDetails 
 --   set [TotalTime]=case 
	--when FromTime<getdate() then  DATEDIFF( S,FromTime,Totime)/3600 else 0 end     
	         
 --update #McFocasDetails 
 --   set [TotalHours]=case 
	--when FromTime<getdate() then  DATEDIFF( S,FromTime,Totime)/3600 else 0 end             

 Update #FocasDetails 
  set Powerontime = Powerontime/60.00 ,
	  Cuttingtime = Cuttingtime/60.00 ,
	  Operatingtime = Operatingtime/60.00,
	  TotalTime= TotalTime/60.00 

 -------------------------output---------------------------------- 	
 SELECT MachineId, Fromtime as [From Time] ,ToTime as [To Time],TotalTime,Powerontime,Cuttingtime as [Cutting time],Operatingtime as [Operating time]  
  FROM #FocasDetails 

 Select Round(sum(ISNULL(Powerontime,0)),2) as [Powerontime],
	 Round(sum(ISNULL(Cuttingtime,0)),2) as [Cutting time],                
	 Round(SUM((ISNULL(TotalTime,0))),2) as [TotalTime], --round(sum(TotalTime),2) as [TotalTime],
	 Round(SUM((ISNULL(TotalHours,0))),2) as TotalHours , --round(Sum(ISNULL(TotalHours,0)),2) as TotalHours    
	 Round(sum((ISNULL(Operatingtime,0)-ISNULL(Cuttingtime,0))),2) as OperatingWithoutCutting,                
	 Round(sum((ISNULL(Powerontime,0)-ISNULL(Operatingtime,0))),2) as NonOperatingTime, 
	 Round((SUM((ISNULL(TotalTime,0)))-sum(ISNULL(Powerontime,0))),2) as PowerOffTime,              
	 Round(sum(ISNULL(Operatingtime,0)),2) as  [Operating time],              
	 Sum(ISNULL(PartsCount,0)) as PartsCount 
	 --,round(SUM(ISNULL(TotalHours,0)),2) as TotalHours               
	From #McFocasDetails  
	--group by [TotalTime],TotalHours
			
END
IF ISNULL(@Param,'')  = 'Stoppages' 
BEGIN

  SELECT PIN.PlantCode,F.PlantID, M.Interfaceid AS MCInterface,F.MachineID,F.ShiftID, F.Shift, F.Batchstart as Batchstart, F.BatchEnd as BatchEnd,
     StoppageTime, F.Reason as Reason, 0 as TotalStoppage
	INTO #MachineStoppage
	FROM  FocasWeb_ShiftwiseStoppages F
   	inner join PlantInformation PIN on F.PlantID=PIN.PlantID
	Inner join PlantMachine P on P.PlantID=PIN.Plantid
	Inner Join Machineinformation M on P.Machineid=M.Machineid and F.Machineid=M.Machineid
	where M.TPMTrakenabled=1 and Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120)
	AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
	AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID)
	AND (ISNULL ( @Shiftname,'') = '' OR F.Shift = @Shiftname) 
	order By PIN.PlantCode, F.MachineID,ShiftID,Batchstart

	UPDATE #MachineStoppage
	SET TotalStoppage = T.TotalStoppage
	FROM (
	      SELECT MachineID , SUM(StoppageTime) as TotalStoppage 
		  FROm #MachineStoppage
		  GROUP BY MachineID
		 ) T INNER JOIN #MachineStoppage M ON M.MachineID = T.MachineID

	SELECT PlantCode, PlantID, MCInterface,MachineID,ShiftID, Shift,Batchstart, BatchEnd,
     dbo.f_FormatTime(StoppageTime,'hh:mm:ss')as StoppageTime, Reason , dbo.f_FormatTime(TotalStoppage,'hh:mm:ss') as TotalStoppage
	FROM  #MachineStoppage

END

IF ISNULL(@Param,'')  = 'RuntimeandDowntime'  OR ISNULL(@Param,'')  = 'OEMruntimechart' 
BEGIN

	SELECT PIN.PlantCode,F.PlantID, M.Interfaceid AS MCInterface,F.MachineID,F.ShiftID, F.Shift, F.Batchstart, F.BatchEnd,
    dbo.f_FormatTime(F.StoppageTime,'hh:mm:ss')as StoppageTime, F.MachineStatus as Reason --F.Reason
	FROM  FocasWeb_RuntimeData F
	LEFT join PlantInformation PIN on F.PlantID=PIN.PlantID
	LEFT join PlantMachine P on P.PlantID=PIN.Plantid
	Inner Join Machineinformation M on P.Machineid=M.Machineid and F.Machineid=M.Machineid
	where M.TPMTrakenabled=1 
	and Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120) 
	AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
	AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID)
	AND (ISNULL ( @Shiftname,'') = '' OR F.Shift = @Shiftname)
	order By PIN.PlantCode, F.MachineID,ShiftID,Batchstart

END

-- Commented to handle shift defination Change : ACV

--IF ISNULL(@Param,'')  = 'OEMruntimechart' 
--BEGIN
    
--	Select @shiftstart = @StartDate             
--	Select @Shiftend = dateadd(hour,4,@StartDate)  

--	SELECT PIN.PlantCode,F.PlantID, M.Interfaceid AS MCInterface,F.MachineID,F.ShiftID, F.Shift, 
--	--F.Batchstart, F.BatchEnd,
--	(CASE WHEN @shiftstart<= F.Batchstart THEN F.Batchstart ELSE @shiftstart END ) AS Batchstart, 
--	(CASE WHEN @shiftend >= F.BatchEnd THEN F.BatchEnd ELSE @shiftend END ) AS BatchEnd,
--    --dbo.f_FormatTime(F.StoppageTime,'hh:mm:ss')as StoppageTime, 
--	dbo.f_FormatTime( 
--		( CASE WHEN ( F.Batchstart >= @shiftstart AND F.BatchEnd <= @Shiftend ) 
--		           THEN DATEDIFF(s,F.Batchstart,F.BatchEnd)
--		      WHEN ( F.Batchstart < @shiftstart  AND F.BatchEnd <= @Shiftend AND F.BatchEnd > @shiftstart )
--			       THEN DATEDIFF(s,@shiftstart,F.BatchEnd)
--			  WHEN ( F.Batchstart >= @shiftstart   AND F.Batchstart <@Shiftend AND F.BatchEnd > @Shiftend )  
--			       THEN DATEDIFF(s,F.Batchstart,@Shiftend)
--			  WHEN ( F.Batchstart < @shiftstart  AND F.BatchEnd > @Shiftend) 
--			       THEN DATEDIFF(s,@shiftstart,@Shiftend)
--		END
--		),'hh:mm:ss') as StoppageTime, 
--	F.MachineStatus as Reason 
--	FROM  FocasWeb_RuntimeData F
--	LEFT join PlantInformation PIN on F.PlantID=PIN.PlantID
--	LEFT join PlantMachine P on P.PlantID=PIN.Plantid
--	Inner Join Machineinformation M on P.Machineid=M.Machineid and F.Machineid=M.Machineid
--	where M.TPMTrakenabled=1 
--	AND  ( ( F.Batchstart >= @shiftstart AND F.BatchEnd <= @Shiftend )
--	 OR ( F.Batchstart < @shiftstart  AND F.BatchEnd <= @Shiftend AND F.BatchEnd > @shiftstart )  
--	 OR ( F.Batchstart >= @shiftstart   AND F.Batchstart <@Shiftend AND F.BatchEnd > @Shiftend )  
--     OR ( F.Batchstart < @shiftstart  AND F.BatchEnd > @Shiftend) ) 

--	--and Convert(Nvarchar(10),Date,120)=Convert(Nvarchar(10),@StartDate,120) 
--	AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
--	AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID)
--	order By PIN.PlantCode, F.MachineID,ShiftID,Batchstart

--END

IF ISNULL(@Param,'')  = 'PartsCount' 
BEGIN
   INSERT INTO #FocasDetails ( PlantId ,MachineID,ShiftDate,ShiftName, Fromtime, ToTime, Hourid,
				TotalTime,Powerontime ,Cuttingtime,Operatingtime )
	Select F.PlantID,F.MachineID,Convert(Nvarchar(10),F.Date,120) as Tdate,F.Shift, HourStart,HourEnd,F.HourID,
			ISNULL(DATEDIFF( s,HourStart,HourEnd),0),ISNULL(F.PowerOntime,0) as POT,ISNULL(F.CuttingTime,0) as CT,ISNULL(F.OperatingTime,0) as OT
		from FocasWeb_HourwiseTimeInfo F
		--inner join PlantInformation PIN on F.PlantID=PIN.PlantID
		--Inner join PlantMachine P on P.PlantID=PIN.Plantid
		--Inner Join Machineinformation M on P.Machineid=M.Machineid and F.Machineid=M.Machineid
		--where M.TPMTrakenabled=1 and 
		where Convert(Nvarchar(10),Date,120)>=Convert(Nvarchar(10),@StartDate,120) 
		and Convert(Nvarchar(10),Date,120)<=Convert(Nvarchar(10),@Enddate,120) 
		AND (ISNULL ( @MachineID,'') = '' OR F.MachineID = @Machineid)
		AND (ISNULL ( @PlantID,'') = '' OR F.PlantID = @PlantID)
		AND (ISNULL ( @Shiftname,'') = '' OR F.Shift = @Shiftname)
		order By F.PlantID, F.MachineID, F.Date, F.ShiftID,F.HourID

   UPDATE #FocasDetails
   SET PartsCount = T.PartCount
   FROM (
		Select MachineId,HourStart,Sum(ISNULL(PartCount,0)) As PartCount
		from FocasWeb_HourwiseCycles
		GROUP By MachineId,HourStart
		)T
	INNER JOIN #FocasDetails F On F.Machineid = T.MachineId AND F.Fromtime = T.HourStart	


 UPDATE #FocasDetails
   SET ProgramNo = T.ProgramNo,
       PartNumber = T.PartNumber
   FROM (
		Select MachineId,HourStart,ProgramId as Programno, ProgramBlock as Partnumber
		from FocasWeb_HourwiseCycles
		)T
	INNER JOIN #FocasDetails F On F.Machineid = T.MachineId AND F.Fromtime = T.HourStart

	UPDATE #FocasDetails
		SET TotalPartsCount = T.PartCount 
		FROM (
			SELECT MachineId , Sum(PartsCount) as PartCount
				FROM #FocasDetails
				GROUP By MachineId 
		)T  INNER JOIN #FocasDetails F ON F.MachineId = T.MachineId
	   	   
	--update #FocasDetails 
	--set Target= T.Ftarget 
	--from                 
	--(select M.Machineid,ROUND(ISNULL(cast(M.OEETarget as float),0),2) as Ftarget 
	--from machineinformation M
	--)T inner join  #FocasDetails F on F.machineID=T.MachineID 
	      
	update #FocasDetails set Target= T.Target from               
	(select T.Machineid,T.Fromtime,T.ProgramNo,
	ROUND((ISNULL(cast(T.Partscount as float),0)*(Isnull(cast(F.Cycletime as float),0))),2) as Target 
	from #FocasDetails T          
	inner join Focas_ProgramwiseTarget F on F.Machineid=T.Machineid and F.ProgramNo=T.ProgramNo)T 
	inner join #FocasDetails on #FocasDetails.machineID=T.MachineID and #FocasDetails.ProgramNo=T.ProgramNo 
	and #FocasDetails.Fromtime=T.Fromtime  
	
	--UPDATE #FocasDetails
	--SET OEE = ISNULL(Target,0) / ISNULL(DATEDIFF (s, Fromtime , ToTime ),0)
	--WHERE ISNULL(DATEDIFF (s, Fromtime , ToTime ),0) <> 0        
   
   	UPDATE #FocasDetails
	SET OEE = ISNULL(Target,0) / ISNULL(Operatingtime,0)
	WHERE ISNULL(Operatingtime,0) <> 0
		  
    update #FocasDetails 
	set FinalTarget= T.Ftarget 
	from                 
	(select M.Machineid,ROUND(ISNULL(cast(M.OEETarget as float),0),2) as Ftarget 
	from machineinformation M
	)T inner join  #FocasDetails F on F.machineID=T.MachineID 

	 UPDATE #FocasDetails
		SET OEE = OEE * 100

     update #FocasDetails set AvgOEE= T.AvgOEE from                 
			(select ROUND(AVG(OEE),0) as AvgOEE from #FocasDetails)T 


 --Insert into #McFocasDetails(Machineid,FromTime,Totime
	--						)
	--SELECT MachineId, Min(Fromtime),Max(ToTime)
	--FROM #FocasDetails                
 --   group by Machineid            
            
 --Update #McFocasDetails set Powerontime  = Isnull(Powerontime,0) + ISNULL(T1.PTime,0),                  
 --Cuttingtime  = Isnull(Cuttingtime,0) + ISNULL(T1.CTime,0),                  
 --Operatingtime = Isnull(Operatingtime,0) + ISNULL(T1.OTime,0) from                   
 --(Select F.machineid,L.FromTime as Fromtime,L.Totime as Totime,Max(F.Powerontime) - Min(F.Powerontime) as Ptime,                  
 --Max(F.CuttingTime)- Min(F.CuttingTime) as CTime,Max(F.OperatingTime)- Min(F.OperatingTime) as OTime 
 --from dbo.FocasWeb_HourwiseTimeInfo F                  
 --inner join #McFocasDetails L on L.machineid=F.machineid and F.HourStart>=L.FromTime and F.HourEnd<=L.ToTime                       
 --group by F.machineid,L.FromTime,L.Totime)T1                  
 --inner join #McFocasDetails on #McFocasDetails.FromTime = T1.Fromtime and #McFocasDetails.Machineid = T1.MachineID                  
              
 
Insert into #McFocasDetails(Machineid,FromTime,Totime,Powerontime,Cuttingtime,Operatingtime,Partscount
							)
	SELECT MachineId, Min(Fromtime),Max(ToTime),SUM(Powerontime),SUM(Cuttingtime),SUM(Operatingtime),SUM(Partscount)
	FROM #FocasDetails                
    group by Machineid            
              
 
 Update #McFocasDetails set Powerontime = Powerontime/3600.00 where Powerontime>0              
 Update #McFocasDetails Set Cuttingtime = Cuttingtime/3600.00 where Cuttingtime>0                   
 Update #McFocasDetails Set Operatingtime = Operatingtime /3600.00 where Operatingtime>0                 
 update #McFocasDetails set [TotalTime]=case when FromTime<getdate() then  DATEDIFF( S,FromTime,Totime)/3600 else 0 end              
 update #McFocasDetails set [TotalHours]=case when FromTime<getdate() then  DATEDIFF( S,FromTime,Totime)/3600 else 0 end           
   
 -------------------------output---------------------------------- 	
  
Update #FocasDetails 
set Powerontime = Powerontime/60.00 ,
	Cuttingtime = Cuttingtime/60.00 ,
	Operatingtime = Operatingtime /60.00,
	TotalTime= TotalTime/60.00

	SELECT SlNo as Id ,PlantId ,MachineID,ShiftDate,ShiftName, Fromtime as [From Time] , ToTime as [To Time],        
			TotalTime,Powerontime,Cuttingtime AS  [Cutting time], Operatingtime as [Operating time],
			PartsCount,TotalPartsCount ,ProgramNo,PartNumber,FinalTarget as FinalTarget, OEE,  AvgOEE  
	FROM #FocasDetails
              
	Select Round(sum(Powerontime),2) as [Powerontime],Round(sum(Cuttingtime),2) as [Cutting time],                
	 round(sum(TotalTime),2) as [TotalTime],round(sum((Operatingtime-Cuttingtime)),2) as OperatingWithoutCutting,                
	 Round(sum((Powerontime-Operatingtime)),2) as NonOperatingTime,round(sum((TotalTime-Powerontime)),2) as PowerOffTime,              
	 Round(sum(Operatingtime),2) as  [Operating time],              
	 sum(PartsCount) as PartsCount,round(Sum(TotalHours),2) as TotalHours               
	 From #McFocasDetails

END

IF ISNULL(@Param,'')  = 'CycleDetails' 
BEGIN
    INSERT INTO #CycleDetails ( Machineid,ProgramNo,CNCTimestamp,ActualCycleTime,IdealCycleTime)
	Select FC.[Machineid],FC.[ProgramNo],FC.[CNCTimestamp] as CNCTimestamp,FC.CycleTime as ActualCycleTime,
	Case when FT.Target>0 then (3600/FT.Target) Else ISNULL(FT.Target,0) END as IdealCycleTime
	from Focas_CycleDetails FC
	inner join Machineinformation on Machineinformation.Machineid=FC.Machineid
	inner join PlantMachine on PlantMachine.Machineid=FC.Machineid 
	Left Outer join Focas_ProgramwiseTarget FT on  FC.[Machineid]=FT.[Machineid] and FC.[ProgramNo]=FT.[ProgramNo] 
	where FC.[CNCTimestamp]>= @StartDate and FC.[CNCTimestamp]<= @Enddate
	 AND (ISNULL ( @MachineID,'') = '' OR FC.MachineID = @Machineid)
	 AND (ISNULL ( @PlantID,'') = '' OR PlantMachine.PlantID = @PlantID)

	 Select ROW_NUMBER() OVER(Order By [CNCTimestamp]) as IDD,
	 [Machineid],[ProgramNo],[CNCTimestamp],[ActualCycleTime],[IdealCycleTime] 
	 From #CycleDetails 
	 Order by [CNCTimestamp]

 END
END
