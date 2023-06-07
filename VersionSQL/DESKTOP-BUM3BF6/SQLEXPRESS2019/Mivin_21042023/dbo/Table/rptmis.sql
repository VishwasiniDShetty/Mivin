/****** Object:  Table [dbo].[rptmis]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptmis](
	[Machineid] [nvarchar](50) NOT NULL,
	[noofwo] [int] NULL,
	[totaltime] [float] NULL,
	[totaltimedisp] [float] NULL,
	[utilisedtime] [float] NULL,
	[utilisedtimedisp] [float] NULL,
	[downtime] [float] NULL,
	[downtimedisp] [float] NULL,
	[availeffy] [float] NULL,
	[prodeffy] [float] NULL,
	[qualityeffy] [float] NULL,
	[expectedto] [float] NULL,
	[turnover] [float] NULL,
	[toeffy] [float] NULL,
	[overalleffy] [float] NULL,
	[retpermchour] [float] NULL,
	[retpermchrtotal] [float] NULL,
 CONSTRAINT [PK_rptmis] PRIMARY KEY CLUSTERED 
(
	[Machineid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
