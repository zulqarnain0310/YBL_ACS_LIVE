CREATE TABLE [pro].[AcDailyTxnDetailDaily] (
  [CustomerKey] [int] IDENTITY,
  [customerID] [varchar](20) NULL,
  [CustomerAcid] [varchar](50) NULL,
  [TxnDate] [date] NULL,
  [TxnType] [varchar](50) NULL,
  [TxnSubType] [varchar](50) NULL,
  [CurrencyCode] [varchar](50) NULL,
  [TxnAmount] [decimal](18, 2) NULL,
  [TxnRefNo] [varchar](50) NULL,
  [UCIF_ID] [varchar](50) NULL,
  [MnemonicCode] [varchar](20) NULL,
  PRIMARY KEY CLUSTERED ([CustomerKey])
)
ON [PRIMARY]
GO