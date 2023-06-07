/****** Object:  Table [dbo].[PumpModelParameterMaster_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PumpModelParameterMaster_Mivin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpType] [nvarchar](50) NOT NULL,
	[Parameter] [nvarchar](50) NOT NULL,
	[Event] [nvarchar](50) NOT NULL,
	[PumpAB] [nvarchar](50) NOT NULL,
	[LSL] [float] NULL,
	[USL] [float] NULL,
	[UpdatedTS] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[PumpModel] ASC,
	[Parameter] ASC,
	[Event] ASC,
	[PumpAB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[PumpModelParameterMaster_Mivin] ADD  DEFAULT (getdate()) FOR [UpdatedTS]
