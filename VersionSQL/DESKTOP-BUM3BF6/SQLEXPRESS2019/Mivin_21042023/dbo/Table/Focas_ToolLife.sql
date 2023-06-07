/****** Object:  Table [dbo].[Focas_ToolLife]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_ToolLife](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineID] [nvarchar](50) NOT NULL,
	[ComponentID] [nvarchar](50) NOT NULL,
	[OperationID] [nvarchar](50) NOT NULL,
	[ToolNo] [nvarchar](50) NOT NULL,
	[ToolActual] [int] NOT NULL,
	[ToolTarget] [int] NOT NULL,
	[SpindleType] [int] NOT NULL,
	[ProgramNo] [int] NOT NULL,
	[CNCTimeStamp] [datetime] NOT NULL,
	[ToolUseOrderNumber] [int] NULL,
	[ToolInfo] [int] NULL,
	[PartsCount] [int] NULL,
	[ChangeReason] [int] NULL
) ON [PRIMARY]
