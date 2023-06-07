/****** Object:  Table [dbo].[Focas_ToolOffsetHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_ToolOffsetHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineID] [nvarchar](50) NOT NULL,
	[MachineTimeStamp] [datetime] NULL,
	[ProgramNumber] [nvarchar](50) NULL,
	[ToolNo] [int] NULL,
	[ToolSequenceNum] [int] NULL,
	[CuttingTime] [float] NULL,
	[ToolUsageTime] [float] NULL,
	[OffsetNo] [int] NULL,
	[WearOffsetX] [float] NULL,
	[WearOffsetZ] [float] NULL,
	[WearOffsetR] [float] NULL,
	[WearOffsetT] [float] NULL,
	[GeometryOffsetX] [float] NULL,
	[GeometryOffsetZ] [float] NULL,
	[GeometryOffsetR] [float] NULL,
	[GeometryOffsetT] [float] NULL,
	[MachineMode] [nvarchar](50) NULL
) ON [PRIMARY]
