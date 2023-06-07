/****** Object:  Table [dbo].[Focas_PredictiveMaintenanceMaster]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_PredictiveMaintenanceMaster](
	[MTB] [nvarchar](50) NOT NULL,
	[AlarmNo] [int] NOT NULL,
	[AlarmDesc] [nvarchar](500) NOT NULL,
	[DurationType] [nvarchar](50) NULL,
	[DurationIn] [nvarchar](50) NULL,
	[TargetDLocation] [int] NOT NULL,
	[CurrentValueDLocation] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL
) ON [PRIMARY]
