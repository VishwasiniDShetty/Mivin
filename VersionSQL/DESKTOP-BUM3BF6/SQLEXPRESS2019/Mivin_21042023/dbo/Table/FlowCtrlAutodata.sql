/****** Object:  Table [dbo].[FlowCtrlAutodata]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[FlowCtrlAutodata](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineInterface] [nvarchar](50) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpSeries] [nvarchar](50) NOT NULL,
	[Operator] [nvarchar](50) NULL,
	[MinFlow] [float] NOT NULL,
	[MaxFlow] [float] NULL,
	[Starttime] [datetime] NOT NULL,
	[Endtime] [datetime] NULL,
	[Remarks] [varchar](max) NULL,
	[Loadunload] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [IX_FlowCtrlAutodata] ON [dbo].[FlowCtrlAutodata]
(
	[MachineInterface] ASC,
	[PumpModel] ASC,
	[PumpSeries] ASC,
	[Starttime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
