/****** Object:  Table [dbo].[ShiftwiseTargetMaster]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ShiftwiseTargetMaster](
	[Date] [datetime] NULL,
	[StationID] [nvarchar](50) NULL,
	[Shift] [nvarchar](50) NULL,
	[Target] [int] NULL,
	[NoOfManpower] [int] NULL,
	[IDD] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
