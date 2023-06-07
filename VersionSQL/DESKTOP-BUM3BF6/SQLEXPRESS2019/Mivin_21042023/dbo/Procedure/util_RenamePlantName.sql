/****** Object:  Procedure [dbo].[util_RenamePlantName]    Committed by VersionSQL https://www.versionsql.com ******/

-- ===================================================================================================
-- Description:	To update the Plant
-- util_RenamePlantName  @PlantIDOld = 'CNC SHOP1', @PlantIDNew = 'CNC SHOPNew'
--- Vasavi - 15/Sep/2017 To rename the Plant
-- =======================================================================================================
create PROCEDURE [dbo].[util_RenamePlantName]
	@PlantIDOld  nvarchar(200),
	@PlantIDNew  nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
DECLARE @update_count int
DECLARE @ErrorCode  int  
DECLARE @ErrorStep  varchar(200)
DECLARE @Return_Message VARCHAR(4000) 
SET @ErrorCode = @@ERROR
SET @Return_Message = ''

	IF (@PlantIDOld = '' or @PlantIDNew = '') print 'ERROR - Plant id not provided' 
	if(select count(*) from Plantinformation where Plantid = @PlantIDOld) = 0 
	Begin
	print 'ERROR - Plant id to be change does not exists' 
	return -1;
	End
	if(select count(*) from Plantinformation where Plantid = @PlantIDNew) > 0 
	Begin
	print 'ERROR - New Plant id already exists' 
	return -1;
	End

BEGIN TRY
	BEGIN TRAN
	
	SET @ErrorStep = 'Error in updating  [AndonTarget]';
	update [dbo].AndonTarget set Plant=@PlantIDNew where Plant= @PlantIDOld
	SET @update_count = @@ROWCOUNT
	print 'Updated ' + CONVERT(varchar, @update_count) + ' records in table AndonTarget'

	--remove constraint for plant	
	SET @ErrorStep = 'Error in updating  [PlantEmployee]';	
	ALTER TABLE PlantEmployee NOCHECK CONSTRAINT FK_PlantEmployee_PlantInformation
	SET @ErrorStep = 'Error in updating [PlantMachine]';
	ALTER TABLE PlantMachine NOCHECK CONSTRAINT FK_PlantMachine_PlantInformation1

	--------------------

	SET @ErrorStep = 'Error in updating  [PlantEmployee]';
	update [dbo].[PlantEmployee] set PlantID=@PlantIDNew where PlantID  = @PlantIDOld
	SET @update_count = @@ROWCOUNT
	print 'Updated ' + CONVERT(varchar, @update_count) + ' records in table PlantEmployee'

	SET @ErrorStep = 'Error in updating  [PlantMachine]';
	update [dbo].PlantMachine set PlantID=@PlantIDNew where PlantID  = @PlantIDOld
	SET @update_count = @@ROWCOUNT
	print 'Updated ' + CONVERT(varchar, @update_count) + ' records in table PlantMachine'


	SET @ErrorStep = 'Error in updating  [PlantInformation]';
	update [dbo].[PlantInformation] set PlantID=@PlantIDNew where PlantID  = @PlantIDOld
	SET @update_count = @@ROWCOUNT
	print 'Updated ' + CONVERT(varchar, @update_count) + ' records in table PlantInformation'

	---------------

	--add constraint for plant
	ALTER TABLE PlantEmployee WITH CHECK CHECK CONSTRAINT FK_PlantEmployee_PlantInformation
	ALTER TABLE PlantMachine  WITH CHECK CHECK CONSTRAINT FK_PlantMachine_PlantInformation1


	SET @ErrorStep = 'Error in updating  [PlantMachineGroups]';
	update [dbo].[PlantMachineGroups] set PlantID=@PlantIDNew where PlantID  = @PlantIDOld
	SET @update_count = @@ROWCOUNT
	print 'Updated ' + CONVERT(varchar, @update_count) + ' records in table PlantMachineGroups'

	SET @ErrorStep = 'Error in updating  [ShiftProductionDetails]';
	update [dbo].[ShiftProductionDetails] set PlantID=@PlantIDNew where PlantID  = @PlantIDOld
	SET @update_count = @@ROWCOUNT
	print 'Updated ' + CONVERT(varchar, @update_count) + ' records in table ShiftProductionDetails'

	SET @ErrorStep = 'Error in updating  [ShiftDownTimeDetails]';
	update [dbo].[ShiftDownTimeDetails] set PlantID=@PlantIDNew where PlantID  = @PlantIDOld
	SET @update_count = @@ROWCOUNT
	print 'Updated ' + CONVERT(varchar, @update_count) + ' records in table ShiftDownTimeDetails'


	COMMIT TRAN
    SET  @ErrorCode  = 0
	Print 'Plant name changed for plant = '  + @PlantIDOld
    RETURN @ErrorCode  

END TRY
BEGIN CATCH    
	PRINT 'Exception happened. Rolling back the transaction'  
    SET @ErrorCode = ERROR_NUMBER() 
	SET @Return_Message = @ErrorStep + ' '
							+ cast(isnull(ERROR_NUMBER(),-1) as varchar(20)) + ' line: '
							+ cast(isnull(ERROR_LINE(),-1) as varchar(20)) + ' ' 
							+ isnull(ERROR_MESSAGE(),'') + ' > ' 
							+ isnull(ERROR_PROCEDURE(),'')
	PRINT @Return_Message
	IF @@TRANCOUNT > 0 ROLLBACK
    RETURN @ErrorCode 
END CATCH
END
