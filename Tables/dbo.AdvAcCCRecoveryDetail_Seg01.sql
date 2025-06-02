CREATE TABLE [dbo].[AdvAcCCRecoveryDetail_Seg01] (
  [EntityKey] [int] IDENTITY,
  [TxnID] [varchar](50) NULL,
  [CustomerID] [varchar](30) NULL,
  [RecAmt] [decimal](16, 2) NULL,
  [RecDate] [date] NOT NULL,
  [DemandDate] [date] NULL,
  [BalRecovery] [decimal](16, 2) NULL,
  [UCIF_ID] [varchar](50) NULL
)
ON [PRIMARY]
GO

CREATE INDEX [AdvAcCCRecoveryDetail_001_IX_Seg01]
  ON [dbo].[AdvAcCCRecoveryDetail_Seg01] ([CustomerID], [BalRecovery], [RecDate], [UCIF_ID])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [AdvAcCCRecoveryDetail_ctrl_Seg01]
  ON [dbo].[AdvAcCCRecoveryDetail_Seg01] ([EntityKey])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO