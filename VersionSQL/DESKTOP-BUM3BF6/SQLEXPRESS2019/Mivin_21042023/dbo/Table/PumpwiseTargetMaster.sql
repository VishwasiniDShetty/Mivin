/****** Object:  Table [dbo].[PumpwiseTargetMaster]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PumpwiseTargetMaster](
	[Date] [datetime] NULL,
	[Shift] [nvarchar](50) NULL,
	[PumpModel] [nvarchar](50) NULL,
	[Target] [int] NULL,
	[IDD] [bigint] IDENTITY(1,1) NOT NULL,
	[StationID] [nvarchar](50) NULL
) ON [PRIMARY]
