CREATE TABLE [pro].[AccountWiseMiscDetailCal] (
  [AccountEntityID] [int] NULL,
  [VariableCreditAmt] [decimal](18, 2) NULL,
  [VariableDebitAmt] [decimal](18, 2) NULL,
  [DaysCount] [int] NULL,
  [InternalFDFlag] [char](1) NULL,
  [AccountMarking] [varchar](100) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [UCIF_ID] [varchar](30) NULL,
  [FD_UCIF_Security] [decimal](22, 4) NULL
)
ON [PRIMARY]
GO