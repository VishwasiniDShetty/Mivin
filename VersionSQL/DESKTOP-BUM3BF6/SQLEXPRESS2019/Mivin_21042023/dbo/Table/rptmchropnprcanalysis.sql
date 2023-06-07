/****** Object:  Table [dbo].[rptmchropnprcanalysis]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptmchropnprcanalysis](
	[machineid] [nvarchar](50) NULL,
	[componentid] [nvarchar](50) NULL,
	[operationno] [nvarchar](50) NULL,
	[cycletime] [int] NULL,
	[opnprice] [float] NULL,
	[exptminopnprice] [float] NULL,
	[mchrrate] [float] NULL,
	[diff] [float] NULL,
	[perdiff] [float] NULL
) ON [PRIMARY]
