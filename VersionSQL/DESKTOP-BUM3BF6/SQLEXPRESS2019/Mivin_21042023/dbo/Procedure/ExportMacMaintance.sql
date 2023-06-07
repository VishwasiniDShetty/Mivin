/****** Object:  Procedure [dbo].[ExportMacMaintance]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[ExportMacMaintance] '','2018-06-01','2018-06-22','A',''
--[dbo].[ExportMacMaintance] 'HMC-06','2018-06-01','2018-06-22','A','Shanti'

CREATE PROCEDURE [dbo].[ExportMacMaintance]
		@Machine nvarchar(50)='',
		@Fromdate datetime='',
		@Todate datetime='',
		@Shift nvarchar(50)='',
		@Param nvarchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if ISNULL(@Param,'')=''
Begin
select ROW_NUMBER() OVER(ORDER BY date ) AS SLNo ,Date,Shift,PartNo,Activity,Frequency,[TimeStamp] as CreatedTS  ,Remarks
 ,Machine,SubSystem from dbo.MacMaintTransaction where  convert(nvarchar(10),[TimeStamp],120)>=convert(nvarchar(10),@Fromdate,120)  
and convert(nvarchar(10),[TimeStamp],120)<=convert(nvarchar(10),@Todate,120) and  (Machine=@Machine or @Machine= '')  
and  (Shift=@Shift or @Shift= '')  
END

if @Param='Shanti'
Begin

CREATE TABLE #shiftdetails (
	PDate datetime,
	Shift nvarchar(20),
	ShiftStart datetime,
	ShiftEnd datetime,
	Shiftid int
)

declare @Start as datetime
Select @Start=@Fromdate

while @Start<=@Todate
Begin
INSERT #ShiftDetails(Pdate, Shift, ShiftStart, ShiftEnd)  
EXEC s_GetShiftTime @Start,@Shift 
Select @Start=dateadd(day,1,@start)
End

select ROW_NUMBER() OVER(ORDER BY S.Pdate ) AS SLNo ,S.Pdate as Date,S.Shift,D.MachineID,D.Activity as ActivityID,DM.Activity,D.UpdatedTS as CreatedTS 
from dbo.dailyCheckListShanti_Transaction D 
inner join DailyCheckListShanti_Master DM on D.Activity=DM.SlNO
cross join #shiftdetails S
where  convert(nvarchar(20),D.UpdatedTS,120)>=convert(nvarchar(20),S.ShiftStart,120)  
and convert(nvarchar(20),D.UpdatedTS,120)<=convert(nvarchar(20),S.ShiftEnd,120) and (D.Machineid=@Machine or @Machine= '')  

ENd

END

Insert into DatabaseVersion (ScriptName, DBVersionnumber, SoftwareVersionNumber) values('6_5600', '5.6.0.0','5.6.0.0')
