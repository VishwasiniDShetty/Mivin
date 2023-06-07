/****** Object:  Table [dbo].[StationInformation]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[StationInformation](
	[IDD] [bigint] IDENTITY(1,1) NOT NULL,
	[StationID] [nvarchar](50) NULL,
	[StationDesc] [nvarchar](200) NULL,
	[PrinterName] [nvarchar](50) NULL,
	[PrinterServerIP] [nvarchar](50) NULL,
	[QRScannerIP] [nvarchar](50) NULL,
	[QRScannerPort] [int] NULL,
	[RegisterAddress] [nvarchar](50) NULL,
	[NoOfRegistersToRead] [int] NULL
) ON [PRIMARY]
