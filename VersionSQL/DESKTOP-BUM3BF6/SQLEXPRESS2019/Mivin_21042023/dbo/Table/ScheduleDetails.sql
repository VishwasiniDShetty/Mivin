/****** Object:  Table [dbo].[ScheduleDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ScheduleDetails](
	[Date] [datetime] NULL,
	[WONumber] [nvarchar](50) NULL,
	[PumpModel] [nvarchar](50) NULL,
	[CustomerModel] [nvarchar](50) NULL,
	[CustomerName] [nvarchar](50) NULL,
	[PackagingType] [nvarchar](50) NULL,
	[PumpQty] [int] NULL,
	[WeekwisePriority] [int] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[UpdatedTS] [datetime] NULL,
	[IDD] [bigint] IDENTITY(1,1) NOT NULL,
	[WorkOrderStatus] [nvarchar](50) NULL
) ON [PRIMARY]
