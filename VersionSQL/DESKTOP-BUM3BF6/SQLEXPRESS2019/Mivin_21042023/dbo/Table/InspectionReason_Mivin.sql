/****** Object:  Table [dbo].[InspectionReason_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[InspectionReason_Mivin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InterfaceID] [nvarchar](50) NULL,
	[InspectionType] [nvarchar](50) NULL,
	[Reason] [nvarchar](100) NULL
) ON [PRIMARY]
