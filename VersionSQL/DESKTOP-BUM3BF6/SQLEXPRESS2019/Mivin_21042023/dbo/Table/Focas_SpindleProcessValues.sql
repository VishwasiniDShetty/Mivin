/****** Object:  Table [dbo].[Focas_SpindleProcessValues]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_SpindleProcessValues](
	[MacroVariable] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NULL,
	[Value] [decimal](18, 3) NULL,
	[BatchTS] [datetime] NULL,
	[IDD] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineId] [nvarchar](50) NULL
) ON [PRIMARY]
