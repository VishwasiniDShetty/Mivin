/****** Object:  Table [dbo].[RunningScheduleDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RunningScheduleDetails](
	[StationID] [nvarchar](50) NULL,
	[WONumber] [nvarchar](50) NULL,
	[PumpModel] [nvarchar](50) NULL,
	[CustomerModel] [nvarchar](50) NULL,
	[ScheduledDate] [datetime] NULL,
	[PackagingType] [nvarchar](50) NULL
) ON [PRIMARY]
