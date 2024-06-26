﻿/****** Object:  Procedure [dbo].[s_GetDailyBreakDownReport]    Committed by VersionSQL https://www.versionsql.com ******/

/*******************************************************************************************************
--Created by Sangeeta Kallur 05/02/2005
--Updated by Sangeeta Kallur on 14-Feb-2005
--To show downtimes mc,comp,opn and down reason wise
--Updated by Mrudula on 22nd july 2006 to capture standard setup time n to calculate setupefficiency
Procedure altered by SSK On 07-Oct-2006 to include Plant Level Concept
Altered by mrudula to include or exclude down
DR0177:24/Mar/2009:KarthikG :: Size of the column 'DownDescription' in table '#TempBreakDownData' has been increased to 100 from 50
mod 1 :- ER0182 By Kusuma M.H on 08-May-2009. Modify all the procedures to support unicode characters. Qualify with leading N.
mod 2 :- ER0181 By Kusuma M.H on 08-May-2009.2) Modify all the procedures accordingly. Qualify machine wherever we are making use of component and opeartion no.
mod 3:-For DR0218 by Mrudula M.Rao on 08-oct-2009.MCO change is not done while selecting the records from autodata and inserting into temp table.
mod 4:-By Mrudula M. Rao on 01-feb-2010. For ER0210 Introduce PDT on 5150. 1) Handle PDT at Machine Level.
mod 5:- By Mrudula M. Rao on 15-Mar-2010. For ER0222 Consider all types of records (1,2,3,4) for the selected time period.
DR0308 - 13/Jun/2012 - SwathiKS -:: To handle Downtime of all Four types when PDT is not applied.
DR0321 - 20/Nov/2012 - SwathiKS/SnehaK :: To handle Query engine error 'Associated Statement not prepared' For Wipro.
-- { The multi-part identifier "P.PlantID" could not be bound. }
*******************************************************************************************************/
--s_GetDailyBreakDownReport '2012-Dec-20 12:00:00 PM','2012-Dec-21 12:00:00 PM','','''defect''','','0'
--s_GetDailyBreakDownReport '2012-Dec-20 12:00:00 AM','2012-Dec-20 12:00:00 AM','ace-05','','WIn chennai - lcc','0'
CREATE       PROCEDURE [dbo].[s_GetDailyBreakDownReport]
	@StartTime datetime,
	@EndTime datetime,
	@MachineID nvarchar(50)= '',
	@DownID varchar(8000)='',
	@PlantID Nvarchar(50)='',
	@Exclude int
