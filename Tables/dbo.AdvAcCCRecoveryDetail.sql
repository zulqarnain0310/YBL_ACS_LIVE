CREATE TABLE [dbo].[AdvAcCCRecoveryDetail] (
  [EntityKey] [int] IDENTITY,
  [CustomerID] [varchar](30) NULL,
  [RecAmt] [decimal](16, 2) NULL,
  [RecDate] [date] NOT NULL,
  [BalRecovery] [decimal](16, 2) NULL,
  [UCIF_ID] [varchar](50) NULL
)
ON [PRIMARY]
GO