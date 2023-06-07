/****** Object:  Table [dbo].[xbar]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[xbar](
	[ucl] [float] NULL,
	[lcl] [float] NULL,
	[mean] [float] NULL,
	[xbar] [float] NULL,
	[slno] [smallint] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[xbar] ADD  CONSTRAINT [DF_xbar_ucl]  DEFAULT (0) FOR [ucl]
ALTER TABLE [dbo].[xbar] ADD  CONSTRAINT [DF_xbar_lcl]  DEFAULT (0) FOR [lcl]
ALTER TABLE [dbo].[xbar] ADD  CONSTRAINT [DF_xbar_mean]  DEFAULT (0) FOR [mean]
ALTER TABLE [dbo].[xbar] ADD  CONSTRAINT [DF_xbar_xbar]  DEFAULT (0) FOR [xbar]
ALTER TABLE [dbo].[xbar] ADD  CONSTRAINT [DF_xbar_slno]  DEFAULT (0) FOR [slno]
