/****** Object:  Table [dbo].[PumpModelMasterTemp_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PumpModelMasterTemp_Mivin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpType] [nvarchar](50) NOT NULL,
	[PumpCategory] [nvarchar](50) NOT NULL,
	[RotationalType] [nvarchar](50) NULL,
	[TimeIntervalVal1] [float] NULL,
	[TimeIntervalVal2] [float] NULL,
	[TimeIntervalVal3] [float] NULL,
	[TimeIntervalVal4] [float] NULL,
	[TimeIntervalVal5] [float] NULL,
	[PumpDescription] [nvarchar](50) NULL,
	[CustomerID] [nvarchar](50) NULL
) ON [PRIMARY]
