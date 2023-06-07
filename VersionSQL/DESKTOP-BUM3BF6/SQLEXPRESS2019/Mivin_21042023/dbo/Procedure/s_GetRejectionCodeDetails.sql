/****** Object:  Procedure [dbo].[s_GetRejectionCodeDetails]    Committed by VersionSQL https://www.versionsql.com ******/

--ER0391 - SwathiKS - 12/Sep/2014 :: Created New procedure to show Rejection Details from AutodataRejections table.
--Launch will be under Std -> Production and Downtime Report-Daily By Hour -> Format - Daily Rejection Report-Excel
---ER0504 - SwathiKS - 23/mar/2021 :: Included RejectionType for Precision Eng.
--[dbo].[s_GetRejectionCodeDetails] '2014-09-05','2014-09-06','','','',''


CREATE  PROCEDURE [dbo].[s_GetRejectionCodeDetails]
	@StartTime DATETIME,
	@EndTime DATETIME,
	@PlantID AS NVARCHAR(50)='',
	@machineID AS NVARCHAR(50)='',
	@ComponentID AS NVARCHAR(100)='',
	@param NVARCHAR(50)=''
	
AS
BEGIN
Declare @strMachine as nvarchar(255)
Declare @strComponent as nvarchar(100)
Declare @strPlantID as nvarchar(255)
Declare @strSql as nvarchar(4000)
Declare @curdate as datetime

SELECT @strMachine = ''
SELECT @strPlantID = ''
SELECT @strSql= ''
select @strComponent=''

