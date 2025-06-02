CREATE TABLE [dbo].[AdvAcCCDemandDetail_FITL] (
  [EntityKey] [int] IDENTITY,
  [CustomerID] [varchar](30) NULL,
  [DemandType] [varchar](25) NULL,
  [DemandDate] [date] NOT NULL,
  [DemandAmt] [decimal](16, 2) NULL,
  [RecDate] [date] NULL,
  [RecAdjDate] [date] NULL,
  [RecAmount] [decimal](16, 2) NULL,
  [BalanceDemand] [decimal](16, 2) NULL,
  [DmdSchNumber] [tinyint] NULL,
  [AcType] [varchar](25) NULL,
  [UCIF_ID] [varchar](50) NULL,
  [MnemonicCode] [varchar](20) NULL
)
ON [PRIMARY]
GO