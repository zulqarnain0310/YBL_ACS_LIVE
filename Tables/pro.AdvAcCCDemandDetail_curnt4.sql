CREATE TABLE [pro].[AdvAcCCDemandDetail_curnt4] (
  [EntityKey] [int] IDENTITY,
  [CustomerID] [varchar](10) NULL,
  [CustomerACID] [varchar](25) NULL,
  [TxnID] [varchar](50) NULL,
  [DemandType] [varchar](25) NULL,
  [DemandDate] [date] NOT NULL,
  [DemandAmt] [decimal](16, 2) NULL,
  [RecDate] [date] NULL,
  [RecAdjDate] [date] NULL,
  [RecAmount] [decimal](16, 2) NULL,
  [BalanceDemand] [decimal](16, 2) NULL,
  [DmdSchNumber] [tinyint] NULL,
  [RefSystemACID] [varchar](20) NULL,
  [AcType] [varchar](25) NULL,
  [IsFullSatisfied] [bit] NULL,
  [FullSatisfiedDate] [date] NULL,
  [NoOfSatisfyIteration] [smallint] NULL,
  [ScoreDayCount] [smallint] NULL,
  [CreditDemandDate] [date] NULL,
  [UCIF_ID] [varchar](50) NULL
)
ON [PRIMARY]
GO