AS
BEGIN
create table #TempBreakDownData
(
StartTime datetime,
EndTime datetime,
machineid nvarchar(50),
machineDescription nvarchar(150),
componentid nvarchar(50),
OperationNo integer,
OperatorName nvarchar(50),
downid nvarchar(50),
DownDescription nvarchar(100),		--DR0177:24/Mar/2009:KarthikG
downtime float,
McDowntime float,
remarks nvarchar(255),
id bigint primary key,
StdSetup float,
SetupEff float
)
--mod 5
Create table #PlannedDownTimes
(
	Machine nvarchar(50),
	--StartTime DateTime, --DR0321
	--EndTime DateTime --DR0321
	st datetime, --DR0321
	nd datetime --DR0321
)
--mod 5
---mod 1
--DECLARE @strsql varchar(8000)
--DECLARE @StrDownId VARCHAR(8000)
DECLARE @strsql nvarchar(4000)
DECLARE @StrDownId NVARCHAR(4000)
---mod 1
DECLARE @strmachine nvarchar(200)
DECLARE @StrPlantID NVARCHAR(200)
--mod 4
DECLARE @StrPLD_DownId NVARCHAR(500)
declare @StrPLD  nvarchar(3000)
--mod 4
SELECT  @strsql=''
SELECT @strmachine=''
SELECT @StrDownId=''
SELECT @StrPlantID=''
--mod 4
select @StrPLD_DownId=''
select @StrPLD = ''
---mod 4
if isnull(@PlantID,'')<>''
begin
	---mod 1
	--select @StrPlantID=' AND (PlantMachine.PlantID ='''+@PlantID+''')'
	select @StrPlantID=' AND (P.PlantID =N'''+@PlantID+''')'
	---mod 1
end
if isnull(@MachineID,'')<>''
begin
	---mod 1
	--select @strmachine=' AND (machineinformation.machineid ='''+@MachineID+''')'
	select @strmachine=' AND (M.machineid =N'''+@MachineID+''')'
	---mod 1
end
IF ISNULL(@DownID,'')<>'' and @Exclude=0
BEGIN
	--SELECT @StrDownId=' AND (D.Downid in ( '+@DownID+' ))' --DR0321
	  SELECT @StrDownId=' AND (D.Downid in (' + @DownID + '))' --DR0321
END
IF ISNULL(@DownID,'')<>'' and @Exclude=1
BEGIN
--	SELECT @StrDownId=' AND (D.Downid not in ( '+@DownID+' ))' --DR0321
	SELECT @StrDownId=' AND (D.Downid not in (' + @DownID + '))' --DR0321
END
---mod 4
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'N'
BEGIN
	If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'Y' AND (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'N'
	BEGIN
		SELECT @StrPLD_DownId=' AND D.DownID= (SELECT ValueInText From CockpitDefaults Where Parameter =''Ignore_Dtime_4m_PLD'')'
	END
	/* Planned Down times for the given time period at machine level*/
	 select @strsql=' Insert into #PlannedDownTimes
	(Machine,st,nd)
	SELECT Machine,
		CASE When starttime<'''+convert(nvarchar(20),@StartTime,120)+''' Then '''+convert(nvarchar(20),@StartTime,120)+'''  Else starttime End As starttime,
		CASE When endtime>'''+convert(nvarchar(20),@EndTime,120) + '''  Then ''' + convert(nvarchar(20),@EndTime,120) + '''  Else endtime End As endtime
		FROM PlannedDownTimes
	WHERE (
	(starttime >= '''+convert(nvarchar(20),@StartTime,120)+''' AND endtime<='''+convert(nvarchar(20),@EndTime,120)+''')
	OR (starttime < '''+convert(nvarchar(20),@StartTime,120)+''' AND endtime<='''+convert(nvarchar(20),@EndTime,120)+''' AND endtime >'''+convert(nvarchar(20),@StartTime,120)+''' )
	OR (starttime >= '''+convert(nvarchar(20),@StartTime,120)+''' AND starttime<'''+convert(nvarchar(20),@EndTime,120)+''' AND endtime >'''+convert(nvarchar(20),@EndTime,120)+''' )
	OR (starttime < '''+convert(nvarchar(20),@StartTime,120)+''' AND endtime>'''+convert(nvarchar(20),@EndTime,120)+''') ) and pdtstatus=1 '
	if isnull(@MachineID,'')<>''
	begin
		select @strsql=@strsql+' AND (PlannedDownTimes.machine =N'''+@MachineID+''') '
	ENd
	select @strsql=@strsql+' ORDER BY starttime'
	print @strsql
	exec (@strsql)
	select @strPld=' LEFT OUTER JOIN
	(
	SELECT T1.Sttime AS PLD_Sttime ,T1.Ndtime AS PLD_Ndtime,T1.MachineID AS PLD_MachineID,Sum(ISNULL(T1.PLD_LoadUnload,0))PLD_LoadUnload
	FROM
		(SELECT A.Sttime,A.Ndtime,M.MachineID,
		CASE
			WHEN (A.sttime>=T.st AND A.ndtime<=T.nd) THEN Loadunload
			WHEN (A.sttime<T.st AND A.ndtime<=T.nd AND A.ndtime>T.st)THEN DATEDIFF(ss,T.st,A.ndtime)
			WHEN (A.sttime>=T.st AND A.sttime<T.nd AND A.ndtime>T.nd) THEN DATEDIFF(ss,A.Sttime,T.nd )
			WHEN (A.sttime<T.st AND A.ndtime>T.nd) THEN DATEDIFF(ss,T.st,T.nd)
		End As PLD_LoadUnload
		From AutoData A INNER JOIN MachineInformation M  ON A.Mc=M.InterfaceID
		--Left Outer Join PlantMachine ON PlantMachine.machineid=M.machineid INNER JOIN --DR0321 Commented
		Left Outer Join PlantMachine P ON P.machineid=M.machineid INNER JOIN --DR0321 Added
		Downcodeinformation D ON A.dcode = D.interfaceid inner JOIN #PlannedDownTimes T on T.Machine=M.machineid
		Where A.Datatype=2 And ((A.sttime>='''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime<='''+convert(nvarchar(20),@EndTime,120)+''' )
		OR(A.sttime<'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime<='''+convert(nvarchar(20),@EndTime,120)+''')
		OR(A.sttime>='''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@EndTime,120)+''' AND A.sttime<'''+convert(nvarchar(20),@EndTime,120)+''')
		OR(A.sttime<'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@EndTime,120)+''' ))
		And (
		(A.sttime>=T.st AND A.ndtime<=T.nd)
		OR(A.sttime<T.st AND A.ndtime<=T.nd AND A.ndtime>T.st)
		OR(A.sttime>=T.st AND A.sttime<T.nd AND A.ndtime>T.nd)
		OR(A.sttime<T.st AND A.ndtime>T.nd))'
	select @strPld=@strPld + @StrPlantID + @strmachine + @StrDownId	+ @StrPLD_DownId
	select @strPld=@strPld + ')AS T1
	Group By T1.Sttime,T1.Ndtime,T1.MachineID'
	--) AS Td ON AutoData.Sttime=Td.PLD_Sttime AND AutoData.Ndtime=Td.PLD_Ndtime AND MachineInformation.MachineID=Td.PLD_MachineID '
	select @strPld=@strPld + ' )AS Td ON A.Sttime=Td.PLD_Sttime AND A.Ndtime=Td.PLD_Ndtime AND M.MachineID=Td.PLD_MachineID '
