/****** Object:  Table [dbo].[rptonlinedata]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[rptonlinedata](
	[MachineID] [nvarchar](50) NULL,
	[FromTime] [nvarchar](50) NULL,
	[ToTime] [nvarchar](50) NULL,
	[Component] [nvarchar](50) NULL,
	[TotalTime] [nvarchar](50) NULL,
	[AvgCycleTime] [nvarchar](50) NULL,
	[AvgLoadUnLoad] [nvarchar](50) NULL,
	[DownTime] [nvarchar](50) NULL,
	[NoOfCompManufactured] [int] NULL,
	[AvailEffy] [float] NULL,
	[ProdnEffy] [float] NULL,
	[OverAllEffy] [float] NULL,
	[TurnOver] [float] NULL,
	[ReturnHr] [float] NULL,
	[CycleTime] [int] NULL,
	[LoadUnloadTime] [int] NULL,
	[CompNo] [int] NULL
) ON [PRIMARY]
