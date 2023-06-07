/****** Object:  Table [dbo].[joborderworkorderlink]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[joborderworkorderlink](
	[joborderno] [nvarchar](50) NULL,
	[workorderno] [nvarchar](50) NULL,
	[slno] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_joborderworkorderlink] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
