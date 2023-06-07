/****** Object:  Table [dbo].[rptdown]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptdown](
	[downid] [nvarchar](50) NULL,
	[downdescription] [nvarchar](50) NULL,
	[machineid] [nvarchar](50) NULL,
	[down] [int] NULL,
	[mctotdown] [int] NULL,
	[dtotdown] [int] NULL,
	[totdown] [int] NULL,
	[downdisp] [float] NULL,
	[mctotdowndisp] [float] NULL,
	[dtotdowndisp] [float] NULL,
	[totdowndisp] [float] NULL
) ON [PRIMARY]