if isnull(@PlantID,'')<> ''
Begin	
	SET @strPlantID = 'and P.PlantID = N''' + @PlantID + ''''	
End

if isnull(@machineID,'')<> ''
Begin	
	SET @strMachine = 'and M.MachineID = N''' + @machineid + ''''	
End

if isnull(@ComponentID,'')<> ''
Begin	
	SET @strComponent = 'and C.Componentid = N''' + @ComponentID + ''''	
End

CREATE TABLE #Rejections
(
	[Date] [datetime],
	[Shift] [nvarchar](50),
	[Machineid] [nvarchar](50),
	[Componentid] [nvarchar](100),
	[Operationno] [nvarchar](50),
	[Employeeid] [nvarchar](50),
	[Rejection Catagory][nvarchar](50) ,
	[Rejection Code] [nvarchar](50),
	[RejectionQty] int,
	[PDT] int,
	[RejectionType] [nvarchar](50) --ER0504
)

CREATE TABLE #ShiftDefn
(
	ShiftDate datetime,		
	Shiftname nvarchar(20),
	ShftSTtime datetime,
	ShftEndTime datetime	
)

declare @startdate as datetime
declare @enddate as datetime
declare @startdatetime nvarchar(20)

select @starttime = convert(nvarchar(10),@starttime,110) + ' ' + CAST(datePart(hh,FromTime) AS nvarchar(2)) + ':' + CAST(datePart(mi,FromTime) as nvarchar(2))+ ':' +CAST(cast(datePart(ss,FromTime)as int)+1 as nvarchar(2))
from shiftdetails where running = 1 and shiftid=(select top 1 shiftid from shiftdetails where running = 1 order by shiftid asc)

select @endtime = convert(nvarchar(10),@endtime,110) + ' ' + CAST(datePart(hh,ToTime) AS nvarchar(2)) + ':' + CAST(datePart(mi,ToTime) as nvarchar(2))+ ':' + CAST(datePart(ss,ToTime) as nvarchar(2))
from shiftdetails where running = 1 and shiftid=(select top 1 shiftid from shiftdetails where running = 1 order by shiftid desc)

print '@starttime @endtime'
print @starttime
print @endtime

select @startdate = dbo.f_GetLogicalDaystart(@StartTime)
select @enddate = dbo.f_GetLogicalDayend(@endtime)

print '@startdate @enddate'
print @startdate
print @enddate

while @startdate<=@enddate
Begin

	select @startdatetime = CAST(datePart(yyyy,@startdate) AS nvarchar(4)) + '-' + 
     CAST(datePart(mm,@startdate) AS nvarchar(2)) + '-' + 
     CAST(datePart(dd,@startdate) AS nvarchar(2))

	INSERT INTO #ShiftDefn(ShiftDate,Shiftname,ShftSTtime,ShftEndTime)
	select @startdate,ShiftName,
	Dateadd(DAY,FromDay,(convert(datetime, @startdatetime + ' ' + CAST(datePart(hh,FromTime) AS nvarchar(2)) + ':' + CAST(datePart(mi,FromTime) as nvarchar(2))+ ':' + CAST(datePart(ss,FromTime) as nvarchar(2))))) as StartTime,
	DateAdd(Day,ToDay,(convert(datetime, @startdatetime + ' ' + CAST(datePart(hh,ToTime) AS nvarchar(2)) + ':' + CAST(datePart(mi,ToTime) as nvarchar(2))+ ':' + CAST(datePart(ss,ToTime) as nvarchar(2))))) as EndTime
	from shiftdetails where running = 1 order by shiftid
	SELECT @startdate = DATEADD(d,1,@startdate)
END

create table #shift
(
	ShiftDate nvarchar(10), 
	shiftname nvarchar(20),
	Shiftstart datetime,
	Shiftend datetime,
	shiftid int
)

Insert into #shift (ShiftDate,shiftname,Shiftstart,Shiftend)
select convert(nvarchar(10),ShiftDate,126),shiftname,ShftSTtime,ShftEndTime from #ShiftDefn --where ShftSTtime>=@StartTime and ShftEndTime<=@endtime 

Update #shift Set shiftid = isnull(#shift.Shiftid,0) + isnull(T1.shiftid,0) from
(Select SD.shiftid ,SD.shiftname from shiftdetails SD
inner join #shift S on SD.shiftname=S.shiftname where
running=1 )T1 inner join #shift on  T1.shiftname=#shift.shiftname



Select @strsql = ''
Select @strsql = @strsql + 'Insert into #Rejections
Select A.RejDate as Date, A.RejShift as Shift, M.machineid as Machineid, C.Componentid as Componentid, O.Operationno as Operationno, E.Employeeid as Employeeid, 
R.Catagory as [Rejection Catagory],R.rejectionid as [Rejection Code], SUM(A.Rejection_Qty) as [RejectionQty],0,A.RejectionType
FROM AutodataRejections A 
inner join Rejectioncodeinformation R on A.Rejection_Code=R.interfaceid
inner join Machineinformation M on A.mc=M.interfaceid
inner join Componentinformation C on A.comp=C.interfaceid
inner join Componentoperationpricing O on A.opn=O.interfaceid and C.Componentid=O.Componentid and O.Machineid=M.machineid
inner join Employeeinformation E on a.opr=E.interfaceid
Left Outer join Plantmachine P on M.machineid=P.machineid
inner join #shift S on '''' + convert(nvarchar(10),(A.RejDate),126) + '''' =S.shiftdate and A.RejShift=S.shiftid 
where A.Rejshift in (S.shiftid) and convert(nvarchar(10),(A.RejDate),126) in (S.shiftdate) and A.flag = ''Rejection''
and Isnull(A.Rejshift,''a'')<>''a'' and Isnull(A.RejDate,''1900-01-01 00:00:00.000'')<>''1900-01-01 00:00:00.000'' '
Select @strsql = @strsql + @strPlantID + @strMachine + @strComponent
Select @strsql = @strsql + ' Group by A.RejDate,A.RejShift,M.machineid,C.Componentid,O.Operationno,E.Employeeid,R.Catagory,R.rejectionid,A.RejectionType'
print @strsql
Exec(@strsql)


Select @strsql = ''
Select @strsql = @strsql + 'Insert into #Rejections
Select #shift.ShiftDate as Date, #shift.shiftid as Shift, M.machineid as Machineid, C.Componentid as Componentid, O.Operationno as Operationno,
 E.Employeeid as Employeeid, R.Catagory as [Rejection Catagory],R.rejectionid as [Rejection Code], SUM(AutodataRejections.Rejection_Qty) as [RejectionQty],0,AutodataRejections.RejectionType
FROM AutodataRejections cross join #shift 
inner join Rejectioncodeinformation R on AutodataRejections.Rejection_Code=R.interfaceid
inner join Machineinformation M on AutodataRejections.mc=M.interfaceid
inner join Componentinformation C on AutodataRejections.comp=C.interfaceid
inner join Componentoperationpricing O on AutodataRejections.opn=O.interfaceid and C.Componentid=O.Componentid and O.Machineid=M.machineid
inner join Employeeinformation E on AutodataRejections.opr=E.interfaceid
Left Outer join Plantmachine P on M.machineid=P.machineid
where AutodataRejections.CreatedTS>=#shift.Shiftstart and AutodataRejections.CreatedTS<=#shift.Shiftend and AutodataRejections.flag = ''Rejection''
and Isnull(AutodataRejections.Rejshift,''a'')=''a'' and Isnull(AutodataRejections.RejDate,''1900-01-01 00:00:00.000'')=''1900-01-01 00:00:00.000'' '
Select @strsql = @strsql + @strPlantID + @strMachine  + @strComponent
Select @strsql = @strsql + ' Group by #shift.ShiftDate, #shift.shiftid,M.machineid,C.Componentid,O.Operationno, E.Employeeid, R.Catagory,R.rejectionid,AutodataRejections.RejectionType'
PRINT @strsql
EXEC(@strsql)

---ER0504 
SELECT @strsql = ''
SELECT @strsql = @strsql + 'Insert into #Rejections
Select A.RejDate as Date, A.RejShift as Shift, M.machineid as Machineid, C.Componentid as Componentid, O.Operationno as Operationno, E.Employeeid as Employeeid, 
R.Catagory as [Rejection Catagory],R.rejectionid as [Rejection Code], SUM(A.Rejection_Qty) as [RejectionQty],0,A.RejectionType
FROM AutodataRejectionsBeforeMachining A 
inner join Rejectioncodeinformation R on A.Rejection_Code=R.interfaceid
inner join Machineinformation M on A.mc=M.interfaceid
inner join Componentinformation C on A.comp=C.interfaceid
inner join Componentoperationpricing O on A.opn=O.interfaceid and C.Componentid=O.Componentid and O.Machineid=M.machineid
inner join Employeeinformation E on a.opr=E.interfaceid
Left Outer join Plantmachine P on M.machineid=P.machineid
inner join #shift S on '''' + convert(nvarchar(10),(A.RejDate),126) + '''' =S.shiftdate and A.RejShift=S.shiftid 
where A.Rejshift in (S.shiftid) and convert(nvarchar(10),(A.RejDate),126) in (S.shiftdate) and A.flag = ''Rejection''
and Isnull(A.Rejshift,''a'')<>''a'' and Isnull(A.RejDate,''1900-01-01 00:00:00.000'')<>''1900-01-01 00:00:00.000'' '
SELECT @strsql = @strsql + @strPlantID + @strMachine + @strComponent
SELECT @strsql = @strsql + ' Group by A.RejDate,A.RejShift,M.machineid,C.Componentid,O.Operationno,E.Employeeid,R.Catagory,R.rejectionid,A.RejectionType'
PRINT @strsql
EXEC(@strsql)
--ER0504

IF (SELECT ValueInText FROM CockpitDefaults WHERE Parameter ='Ignore_Count_4m_PLD')='Y'
BEGIN

	UPDATE #Rejections SET [RejectionQty] = ISNULL([RejectionQty],0) - ISNULL(T1.RejQty,0),[PDT] = ISNULL([PDT],0)+ ISNULL(T1.RejQty,0) FROM
	(
	SELECT date,shift,machineid,componentid,operationno,Employeeid,[Rejection Catagory],[Rejection Code],ISNULL(SUM([RejectionQty]),0) AS RejQty
	FROM #Rejections INNER JOIN #shift S ON #Rejections.Date=S.shiftdate AND #Rejections.shift=S.shiftid
	CROSS JOIN Planneddowntimes P
	WHERE P.PDTStatus =1 AND P.machine=#Rejections.Machineid AND 
	P.starttime>=S.Shiftstart AND P.Endtime<=S.shiftend
	GROUP BY date,shift,machineid,componentid,operationno,Employeeid,[Rejection Catagory],[Rejection Code]
	)T1 
	INNER JOIN #Rejections ON #Rejections.Date=T1.Date AND #Rejections.Shift=T1.shift 
	AND #Rejections.machineid=T1.machineid AND #Rejections.componentid=T1.componentid
	AND #Rejections.operationno=T1.operationno AND #Rejections.Employeeid=T1.Employeeid AND #Rejections.[Rejection Catagory]=T1.[Rejection Catagory] AND #Rejections.[Rejection Code]=T1.[Rejection Code]
END

SELECT Date,Shift,Machineid,Componentid,Operationno,Employeeid,[Rejection Catagory],[Rejection Code],[RejectionQty] AS [Rejection Qty],
[PDT] AS [Rejection during PDT],RejectionType FROM  #Rejections ORDER BY Date,Shift,Machineid --ER0504


END
