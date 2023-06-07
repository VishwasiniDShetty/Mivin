/****** Object:  Table [dbo].[ManPowerDetails_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ManPowerDetails_Mivin](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Pdate] [datetime] NOT NULL,
	[Shift] [nvarchar](50) NOT NULL,
	[Machineid] [nvarchar](50) NOT NULL,
	[NoOfOperators] [int] NULL,
	[updatedTS] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[ManPowerDetails_Mivin] ADD  DEFAULT (getdate()) FOR [updatedTS]