END
---mod 4
select @strsql='insert into  #TempBreakDownData(StartTime,endtime,machineid,machineDescription,componentid,OperationNo,OperatorName,downid,downdescription,downtime,Mcdowntime,remarks,id,StdSetup,SetupEff)
select
A.sttime,A.ndtime,
M.machineid,M.Description,
CI.componentid,
CO.operationno,E.employeeid,
D.downid,D.downdescription,'
---A.loadunload  ----DR0308 Swathi Commented
----DR0308 Added From Here----------------
select @strsql=@strsql + ' SUM(CASE
			WHEN (A.sttime>='''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime<='''+convert(nvarchar(20),@EndTime,120)+''') THEN A.Loadunload
			WHEN (A.sttime<'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime<='''+convert(nvarchar(20),@EndTime,120)+''') THEN DATEDIFF(ss,'''+convert(nvarchar(20),@StartTime,120)+''',A.ndtime)
			WHEN (A.sttime>='''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@EndTime,120)+''' AND A.sttime<'''+convert(nvarchar(20),@EndTime,120)+''') THEN DATEDIFF(ss,A.Sttime,'''+convert(nvarchar(20),@EndTime,120)+''')
			WHEN (A.sttime<'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@EndTime,120)+''') THEN DATEDIFF(ss,'''+convert(nvarchar(20),@StartTime,120)+''','''+convert(nvarchar(20),@EndTime,120)+''')
		End )'
