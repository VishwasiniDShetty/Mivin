/****** Object:  Table [dbo].[rptoperatorperformance]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptoperatorperformance](
	[employeeid] [nvarchar](50) NULL,
	[name] [nvarchar](50) NULL,
	[peffy] [int] NULL,
	[qeffy] [int] NULL,
	[dtfrom] [nvarchar](50) NULL,
	[dtto] [nvarchar](50) NULL
) ON [PRIMARY]
