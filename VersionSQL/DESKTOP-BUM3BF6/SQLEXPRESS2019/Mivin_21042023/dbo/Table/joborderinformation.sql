/****** Object:  Table [dbo].[joborderinformation]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[joborderinformation](
	[JoborderNo] [nvarchar](50) NOT NULL,
	[JobOrderDate] [smalldatetime] NULL,
	[compound] [smallint] NULL,
 CONSTRAINT [PK_joborderinformation] PRIMARY KEY CLUSTERED 
(
	[JoborderNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[joborderinformation] ADD  CONSTRAINT [DF_joborderinformation_compound]  DEFAULT (0) FOR [compound]
