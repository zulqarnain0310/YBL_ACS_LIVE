CREATE TABLE [pro].[AcDailyTxnDetail_Cal] (
  [AccountEntityID] [int] NULL,
  [ProductCode] [varchar](20) NULL,
  [CustomerAcID] [varchar](20) NULL,
  [TxnAmount] [decimal](16, 2) NULL,
  [TxnType] [varchar](10) NULL,
  [TxnSubType] [varchar](20) NULL,
  [TxnValueDate] [date] NULL,
  [SourceAlt_Key] [tinyint] NULL,
  [TrueCredit] [char](1) NULL,
  [MNEMONICCODE] [varchar](20) NULL,
  [PARTICULAR] [varchar](500) NULL
)
ON [PRIMARY]
GO