/****** Object:  Table [dbo].[ScannedDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ScannedDetails](
	[Date] [datetime] NULL,
	[StationID] [nvarchar](50) NULL,
	[Shift] [nvarchar](50) NULL,
	[WONumber] [nvarchar](50) NULL,
	[PumpModel] [nvarchar](50) NULL,
	[CustomerModel] [nvarchar](50) NULL,
	[ScannedQty] [int] NULL,
	[Operator] [nvarchar](50) NULL,
	[ScannedSlNo] [nvarchar](50) NULL,
	[ScannedOrForceCloseStatus] [int] NULL,
	[ScannedTS] [datetime] NULL,
	[Remarks] [nvarchar](1000) NULL,
	[IDD] [bigint] IDENTITY(1,1) NOT NULL,
	[ScheduledDate] [datetime] NULL,
	[PackagingType] [nvarchar](50) NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[ScannedDetails] ADD  CONSTRAINT [DF__ScannedDe__Scann__21B6055D]  DEFAULT ((0)) FOR [ScannedOrForceCloseStatus]
