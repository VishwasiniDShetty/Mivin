/****** Object:  Table [dbo].[PumpTestData_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PumpTestData_Mivin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineID] [nvarchar](50) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpType] [nvarchar](50) NOT NULL,
	[RotationalType] [nvarchar](50) NULL,
	[SlNo] [nvarchar](50) NOT NULL,
	[Event] [nvarchar](50) NOT NULL,
	[CycleStart] [datetime] NOT NULL,
	[MeasuredDatetime] [datetime] NOT NULL,
	[OperationNo] [int] NULL,
	[Operator] [nvarchar](50) NULL,
	[FlowVal] [float] NULL,
	[TempVal] [float] NULL,
	[PressureVal] [float] NULL,
	[RPMVal] [float] NULL,
	[FlowLSL] [float] NULL,
	[FlowUSL] [float] NULL,
	[TempLSL] [float] NULL,
	[TempUSL] [float] NULL,
	[PressureLSL] [float] NULL,
	[PressureUSL] [float] NULL,
	[RPMLSL] [float] NULL,
	[RPMUSL] [float] NULL,
	[ReCheckNo] [int] NULL,
	[ReWorkNo] [int] NULL,
	[IsMasterPump] [bit] NULL,
	[UpdatedTS] [datetime] NULL,
	[PumpAB] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[TorqueVal] [float] NULL,
	[TorqueMin] [float] NULL,
	[TorqueMax] [float] NULL,
	[ModelType] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MachineID] ASC,
	[PumpModel] ASC,
	[SlNo] ASC,
	[Event] ASC,
	[CycleStart] ASC,
	[MeasuredDatetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [PumpTestData-20211231-175934] ON [dbo].[PumpTestData_Mivin]
(
	[MachineID] ASC,
	[PumpModel] ASC,
	[SlNo] ASC,
	[Event] ASC,
	[CycleStart] ASC,
	[MeasuredDatetime] ASC,
	[UpdatedTS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[PumpTestData_Mivin] ADD  DEFAULT ((0)) FOR [IsMasterPump]
ALTER TABLE [dbo].[PumpTestData_Mivin] ADD  DEFAULT (getdate()) FOR [UpdatedTS]
