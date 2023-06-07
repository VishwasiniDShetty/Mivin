/****** Object:  Table [dbo].[Focas_SpindleInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_SpindleInfo](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineId] [nvarchar](50) NOT NULL,
	[CNCTimeStamp] [datetime] NOT NULL,
	[SpindleSpeed] [decimal](18, 0) NULL,
	[SpindleLoad] [decimal](18, 3) NULL,
	[Temperature] [decimal](18, 3) NULL,
	[FeedRate] [decimal](18, 3) NULL,
	[ProgramNo] [nvarchar](50) NULL,
	[ToolNo] [nvarchar](50) NULL,
	[SpindleTarque] [decimal](18, 3) NULL,
	[AxisNo] [nvarchar](5) NULL
) ON [PRIMARY]
