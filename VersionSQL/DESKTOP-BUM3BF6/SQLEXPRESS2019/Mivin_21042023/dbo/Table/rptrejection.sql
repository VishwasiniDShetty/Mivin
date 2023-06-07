/****** Object:  Table [dbo].[rptrejection]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptrejection](
	[machineid] [nvarchar](50) NULL,
	[workorderno] [nvarchar](50) NULL,
	[employeeid] [nvarchar](50) NULL,
	[componentid] [nvarchar](50) NULL,
	[operationno] [int] NULL,
	[price] [int] NULL,
	[fromdate] [smalldatetime] NULL,
	[todate] [smalldatetime] NULL,
	[rejectionid] [nvarchar](50) NULL,
	[rejectiondescription] [nvarchar](50) NULL,
	[rejection] [int] NULL,
	[employeename] [nvarchar](50) NULL,
	[compdescription] [nvarchar](50) NULL
) ON [PRIMARY]
