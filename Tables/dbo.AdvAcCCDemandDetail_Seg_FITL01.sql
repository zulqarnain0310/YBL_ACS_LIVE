CREATE TABLE [dbo].[AdvAcCCDemandDetail_Seg_FITL01] (
  [EntityKey] [int] IDENTITY,
  [CustomerID] [varchar](30) NULL,
  [DemandType] [varchar](25) NULL,
  [DemandDate] [date] NOT NULL,
  [DemandAmt] [decimal](16, 2) NULL,
  [RecDate] [date] NULL,
  [RecAdjDate] [date] NULL,
  [RecAmount] [decimal](16, 2) NULL,
  [BalanceDemand] [decimal](16, 2) NULL,
  [DmdSchNumber] [tinyint] NULL,
  [AcType] [varchar](25) NULL,
  [UCIF_ID] [varchar](50) NULL,
  [MnemonicCode] [varchar](20) NULL
)
ON [PRIMARY]
GO

CREATE INDEX [AdvAcCCDemandDetail_001_IX_Seg_FITL01]
  ON [dbo].[AdvAcCCDemandDetail_Seg_FITL01] ([CustomerID], [DemandDate], [BalanceDemand], [UCIF_ID])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE INDEX [AdvAcCCDemandDetail_002_IX_Seg_FITL01]
  ON [dbo].[AdvAcCCDemandDetail_Seg_FITL01] ([DemandDate])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE INDEX [AdvAcCCDemandDetail_003_IX_Seg_FITL01]
  ON [dbo].[AdvAcCCDemandDetail_Seg_FITL01] ([CustomerID], [DemandType], [UCIF_ID])
  INCLUDE ([BalanceDemand])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [AdvAcCCDemandDetail_ctrl_Seg_FITL01]
  ON [dbo].[AdvAcCCDemandDetail_Seg_FITL01] ([EntityKey])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO