CREATE TABLE [dbo].[AdvAcCCRecoveryDetail_Seg02] (
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