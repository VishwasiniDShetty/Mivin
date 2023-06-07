/****** Object:  Table [dbo].[MessageHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MessageHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PC_SerialNo] [nvarchar](50) NULL,
	[RequestedTime] [datetime] NULL,
	[SendTime] [datetime] NULL,
	[MsgStatus] [tinyint] NULL,
	[MobileNo] [nvarchar](50) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Message] [nvarchar](150) NULL,
	[MsgPerEvery] [int] NULL,
	[MachineID] [nvarchar](50) NULL,
	[Alerttype] [nvarchar](10) NULL,
	[Record_sttime] [datetime] NULL,
	[Record_ndtime] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[MessageHistory] ADD  DEFAULT ('N') FOR [Alerttype]
