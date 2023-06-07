/****** Object:  Table [dbo].[rpttargetvsperformance]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rpttargetvsperformance](
	[criteria] [nvarchar](50) NULL,
	[actualvalue] [float] NULL,
	[Expectedvalue] [float] NULL,
	[Targetvalue] [float] NULL,
	[slno] [int] IDENTITY(1,1) NOT NULL,
	[dtfrom] [smalldatetime] NULL,
	[dtto] [smalldatetime] NULL,
 CONSTRAINT [PK_rpttargetvsperformance] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
