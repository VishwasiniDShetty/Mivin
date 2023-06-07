/****** Object:  Table [dbo].[PlantMachineGroupSubgroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PlantMachineGroupSubgroup](
	[PlantID] [nvarchar](50) NULL,
	[MachineID] [nvarchar](50) NULL,
	[GroupID] [nvarchar](50) NULL,
	[SubGroups] [nvarchar](50) NULL,
	[GroupOrder] [int] NULL,
	[description] [nvarchar](100) NULL,
	[EndOfLineMachine] [nvarchar](50) NULL,
	[EndOfGroupMachine] [nvarchar](50) NULL,
	[MachineSequence] [int] NULL
) ON [PRIMARY]
