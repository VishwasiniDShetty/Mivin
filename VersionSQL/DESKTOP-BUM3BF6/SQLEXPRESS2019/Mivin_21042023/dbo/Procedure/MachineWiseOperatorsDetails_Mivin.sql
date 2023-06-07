/****** Object:  Procedure [dbo].[MachineWiseOperatorsDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
exec [dbo].[MachineWiseOperatorsDetails_Mivin] '2103','2021-09-01 00:00:00','2021-09-30 00:00:00'
*/
CREATE PROCEDURE [dbo].[MachineWiseOperatorsDetails_Mivin]
@MachineID NVARCHAR(50)='',
@StartDate DATETIME='',
@EndDate DATETIME=''
AS
BEGIN

DECLARE @starttime DATETIME
DECLARE @endtime DATETIME

SELECT @starttime=@StartDate
SELECT @endtime=@EndDate

CREATE TABLE #shift 
(
	shiftDate DATETIME,
	Shift nvarchar(20),
	ShiftStart datetime,
	ShiftEnd datetime,
	NoOfOperators int
)

while @starttime<=@endtime
BEGIN
INSERT #shift(shiftDate,Shift, ShiftStart, ShiftEnd)
EXEC s_GetShiftTime @starttime
	
	SELECT @starttime=DATEADD(DAY,1,@starttime)
END

IF NOT EXISTS(SELECT * FROM dbo.ManPowerDetails_Mivin WHERE (Machineid=@MachineID OR ISNULL(@MachineID,'')='') AND (Pdate>=@StartDate AND Pdate<=@EndDate))
BEGIN
INSERT INTO ManPowerDetails_Mivin(MACHINEID,PDATE,SHIFT,NoOfOperators)
SELECT m1.machineid,shiftDate,s.shift,ISNULL(m.NoOfOperators,1) AS NoOfOperators   FROM #shift s
CROSS JOIN dbo.machineinformation m1 
LEFT OUTER JOIN dbo.ManPowerDetails_Mivin m ON m.Pdate= s.shiftDate AND m.Shift=s.Shift AND m.Machineid=m1.machineid
WHERE (m1.machineid=@MachineID OR ISNULL(@MachineID,'')='')
PRINT 'Inserted Successfully'
END


--DELETE FROM dbo.ManPowerDetails_Mivin WHERE Pdate IN
--(SELECT DISTINCT m.Pdate FROM dbo.ManPowerDetails_Mivin m INNER JOIN dbo.HolidayList h ON h.MachineID=m.Machineid AND h.Holiday=m.Pdate WHERE m.Machineid=@MachineID OR ISNULL(@MachineID,'')='')


SELECT DISTINCT m1.Machineid,m.description AS  description,Pdate AS shiftDate,Shift,NoOfOperators FROM dbo.ManPowerDetails_Mivin m1
INNER JOIN dbo.machineinformation m ON m.machineid=m1.Machineid
WHERE (m1.Machineid=@MachineID OR ISNULL(@MachineID,'')='') AND Pdate>=@StartDate AND Pdate<=@EndDate

END
