/****** Object:  Table [dbo].[rptcomponentwise]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptcomponentwise](
	[componentid] [nvarchar](50) NULL,
	[employeeid] [nvarchar](25) NULL,
	[machineid] [nvarchar](50) NULL,
	[peffy] [float] NULL,
	[qeffy] [float] NULL,
	[aeffy] [float] NULL,
	[teffy] [float] NULL,
	[oeffy] [float] NULL,
	[prdtime] [nvarchar](50) NULL,
	[downtime] [nvarchar](50) NULL,
	[prodn] [int] NULL,
	[rejection] [int] NULL,
	[turnover] [float] NULL,
	[expectedturnover] [float] NULL,
	[slno] [bigint] IDENTITY(1,1) NOT NULL,
	[strfrom] [nvarchar](50) NULL,
	[strto] [nvarchar](50) NULL,
 CONSTRAINT [PK_rptcomponentwise] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
