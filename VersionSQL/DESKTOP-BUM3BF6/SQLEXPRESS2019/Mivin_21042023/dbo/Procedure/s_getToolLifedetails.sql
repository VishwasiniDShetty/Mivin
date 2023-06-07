/****** Object:  Procedure [dbo].[s_getToolLifedetails]    Committed by VersionSQL https://www.versionsql.com ******/

 --[dbo].[s_getToolLifedetails]'TURNING 01','2017-01-29 14:00:00','2017-04-29 18:00:00'
CREATE PROCEDURE [dbo].[s_getToolLifedetails]
@machineid as nvarchar(50)='',
@fromTime datetime='',
@ToTime datetime=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 create table #temp
 (
 id int,
 Machineid nvarchar(50),
 Componentid nvarchar(50),
 operationid nvarchar(50),
 ToolNo int,
 PrevToolNo int,
 ToolTarget int,
 ToolActual int,
 ToolLedValue int,
 ProgramNo nvarchar(50),
 CNCTimeStamp datetime,
 ToolLifeCount int,
 Flag int,
 AlarmTime datetime
 )

 SELECT *
INTO #Focas_ToolLife
FROM Focas_ToolLife  where CNCTimeStamp >= @FromTime and CNCTimeStamp <= @ToTime and
  Machineid= @machineid

-- insert into #temp(id,Machineid,Componentid,operationid,ToolNo,PrevToolNo,ToolTarget,ToolActual,ToolLedValue,ProgramNo,CNCTimeStamp)
--select  id, Machineid,Componentid,OperationID,ToolNo,lead(ToolNo) over (Partition by ToolNO order by ToolNO,cnctimestamp) as lead,
--ToolTarget,ToolActual,lead(ToolActual)over (Partition by ToolNO order by ToolNO,cnctimestamp) ToolLedValue,ProgramNo,
--CNCTimeStamp  from #Focas_ToolLife
--order by ToolNO,cnctimestamp

;With cte As
(SELECT id,Machineid,Componentid,OperationID,ToolNo,ToolTarget,ToolActual,ProgramNo,CNCTimeStamp,
         ROW_NUMBER() OVER (PARTITION BY ToolNO ORDER BY ToolNO,cnctimestamp) AS rn
  FROM #Focas_ToolLife)
insert into #temp(id,Machineid,Componentid,operationid,ToolNo,PrevToolNo,ToolTarget,ToolActual,ToolLedValue,ProgramNo,CNCTimeStamp)
SELECT c1.ID, c1.Machineid, c1.Componentid,c1.OperationID,c1.ToolNO,IsNull(c2.ToolNO, 0) As PrevToolNo,c1.ToolTarget,c1.ToolActual,c2.ToolActual as ToolLedValue,c1.ProgramNo,  
c1.CNCTimeStamp
  FROM cte c1
  LEFT OUTER JOIN cte c2 ON c1.ToolNO = c2.ToolNO And c2.rn = c1.rn + 1; 


update #temp set Flag = 1 where ToolLedValue < ToolActual and ToolNo=PrevToolNo

update #temp set ToolLifeCount = T.ToolCount from
(select count (Toolno) as ToolCount,ToolNo from #temp where Flag = 1 
group by ToolNo)T inner join #temp on #temp.ToolNo = T.ToolNo
where #temp.Flag = 1


select Machineid,ToolNo,ToolTarget,ToolActual,CNCTimeStamp,ToolLifeCount, AlarmTime  from #temp 
where Flag = 1 
order by ToolNO,cnctimestamp;


 



END
