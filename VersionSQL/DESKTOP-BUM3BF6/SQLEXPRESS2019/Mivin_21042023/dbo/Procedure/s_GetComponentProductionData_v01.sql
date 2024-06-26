﻿/****** Object:  Procedure [dbo].[s_GetComponentProductionData_v01]    Committed by VersionSQL https://www.versionsql.com ******/

create   PROCEDURE s_GetComponentProductionData_v01
	@StartTime as DateTime,-- = '9 feb 2004 07:00:00' ,
	@EndTime as DateTime,-- = '25 feb 2004 07:00:00',
	@MachineID as nvarchar(50) = '',
	@ComponentID nvarchar(50) = '',
	@OperatorID nvarchar(50) = ''
AS
BEGIN
declare @strsql nvarchar(2000)
declare @strmachine nvarchar(255)
declare @stroperator nvarchar(255)
declare @strcomponent nvarchar(255)

CREATE TABLE #ProdData (
	ComponentID nvarchar(50) primary key,
	Production float,
	Rejection float,
	CN float,
	TurnOver float)
-- Load the Production, Rejection, CN and Turnover from Work Order Production Details
select @strsql = ''
select @strmachine = ''
select @strcomponent = ''
select @stroperator = ''
if isnull(@machineid,'') <> ''
	begin
	select @strmachine = ' AND ( workorderheader.machineid = ''' + @MachineID+ ''')'
	end
if isnull(@componentid, '') <> ''
	begin
	select @strcomponent = ' AND ( workorderheader.componentid = ''' + @ComponentID+ ''')'
	end
if isnull(@operatorid, '') <> ''
	begin
	select @stroperator = ' AND ( workorderproductiondetail.employeeid = ''' + @operatorid + ''')'
	end
select @strsql = 'INSERT INTO #ProdData (ComponentID, Production, Rejection, CN, TurnOver)'
select @strsql = @strsql + ' SELECT  workorderheader.ComponentID, SUM(workorderproductiondetail.production) AS Production, '
select @strsql = @strsql + ' ISNULL(SUM(workorderproductiondetail.rejection), 0) AS Rejection, '
select @strsql = @strsql + ' SUM(workorderheader.cycletime * workorderproductiondetail.production) AS CN, '
select @strsql = @strsql + ' SUM(workorderheader.price * (workorderproductiondetail.production - workorderproductiondetail.rejection)) AS TurnOver'
select @strsql = @strsql + ' FROM workorderheader INNER JOIN workorderproductiondetail ON workorderheader.workorderno = workorderproductiondetail.workorderno'
select @strsql = @strsql + ' WHERE (('
select @strsql = @strsql + ' (workorderproductiondetail.timefrom>=''' + convert(nvarchar(20),@StartTime) + ''') AND'

select @strsql = @strsql + ' (workorderproductiondetail.timeto<=''' + convert(nvarchar(20),@EndTime) + ''')'
select @strsql = @strsql + '  ) OR ( '
select @strsql = @strsql + ' (workorderproductiondetail.timefrom<''' + convert(nvarchar(20),@StartTime) + ''') AND'
select @strsql = @strsql + ' (workorderproductiondetail.timeto<=''' + convert(nvarchar(20),@EndTime) + ''') AND'
select @strsql = @strsql + ' (workorderproductiondetail.timeto>''' + convert(nvarchar(20),@StartTime) + ''')))'
select @strsql = @strsql + @strmachine + @stroperator + @strcomponent
select @strsql = @strsql + ' GROUP BY workorderheader.ComponentID'
exec (@strsql)
/*INSERT INTO #ProductionData (ComponentID, Production, Rejection, CN, TurnOver)
SELECT  workorderheader.ComponentID,
	SUM(workorderproductiondetail.production) AS Production,
	ISNULL(SUM(workorderproductiondetail.rejection), 0) AS Rejection,
	SUM(workorderheader.cycletime * workorderproductiondetail.production) AS CN,
	SUM(workorderheader.price * (workorderproductiondetail.production - workorderproductiondetail.rejection)) AS TurnOver
FROM         workorderheader
	     INNER JOIN workorderproductiondetail ON
			workorderheader.workorderno = workorderproductiondetail.workorderno
WHERE 	
	( workorderheader.machineid LIKE '%'+@MachineID+'%')
	AND
	( workorderheader.componentid LIKE '%'+@ComponentID+'%' )
	AND
	( workorderproductiondetail.employeeid LIKE '%'+@OperatorID+'%' )
	AND
	((
		(workorderproductiondetail.timefrom>=@StartTime)
		AND
		(workorderproductiondetail.timeto<=@EndTime)
	)
	OR 	
	(
		(workorderproductiondetail.timefrom<@StartTime)
		AND
		(workorderproductiondetail.timeto<= @EndTime)
		AND
		(workorderproductiondetail.timeto>@StartTime)
	))
GROUP BY workorderheader.ComponentID, workorderheader.workorderno
*/
-- Load the rejection count from the Work Order Rejection Details
--UPDATE #ProductionData
--SET Rejection = Rejection + isnull((
--	SELECT SUM(workorderrejectiondetail.Quantity)
--	FROM         workorderheader	
--	     INNER JOIN workorderrejectiondetail ON
--			workorderheader.workorderno = workorderrejectiondetail.workorderno
--	WHERE 	
--		( workorderheader.machineid LIKE '%'+@MachineID+'%')
--		AND
--		( workorderheader.componentid LIKE '%'+#ProductionData.ComponentID+'%' )
--		AND
--		( workorderrejectiondetail.employeeid LIKE '%'+@OperatorID+'%' )
--		AND
--		(workorderrejectiondetail.rejectiondate>=@StartTime)
--		AND
--		(workorderrejectiondetail.rejectiondate<=@EndTime)
--	GROUP BY workorderheader.ComponentID, workorderheader.workorderno
--	),0)
-- Return the totals for each component
insert #productiondata (componentid, production, rejection, CN, turnover)
SELECT
	ComponentID,
	Sum(Production) as Production,
	SUM(Rejection) as Rejection,
	SUM(CN) as CN,
	SUM(TurnOver) as TurnOver
FROM #ProdData
GROUP BY ComponentID
END
