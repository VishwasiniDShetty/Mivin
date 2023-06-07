/****** Object:  Procedure [dbo].[s_PushShiftAggregation]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Procedure Created by Sangeeta Kallur on 21-Apr-2006
To Get the rejections for a shift
--changed To Support SubOperations at CO Level{AutoAxel Request}.
*/

CREATE         PROCEDURE s_PushShiftAggregation
	@Date as DateTime,
	@Shift as Nvarchar(20),
	@MachineID as NvarChar(50)
	
AS
BEGIN
	
	CREATE TABLE #ShiftDetails (
	PDate datetime,
	Shift nvarchar(20),
	ShiftStart datetime,
	ShiftEnd datetime
	)

declare @StartTime as datetime
declare @EndTime as datetime

--Get Shift Start and Shift End
INSERT #ShiftDetails(Pdate, Shift, ShiftStart, ShiftEnd)
EXEC s_GetShiftTime @Date,@Shift

--Introduced TOP 1 to take care of input 'ALL' shifts
select @StartTime = (select TOP 1 shiftstart from #ShiftDetails ORDER BY shiftstart ASC)
select @EndTime = (select TOP 1 shiftend from #ShiftDetails ORDER BY shiftend DESC)


	-- Delete from ShiftProductionDetails Where MachineID=@MachineID AND DATE=@Date AND SHIFT=@Shift
	 Insert into ShiftProductionDetails (MachineID,Date,Shift,ComponentID,OperationNo,Prod_Qty)
	
	 SELECT machineinformation.machineid,@Date,@Shift, componentinformation.componentid, 
	 componentoperationpricing.operationno, 
	 CAST(CEILING(CAST(Count(autodata.opn)as float)/ ISNULL(componentoperationpricing.SubOperations,1))as integer ) as opn
	 FROM autodata INNER JOIN  machineinformation ON autodata.mc = machineinformation.InterfaceID INNER JOIN  
	 componentinformation ON autodata.comp = componentinformation.InterfaceID  INNER JOIN 
	 componentoperationpricing ON (autodata.opn = componentoperationpricing.InterfaceID)
	 AND (componentinformation.componentid = componentoperationpricing.componentid) 
	 WHERE (autodata.ndtime > @StartTime)
	 AND (autodata.ndtime <=@EndTime )
	 AND (autodata.datatype = 1)
	 AND machineinformation.machineid=@MachineID
	 GROUP BY machineinformation.machineid,componentinformation.componentid, componentoperationpricing.operationno, 
	 componentoperationpricing.cycletime, componentoperationpricing.machiningtime , componentoperationpricing.SubOperations
		
	 Select DISTINCT *  from ShiftProductionDetails 
	 where  MachineID=@MachineID AND DATE=@Date AND SHIFT=@Shift
        
	
END
