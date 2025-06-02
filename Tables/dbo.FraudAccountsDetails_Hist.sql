CREATE TABLE [dbo].[FraudAccountsDetails_Hist] (
  [Entitykey] [bigint] IDENTITY,
  [UCIF_ID] [varchar](30) NULL,
  [CustomerID] [varchar](50) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [QTR] [int] NULL,
  [UsedFraudProvAmt] [decimal](22, 4) NULL,
  [FraudProvAmt] [decimal](22, 4) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO