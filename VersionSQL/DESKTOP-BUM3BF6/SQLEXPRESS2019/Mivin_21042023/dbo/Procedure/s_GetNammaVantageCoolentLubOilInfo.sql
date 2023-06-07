/****** Object:  Procedure [dbo].[s_GetNammaVantageCoolentLubOilInfo]    Committed by VersionSQL https://www.versionsql.com ******/

 --   s_GetNammaVantageCoolentLubOilInfo '2015-01-01', '2015-01-03','VANTAGE MSY 01','CoolentLevelsummary'
CREATE PROCEDURE [dbo].[s_GetNammaVantageCoolentLubOilInfo]    
 @StartTime datetime,    
 @EndTime datetime,    
 @MachineID nvarchar(50) = '',    
 @Param nvarchar(20)=''    
     
AS    
BEGIN    
    
   declare @LubOilLevel as int 
   declare @CoolentLevel as int 
  select  @LubOilLevel = isnull(valueinint,0) from shopdefaults where parameter='LubOilTankCapacityInLitres'   
  select @CoolentLevel = isnull(valueinint,0) from shopdefaults where parameter='CoolentTankCapacityInLitres'    
    
IF @param='CoolentLevelDetails'    
Begin    
  
  Select CNCTimeStamp as RefillTime,PrevCoolentLevel,coolentlevel,((CoolentLevel/4095)*100) as QtyAfterRefill ,((PrevCoolentLevel/4095)*100) as QtyBeforeRefill,
  (((CoolentLevel-PrevCoolentLevel)/4095)*100) as Consumption,(((CoolentLevel-PrevCoolentLevel)/4095)*@CoolentLevel) as litres from Focas_CoolentLubOilInfo    
 where  machineid=@machineid and CNCTimeStamp>=@StartTime and 
 CNCTimeStamp<=@EndTime  and (((CoolentLevel-PrevCoolentLevel)/4095)*100) >= 10  
 Order by CNCTimeStamp    
    
End    
    
    
IF @param='CoolentLevelsummary'    
Begin    
    
 create table #Coolentlevelsummary    
 (    
  NoOfAlerts int,    
  NoOfRefills int,    
  Consumption decimal(18,3),
  litres decimal(18,3)    
 )    
    
 Insert into #Coolentlevelsummary(NoOfAlerts)    
 select isnull(count(*),0) from Focas_CoolentLubOilAlertsInfo where machineid=@machineid    
 and AlertTimestamp>=@StartTime and AlertTimestamp<=@endtime and AlertType='Coolant'    
    
 update #Coolentlevelsummary set NoOfRefills = T1.NoOfRefills from    
 (Select isnull(count(*),0) as NoOfRefills from  Focas_CoolentLubOilInfo    
 where  machineid=@machineid and (((CoolentLevel-PrevCoolentLevel)/4095)*100) >= 10   and CNCTimeStamp>=@StartTime and CNCTimeStamp<=@EndTime)T1    
    
 update #Coolentlevelsummary set Consumption = ((T1.consumption/4095)*100), litres=((T1.consumption/4095)*@CoolentLevel) from    
 (Select isnull(sum((CoolentLevel-PrevCoolentLevel)),0) as Consumption from  Focas_CoolentLubOilInfo    
 where  machineid=@machineid and (((CoolentLevel-PrevCoolentLevel)/4095)*100) >= 10   and CNCTimeStamp>=@StartTime and CNCTimeStamp<=@EndTime)T1    

 
 select NoOfAlerts,NoOfRefills,Consumption,litres from #Coolentlevelsummary    
    
End    
    
if @Param = 'LubOilDetails'    
Begin   
 select [CNCTimeStamp] as [RefillTime],((PrevLubOilLevel/4095)*100) as [QtyBeforeRefill],((LubOilLevel/4095)*100) as [QtyAfterReFill],((([LubOilLevel]-[PrevLubOilLevel])/4095)*100) as Consumption,((([LubOilLevel]-[PrevLubOilLevel])/4095)*@LubOilLevel) as litres    
 from [dbo].[Focas_CoolentLubOilInfo] where @StartTime <= [CNCTimeStamp] and @EndTime >= [CNCTimeStamp] and LubOilLevelStatus = 1 and @MachineID=MachineID    
 order by [CNCTimeStamp]    
End     
    
if @param ='LubOilSummary'    
Begin    
 Create table #LubOilInfo    
  (    
  [NoOfAlerts] int,    
  [NoOfRefills] int,    
  consumption decimal(18,3),
  litres decimal(18,3)    
  )    
      
    
 Insert into #LubOilInfo([NoOfAlerts])    
 select Count(AlertType) from [dbo].[Focas_CoolentLubOilAlertsInfo]    
 where AlertType ='Lubricant' and  @StartTime <= [AlertTimestamp] and @EndTime >= [AlertTimestamp] and  @MachineID=MachineID    
    
 update #LubOilInfo set  [NoOfRefills]=T.[NoOfRefills] from    
 (select Count(LubOilLevelStatus) as [NoOfRefills]  from [dbo].[Focas_CoolentLubOilInfo]    
 where @MachineID=MachineID and  LubOilLevelStatus='1' and  @StartTime <= [CNCTimeStamp] and @EndTime >= [CNCTimeStamp])T     
    
 update #LubOilInfo set consumption= ((P.consumption/4095)*100),litres=((P.consumption/4095)*@LubOilLevel)  from    
 (select sum([LubOilLevel]-[PrevLubOilLevel]) as consumption from  [dbo].[Focas_CoolentLubOilInfo]    
 where @MachineID=MachineID and  LubOilLevelStatus='1' and  @StartTime <= [CNCTimeStamp] and @EndTime >= [CNCTimeStamp])P 
 
 
     
 select * from  #LubOilInfo    
End     
     
End    
