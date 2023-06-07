/****** Object:  Procedure [dbo].[S_Get_SLNoValidation_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
exec S_Get_SLNoValidation_Mivin '2042','R983081339','180358357'
exec S_Get_SLNoValidation_Mivin '2042','R983042897','180356305'
*/
CREATE procedure [dbo].[S_Get_SLNoValidation_Mivin]
@MachineID nvarchar(50)='',
@PumpModel nvarchar(50)='',
@SlNo nvarchar(50)=''
as
begin
DECLARE @SLNumber nvarchar(50)
declare @ReworkNo nvarchar(50)
select @ReworkNo=(select isnull(max(reworkno),0) from PumpTestData_Mivin where MachineID=@MachineID and PumpModel=@PumpModel and SlNo=@SlNo)
if isnull(@ReworkNo,0)>0
begin
	select @SLNumber=@SlNo+'_'+@ReworkNo
end
else
begin
	select @SLNumber=@SlNo
end

if exists(select * from AutodataRejections where mc=@MachineID and comp=@PumpModel and WorkOrderNumber=@SLNumber and Flag='Rejection')
begin
	select '4' AS Status --Rejected
end
else if exists(select * from PumpTestData_Mivin where MachineID=@MachineID and PumpModel=@PumpModel and SlNo=@SlNo)
begin
	select '3'  AS Status, isnull(max(reworkno),0)+1 as Count  from PumpTestData_Mivin where  machineid=@MachineID and pumpmodel=@PumpModel and SlNo=@SlNo
	and MeasuredDatetime=(select max(MeasuredDatetime) from PumpTestData_Mivin where MachineID=@MachineID and PumpModel=@PumpModel and SlNo=@SlNo)
end
else
begin
	select '2'  AS Status 
end
end
