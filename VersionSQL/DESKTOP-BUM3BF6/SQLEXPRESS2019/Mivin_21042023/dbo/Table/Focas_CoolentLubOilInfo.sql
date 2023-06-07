/****** Object:  Table [dbo].[Focas_CoolentLubOilInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Focas_CoolentLubOilInfo](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineId] [nvarchar](50) NOT NULL,
	[CNCTimeStamp] [datetime] NOT NULL,
	[CoolentLevel] [decimal](18, 3) NOT NULL,
	[LubOilLevel] [decimal](18, 3) NOT NULL,
	[PrevCoolentLevel] [decimal](18, 3) NOT NULL,
	[PrevLubOilLevel] [decimal](18, 3) NOT NULL,
	[CoolentLevelStatus]  AS (case when ([CoolentLevel]-[PrevCoolentLevel]/(4.905))*(100)>=(10) then '0' else '1' end),
	[LubOilLevelStatus]  AS (case when ([LubOilLevel]-[PrevLubOilLevel]/(4.905))*(100)>=(10) then '0' else '1' end),
 CONSTRAINT [PK_Focas_CoolentLubOilInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
