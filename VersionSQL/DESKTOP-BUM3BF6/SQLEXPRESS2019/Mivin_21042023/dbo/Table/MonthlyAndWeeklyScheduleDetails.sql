/****** Object:  Table [dbo].[MonthlyAndWeeklyScheduleDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MonthlyAndWeeklyScheduleDetails](
	[Date] [datetime] NULL,
	[PumpModel] [nvarchar](50) NULL,
	[PackagingType] [nvarchar](50) NULL,
	[CustomerName] [nvarchar](50) NULL,
	[MonthRequirement] [int] NULL,
	[Week1Qty] [int] NULL,
	[Week2Qty] [int] NULL,
	[Week3Qty] [int] NULL,
	[Week4Qty] [int] NULL,
	[Week5Qty] [int] NULL,
	[CustomerModel] [nvarchar](50) NULL,
	[WONumber] [nvarchar](50) NULL,
	[WeekwisePriority] [int] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[UpdatedTS] [datetime] NULL,
	[IDD] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
