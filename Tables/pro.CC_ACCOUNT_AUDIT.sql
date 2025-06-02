CREATE TABLE [pro].[CC_ACCOUNT_AUDIT] (
  [AC_key] [int] IDENTITY,
  [AcType] [varchar](50) NULL,
  [StartDate] [date] NULL,
  [EndDate] [date] NULL,
  [SumDebit] [decimal](18, 2) NULL,
  [SumCredit] [decimal](18, 2) NULL,
  [SumDebitFin] [decimal](18, 2) NULL,
  [SumCreditFin] [decimal](18, 2) NULL
)
ON [PRIMARY]
GO