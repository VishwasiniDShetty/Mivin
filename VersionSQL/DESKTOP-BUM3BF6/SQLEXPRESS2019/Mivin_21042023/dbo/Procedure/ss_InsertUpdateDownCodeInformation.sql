/****** Object:  Procedure [dbo].[ss_InsertUpdateDownCodeInformation]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[ss_InsertUpdateDownCodeInformation]
@downid  nvarchar(50)='',
@interfaceid nvarchar(50)='',
@downDescription nvarchar(50)='',
@catagory nvarchar(50)='',
@availeffy bit=0,
@retpermchour bit=0,
@Threshold float='',
@Prodeffy bit =0,
@ThresholdFromCO bit =0,
@param nvarchar(50)=''	
AS
BEGIN

	SET NOCOUNT ON;


If EXISTS(select * from DownCodeInformation where interfaceid=@InterfaceID and downID <> @downid)
BEGIN
RAISERROR('This interfaceID already exists for another downID',16,1)
return -1;
END

if(@param= 'Update')
BEGIN
update  DownCodeInformation set interfaceid=@interfaceid ,downDescription = @downDescription ,availeffy= @availeffy,
retpermchour=@retpermchour,Threshold=@Threshold,ProdEffy=@ProdEffy ,ThresholdFromCO= @ThresholdFromCO,Catagory=@catagory --Added Catagory
where downid=@downid
END


if(@param= 'Insert')
BEGIN

if exists(select * from downcodeinformation where downid = @downid)
BEGIN
RAISERROR('This Down ID already exists',16,1)
return -1;
END

insert into DownCodeInformation(downid,downdescription,catagory,interfaceid,availeffy,retpermchour,Threshold,ProdEffy,ThresholdFromCO)
values(@downid,@downdescription,@catagory,@interfaceid,@availeffy,@retpermchour,@Threshold,@ProdEffy,@ThresholdFromCO)
END
END
