/****** Object:  Table [dbo].[PlantWiseTargetDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PlantWiseTargetDetails_Mivin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[GroupID] [nvarchar](50) NULL,
	[Target] [float] NULL,
	[UpdatedTS] [datetime] NULL,
	[PlantID] [nvarchar](50) NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[PlantWiseTargetDetails_Mivin] ADD  DEFAULT (getdate()) FOR [UpdatedTS]
