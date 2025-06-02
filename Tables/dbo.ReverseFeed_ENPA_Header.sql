CREATE TABLE [dbo].[ReverseFeed_ENPA_Header] (
  [ATHEZ-H-ORG] [varchar](3) NULL,
  [ATHEZ-H-CLIENT-ID] [varchar](8) NULL,
  [ATHEZ-H-DATE] [varchar](8) NULL,
  [ATHEZ-H-BULK-UPD-ONLINE] [char](1) NULL,
  [FILLER] [varchar](180) NULL,
  [DateofData] [date] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO