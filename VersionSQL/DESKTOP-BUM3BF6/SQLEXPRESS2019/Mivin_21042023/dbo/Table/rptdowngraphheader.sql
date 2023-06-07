/****** Object:  Table [dbo].[rptdowngraphheader]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptdowngraphheader](
	[prdfrom] [nvarchar](50) NULL,
	[prdto] [nvarchar](50) NULL,
	[machineid] [nvarchar](50) NULL,
	[componentid] [nvarchar](50) NULL,
	[downid] [nvarchar](50) NULL,
	[employeeid] [nvarchar](50) NULL,
	[operationno] [int] NULL,
	[workorderno] [nvarchar](50) NULL,
	[slno] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](100) NULL,
 CONSTRAINT [PK_rptdowngraphheader] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
