/****** Object:  Table [dbo].[rptDownTime]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptDownTime](
	[DownID] [nvarchar](50) NULL,
	[DownDescription] [nvarchar](100) NULL,
	[MachineID] [nvarchar](50) NULL,
	[EmployeeID] [nvarchar](50) NULL,
	[DownTime] [float] NULL,
	[StartTime] [smalldatetime] NULL,
	[EndTime] [smalldatetime] NULL
) ON [PRIMARY]
