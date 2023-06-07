/****** Object:  Table [dbo].[PumpModelParameterMasterTemp_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PumpModelParameterMasterTemp_Mivin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpType] [nvarchar](50) NULL,
	[Parameter] [nvarchar](50) NOT NULL,
	[Event] [nvarchar](50) NOT NULL,
	[PumpAB] [nvarchar](50) NOT NULL,
	[LSL] [float] NULL,
	[USL] [float] NULL,
	[UpdatedTS] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[PumpModelParameterMasterTemp_Mivin] ADD  DEFAULT (getdate()) FOR [UpdatedTS]
