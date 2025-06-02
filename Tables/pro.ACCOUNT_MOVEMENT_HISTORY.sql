CREATE TABLE [pro].[ACCOUNT_MOVEMENT_HISTORY] (
  [EntityKey] [int] IDENTITY,
  [UCIF_ID] [varchar](50) NULL,
  [RefCustomerID] [varchar](50) NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [FinalNpaDt] [date] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [MovementFromDate] [date] NULL,
  [MovementFromStatus] [varchar](10) NULL,
  [MovementToStatus] [varchar](10) NULL,
  [MovementToDate] [date] NULL,
  [TotOsAcc] [decimal](18, 2) NULL
)
ON [PRIMARY]
GO