/****** Object:  Table [dbo].[rptdowngraph]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptdowngraph](
	[downid] [nvarchar](50) NULL,
	[down] [float] NULL,
	[slno] [bigint] IDENTITY(1,1) NOT NULL,
	[aggregate] [float] NULL,
	[aggregatetitle] [nvarchar](50) NULL,
	[description] [nvarchar](50) NULL,
	[detail] [nvarchar](50) NULL,
 CONSTRAINT [PK_rptdowngraph] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
