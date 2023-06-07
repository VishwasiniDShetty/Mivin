/****** Object:  Table [dbo].[PumpModelMaster_Mivin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PumpModelMaster_Mivin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PumpModel] [nvarchar](50) NOT NULL,
	[PumpType] [nvarchar](50) NOT NULL,
	[PumpCategory] [nvarchar](50) NOT NULL,
	[RotationalType] [nvarchar](50) NULL,
	[TimeIntervalVal1] [float] NULL,
	[TimeIntervalVal2] [float] NULL,
	[TimeIntervalVal3] [float] NULL,
	[TimeIntervalVal4] [float] NULL,
	[TimeIntervalVal5] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[PumpModel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
