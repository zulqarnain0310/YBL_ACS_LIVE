CREATE TABLE [dbo].[ReverseFeed_ENPA] (
  [SourceSystemName] [varchar](30) NULL,
  [DateofData] [date] NULL,
  [UCIC_ID] [varchar](30) NULL,
  [FCR_CustomerID] [varchar](30) NULL,
  [SourceSystemCustomerID] [varchar](30) NULL,
  [AccountID] [varchar](30) NULL,
  [AssetClass] [varchar](20) NULL,
  [AssetSubClass] [varchar](20) NULL,
  [NPADate] [date] NULL,
  [NPAReason] [varchar](max) NULL,
  [NPACategory] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO