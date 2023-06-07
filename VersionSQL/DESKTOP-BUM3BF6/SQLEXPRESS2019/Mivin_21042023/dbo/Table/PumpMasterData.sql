/****** Object:  Table [dbo].[PumpMasterData]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PumpMasterData](
	[PumpModel] [nvarchar](50) NOT NULL,
	[CustomerModel] [nvarchar](50) NULL,
	[CustomerName] [nvarchar](500) NULL,
	[SalesUnit] [nvarchar](50) NULL,
	[PackagingType] [nvarchar](50) NOT NULL,
	[PackingBoxNumber] [nvarchar](50) NULL,
	[PerBoxPumpQty] [int] NULL,
	[PumpType] [nvarchar](50) NULL,
	[BoxDestination] [nvarchar](50) NULL,
 CONSTRAINT [PK_PumpMasterData] PRIMARY KEY CLUSTERED 
(
	[PumpModel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
