/****** Object:  Table [dbo].[Focas_ToolOffsetHistoryTemp]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_ToolOffsetHistoryTemp](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineID] [nvarchar](50) NOT NULL,
	[MachineMode] [nvarchar](50) NULL,
	[ProgramNo] [nvarchar](50) NULL,
	[ToolNo] [int] NULL,
	[OffsetNo] [int] NULL,
	[WearOffsetX] [float] NULL,
	[WearOffsetZ] [float] NULL,
	[WearOffsetR] [float] NULL,
	[WearOffsetT] [float] NULL,
	[CNCTimeStamp] [datetime] NULL
) ON [PRIMARY]
