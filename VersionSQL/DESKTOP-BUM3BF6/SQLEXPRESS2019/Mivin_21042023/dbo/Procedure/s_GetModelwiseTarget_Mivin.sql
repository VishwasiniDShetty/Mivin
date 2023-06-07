/****** Object:  Procedure [dbo].[s_GetModelwiseTarget_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

---[dbo].[s_GetModelwiseTarget_Mivin] '','2020-03-10 16:00:00.000','2020-03-15 16:00:00.000'
CREATE PROCEDURE [dbo].[s_GetModelwiseTarget_Mivin] 
	@StationID nvarchar(50),
	@StartDate datetime,
	@Enddate datetime
AS  
BEGIN  

CREATE TABLE #ShiftDetails
( 
	dDate datetime ,
	Shift nvarchar(50),
	Starttime datetime ,
	Endtime datetime,
	Shiftid int 
)  

create table #Target
(
Date datetime,
Shift nvarchar(50),
ShiftTarget int,
TotalShiftTarget int,
NoOfPersons int
)

while @StartDate<=@Enddate
Begin
	INSERT INTO #ShiftDetails(dDate,Shift,Starttime,Endtime)
	EXEC s_GetShiftTime @StartDate
	select @StartDate=DATEADD(day,1,@Startdate)
END

--insert into #Target(PumpModel,Date,Shift,shifttarget,TotalShiftTarget)
--select distinct S.PumpModel,SH.dDate,SH.shift,0,0 from ScheduleDetails S
--cross join #ShiftDetails SH 
--where convert(nvarchar(10),S.Date,120)=convert(nvarchar(10),@StartDate,120)

--update #Target set  shifttarget=T.shifttarget from
--(Select p.pumpmodeL,P.Date,P.Shift,sum(P.Target) AS shifttarget from PumpwiseTargetMaster p
--INNER JOIN #Target s ON CONVERT(NVARCHAR(10),p.DATE,120)=CONVERT(NVARCHAR(10),s.DATE,120) AND p.Shift=s.Shift and p.PumpModel=s.PumpModel
--group by p.pumpmodeL,P.Date,P.Shift)T inner join #Target on T.PumpModel=#Target.PumpModel and CONVERT(NVARCHAR(10),T.DATE,120)=CONVERT(NVARCHAR(10),#Target.DATE,120) AND T.Shift=#Target.Shift

--update #Target set  TotalShiftTarget=T.TotalShiftTarget from
--(Select P.Date,P.Shift,sum(P.shifttarget) AS TotalShiftTarget from 
--#Target P where convert(nvarchar(10),Date,120)=convert(nvarchar(10),@StartDate,120)
--group by P.Date,P.Shift)T inner join #Target on  CONVERT(NVARCHAR(10),T.DATE,120)=CONVERT(NVARCHAR(10),#Target.DATE,120) AND T.Shift=#Target.Shift

--Declare @SelectColumnName nvarchar(max)
--Declare @DynamicPivotQuery1 nvarchar(max)

--SELECT @SelectColumnName= ISNULL(@SelectColumnName + ',','') 
--+ QUOTENAME(PumpModel)
--FROM (select distinct PumpModel from #Target) AS BatchValues 

--select @DynamicPivotQuery1=''
--SET @DynamicPivotQuery1 = 
--N'
--SELECT Date,Shift,' + @SelectColumnName + ' ,TotalShiftTarget 
--FROM (select PumpModel,Date,Shift,shifttarget,TotalShiftTarget
--from #Target
--)as s 
--PIVOT (SUM(shifttarget)
--FOR [PumpModel] IN (' + @SelectColumnName + ')) AS PVTTable2
--order by Date,Shift'

--EXEC sp_executesql @DynamicPivotQuery1


insert into #Target(Date,Shift,shifttarget,TotalShiftTarget,NoOfPersons)
select distinct SH.dDate,SH.shift,0,0,0 from #ShiftDetails SH 


update #Target set  TotalShiftTarget=T.Target,NoOfPersons=T.NoOfManpower from
(Select P.Date,P.Shift,P.Target,P.NoOfManpower from ShiftwiseTargetMaster p
INNER JOIN #Target s ON CONVERT(NVARCHAR(10),p.DATE,120)=CONVERT(NVARCHAR(10),s.DATE,120) AND p.Shift=s.Shift 
where p.StationID=@StationID
)T inner join #Target on CONVERT(NVARCHAR(10),T.DATE,120)=CONVERT(NVARCHAR(10),#Target.DATE,120) AND T.Shift=#Target.Shift

update #target set ShiftTarget=TotalShiftTarget/NoOfPersons where NoOfPersons>0

Declare @SelectColumnName nvarchar(max)
Declare @DynamicPivotQuery1 nvarchar(max)

SELECT @SelectColumnName= ISNULL(@SelectColumnName + ',','') 
+ QUOTENAME(Shift)
FROM (select distinct Shift from #ShiftDetails) AS BatchValues 

select @DynamicPivotQuery1=''
SET @DynamicPivotQuery1 = 
N'
SELECT Date,' + @SelectColumnName + ' ,NoOfPersons,TotalShiftTarget 
FROM (select Date,Shift,shifttarget,TotalShiftTarget,NoOfPersons
from #Target
)as s 
PIVOT (SUM(ShiftTarget)
FOR [Shift] IN (' + @SelectColumnName + ')) AS PVTTable2
order by Date'

EXEC sp_executesql @DynamicPivotQuery1

END
