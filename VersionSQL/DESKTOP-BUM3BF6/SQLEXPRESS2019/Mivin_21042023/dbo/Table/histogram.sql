/****** Object:  Table [dbo].[histogram]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[histogram](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[lbl] [float] NULL,
	[occ] [smallint] NULL,
 CONSTRAINT [PK_histogram] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[histogram] ADD  CONSTRAINT [DF_histogram_lbl]  DEFAULT (0) FOR [lbl]
ALTER TABLE [dbo].[histogram] ADD  CONSTRAINT [DF_histogram_occ]  DEFAULT (0) FOR [occ]
