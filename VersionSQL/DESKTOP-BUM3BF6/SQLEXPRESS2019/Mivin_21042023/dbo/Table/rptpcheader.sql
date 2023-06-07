/****** Object:  Table [dbo].[rptpcheader]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptpcheader](
	[testid] [nvarchar](50) NULL,
	[customer] [nvarchar](50) NULL,
	[component] [nvarchar](50) NULL,
	[trialengr] [nvarchar](50) NULL,
	[date] [smalldatetime] NULL,
	[machineid] [nvarchar](50) NULL,
	[parameter] [nvarchar](50) NULL,
	[instused] [nvarchar](50) NULL,
	[slno] [int] IDENTITY(1,1) NOT NULL,
	[noofobs] [int] NULL,
	[groupsize] [int] NULL,
	[histInterval] [int] NULL,
 CONSTRAINT [PK_rptpcheader] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
