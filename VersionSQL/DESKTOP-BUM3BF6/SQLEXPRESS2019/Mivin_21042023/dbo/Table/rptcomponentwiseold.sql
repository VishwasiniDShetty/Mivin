/****** Object:  Table [dbo].[rptcomponentwiseold]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptcomponentwiseold](
	[componentid] [nvarchar](50) NULL,
	[peffy] [float] NULL,
	[qeffy] [float] NULL,
	[aeffy] [float] NULL,
	[teffy] [float] NULL,
	[oeffy] [float] NULL,
	[prdtime] [float] NULL,
	[downtime] [float] NULL,
	[prodn] [int] NULL,
	[rejection] [int] NULL,
	[turnover] [float] NULL,
	[expectedturnover] [float] NULL,
	[slno] [int] NOT NULL,
	[strfrom] [nvarchar](50) NULL,
	[strto] [nvarchar](50) NULL
) ON [PRIMARY]