----DR0308 Added Till Here----------------
---mod 4
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'N'
BEGIN
select @strsql=@strsql + '-ISNULL(Td.PLD_LoadUnload,0)'
END
---mod 4
select @strsql = @strsql + ' As downtime'
select @strsql=@strsql + ' ,0,A.Remarks,A.id,0,0
FROM autodata A INNER JOIN
machineinformation M ON A.mc = M.InterfaceID Left Outer Join
--PlantMachine ON PlantMachine.machineid=M.machineid INNER JOIN --DR0321 Commented
PlantMachine P ON P.machineid=M.machineid INNER JOIN --DR0321 Added
downcodeinformation D ON A.dcode = D.interfaceid INNER JOIN
employeeinformation E ON A.opr = E.interfaceid INNER JOIN
componentinformation CI ON A.COMP= CI.interfaceid INNER JOIN
componentoperationpricing CO ON A.opn  = CO.interfaceid and CO.componentid=CI.componentid'
---mod 3
select @strsql=@strsql +' and CO.Machineid=M.machineid'
---mod 3
---mod 4: Neglect planned down times
select @strsql=@strsql + @strPld
---mod 4
select @strsql=@strsql +' WHERE (A.datatype = 2)'
--mod 5:Consider all 4 types
--select @strsql=@strsql +'AND (A.sttime >= ''' + convert(nvarchar(20),@StartTime) + ''')'
--select @strsql=@strsql +'AND (A.ndtime <= ''' + convert(nvarchar(20),@EndTime) + ''')'
SELECT @StrSql =@StrSql +'AND ((A.sttime>='''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime<='''+convert(nvarchar(20),@EndTime,120)+''')
		OR(A.sttime<'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime<='''+convert(nvarchar(20),@EndTime,120)+''')
		OR(A.sttime>='''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@EndTime,120)+''' AND A.sttime<'''+convert(nvarchar(20),@EndTime,120)+''')
		OR(A.sttime<'''+convert(nvarchar(20),@StartTime,120)+''' AND A.ndtime>'''+convert(nvarchar(20),@EndTime,120)+'''))'
---mod 5
select @strsql=@strsql + @StrPlantID + @strmachine + @StrDownId
----DR0308 Added From Here----------------
select @strsql=@strsql +'group by A.sttime,A.ndtime,
M.machineid,M.description,CI.componentid,
CO.operationno,E.employeeid,
D.downid,D.downdescription,A.Remarks,A.id'
If (SELECT ValueInText From CockpitDefaults Where Parameter ='Ignore_Dtime_4m_PLD')<>'N'
BEGIN
select @strsql=@strsql + ' ,Td.PLD_LoadUnload'
END
----DR0308 Added Till Here----------------
--select @strsql=@strsql +'ORDER BY A.ndtime' ------DR0308 Commented
exec(@strsql)
print @strsql
--RETURN
---mod 5: delete records with downtime=0
delete from #TempBreakDownData where  downtime<=0
--mod 5
--updated by mrudula to capture std setup time from CO table
update #TempBreakDownData set StdSetup=ISNULL(T2.SETUp,0) From
---mod 2
--(SELECT C.componentID AS componentID,O.OperationNo AS OperationNo,O.StdSetupTime AS SETUp
-- FROM ComponentInformation C Inner Join  Componentoperationpricing O ON C.ComponentID=O.ComponentID
--)AS T2 Inner Join #TempBreakDownData on #TempBreakDownData.ComponentID=T2.ComponentID AND
-- #TempBreakDownData.OperationNo=T2.OperationNo
--WHERE #TempBreakDownData.Downid='SETUP'
(SELECT C.componentID AS componentID,O.OperationNo AS OperationNo,O.StdSetupTime AS SETUp,M.machineid
FROM ComponentInformation C Inner Join Componentoperationpricing O ON C.ComponentID=O.ComponentID
inner join machineinformation M on M.machineid = O.machineid
)AS T2 Inner Join #TempBreakDownData on #TempBreakDownData.ComponentID=T2.ComponentID
AND #TempBreakDownData.OperationNo=T2.OperationNo and #TempBreakDownData.machineid = T2.machineid
WHERE #TempBreakDownData.Downid='SETUP'
---mod 2
--Query to calculate Seup Efficiency
Update #TempBreakDownData set SetupEff=isnull((StdSetup/isnull(downtime,0)),0)*100  where Downid='SETUP' and downtime<>0
--Get the total down time by machine
update #TempBreakDownData set McDowntime = isnull(Mcdowntime,0) + isnull(t2.down,0)
from (select Machineid, sum(downtime) down
from #tempBreakdowndata group by Machineid)as t2 inner join #tempbreakdowndata on t2.machineid = #tempbreakdowndata.Machineid
--Format the downtime as per user preferences
declare @TimeFormat as nvarchar(25)
SELECT @TimeFormat = ''
SELECT @TimeFormat = (SELECT  ValueInText  FROM CockpitDefaults WHERE Parameter = 'TimeFormat')
if (ISNULL(@TimeFormat,'')) = ''
	SELECT @TimeFormat = 'ss'
SELECT @strsql = 'SELECT StartTime,EndTime,machineID,machineDescription,componentid,OperationNo,OperatorName,DownID,DownDescription,remarks,downtime as DownNumeric,Remarks,'
if (@TimeFormat = 'hh:mm:ss'or @TimeFormat = 'hh' or @TimeFormat = 'mm' or @TimeFormat = 'ss' )
begin	
	SELECT @strsql =  @strsql  +'dbo.f_FormatTime(DownTime,''' + @TimeFormat + ''') as DownTime , '
	SELECT @strsql =  @strsql  +'dbo.f_FormatTime(McDownTime,''' + @TimeFormat + ''') as McDownTime , '
	SELECT @strsql =  @strsql  +'dbo.f_FormatTime(StdSetup,''' + @TimeFormat + ''') as StdSetup , '
	end
SELECT @strsql =  @strsql  + 'SetupEff From #TempBreakDownData order by EndTime'
--print @strsql
EXEC (@strsql)
END
