/****** Object:  Table [dbo].[componetlistrept]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[componetlistrept](
	[CustomerID] [nvarchar](50) NULL,
	[ComponentID] [nvarchar](50) NULL,
	[OperationNo] [int] NULL,
	[Description1] [nvarchar](50) NULL,
	[Description2] [nvarchar](50) NULL,
	[MachineID] [nvarchar](50) NULL,
	[Price] [int] NULL,
	[CycleTime] [int] NULL,
	[DrawingNo] [nvarchar](50) NULL
) ON [PRIMARY]
