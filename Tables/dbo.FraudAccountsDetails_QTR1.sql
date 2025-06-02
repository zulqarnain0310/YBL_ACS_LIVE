CREATE TABLE [dbo].[FraudAccountsDetails_QTR1] (
  [Entitykey] [bigint] IDENTITY,
  [UCIF_ID] [varchar](30) NULL,
  [CustomerID] [varchar](50) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [DateofFraud] [date] NULL,
  [AmountofFraud] [decimal](18, 2) NULL,
  [InitialNpaDt] [date] NULL,
  [FinalNpaDt] [date] NULL,
  [InitialAssetClassAlt_Key] [int] NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [ActualAssetClassAlt_Key] [int] NULL,
  [ProvisionPer] [decimal](5, 2) NULL,
  [QTR] [int] NULL,
  [AmtForFraudProv] [decimal](22, 4) NULL,
  [UsedFraudProvAmt] [decimal](22, 4) NULL,
  [FraudProvAmt] [decimal](22, 4) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [ProcessDate] [date] NULL,
  [ProvisionAmtAtFraud] [decimal](22, 4) NULL,
  [ProvisionAmtAtFraudPer] [decimal](18, 2) NULL
)
ON [PRIMARY]
GO