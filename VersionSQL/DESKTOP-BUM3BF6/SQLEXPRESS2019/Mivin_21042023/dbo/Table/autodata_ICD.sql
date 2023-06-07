/****** Object:  Table [dbo].[autodata_ICD]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[autodata_ICD](
	[mc] [nvarchar](50) NULL,
	[comp] [nvarchar](50) NULL,
	[opn] [nvarchar](50) NULL,
	[opr] [nvarchar](50) NULL,
	[dcode] [nvarchar](50) NULL,
	[stdate] [datetime] NULL,
	[sttime] [datetime] NULL,
	[nddate] [datetime] NULL,
	[ndtime] [datetime] NULL,
	[datatype] [int] NULL,
	[cycletime] [int] NULL,
	[loadunload] [int] NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_autodata_ICD] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [IX_MCSTTIME] ON [dbo].[autodata_ICD]
(
	[mc] ASC,
	[sttime] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
