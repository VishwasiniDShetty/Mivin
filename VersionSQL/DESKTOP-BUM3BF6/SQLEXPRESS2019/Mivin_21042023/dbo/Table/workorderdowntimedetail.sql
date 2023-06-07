﻿/****** Object:  Table [dbo].[workorderdowntimedetail]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[workorderdowntimedetail](
	[workorderno] [nvarchar](50) NULL,
	[downdate] [smalldatetime] NULL,
	[timefrom] [datetime] NULL,
	[timeto] [datetime] NULL,
	[employeeid] [nvarchar](50) NULL,
	[downid] [nvarchar](50) NULL,
	[totaldown] [float] NULL,
	[slno] [bigint] IDENTITY(1,1) NOT NULL,
	[AutoGenerated] [smallint] NULL,
 CONSTRAINT [PK_workorderdowntimedetail] PRIMARY KEY CLUSTERED 
(
	[slno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[workorderdowntimedetail] ADD  CONSTRAINT [DF_workorderdowntimedetail_workorderno]  DEFAULT (0) FOR [workorderno]
ALTER TABLE [dbo].[workorderdowntimedetail] ADD  CONSTRAINT [DF_workorderdowntimedetail_totaldown]  DEFAULT (0) FOR [totaldown]
ALTER TABLE [dbo].[workorderdowntimedetail] ADD  CONSTRAINT [DF_workorderdowntimedetail_AutoGenerated]  DEFAULT (0) FOR [AutoGenerated]
