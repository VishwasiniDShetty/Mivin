/****** Object:  Table [dbo].[rptactualdata]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptactualdata](
	[workorderno] [nvarchar](50) NULL,
	[machineid] [nvarchar](50) NULL,
	[customerid] [nvarchar](50) NULL,
	[componentid] [nvarchar](50) NULL,
	[operationno] [smallint] NULL,
	[productiondate] [smalldatetime] NULL,
	[timefrom] [smalldatetime] NULL,
	[timeto] [smalldatetime] NULL,
	[employeeid] [nvarchar](50) NULL,
	[production] [float] NULL,
	[rejection] [float] NULL,
	[accepted] [float] NULL,
	[downid] [nvarchar](50) NULL,
	[prd] [int] NULL,
	[slno] [bigint] IDENTITY(1,1) NOT NULL,
	[tmfrom] [nvarchar](10) NULL,
	[tmto] [nvarchar](10) NULL,
	[strfrom] [nvarchar](50) NULL,
	[strto] [nvarchar](50) NULL,
 CONSTRAINT [PK_rptactualdata] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
