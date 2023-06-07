/****** Object:  Table [dbo].[Focas_AlarmHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_AlarmHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AlarmNo] [bigint] NULL,
	[AlarmGroupNo] [bigint] NULL,
	[AlarmMSG] [nvarchar](255) NULL,
	[AlarmAxisNo] [bigint] NULL,
	[AlarmTotAxisNo] [bigint] NULL,
	[AlarmGCode] [nvarchar](250) NULL,
	[AlarmOtherCode] [nvarchar](250) NULL,
	[AlarmMPos] [nvarchar](255) NULL,
	[AlarmAPos] [nvarchar](255) NULL,
	[AlarmTime] [datetime] NULL,
	[MachineID] [nvarchar](50) NULL,
	[AckStatus] [int] NULL,
	[Endtime] [datetime] NULL
) ON [PRIMARY]
