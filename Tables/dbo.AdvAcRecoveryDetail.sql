CREATE TABLE [dbo].[AdvAcRecoveryDetail] (
  [EntityKey] [bigint] IDENTITY,
  [CUSTOMERACID] [varchar](30) NULL,
  [AcType] [varchar](5) NULL,
  [RecAmt] [decimal](16, 2) NULL,
  [RecDate] [date] NOT NULL,
  [CashRecDate] [date] NOT NULL,
  [DemandDate] [date] NULL,
  [DemandAdj] [decimal](16, 2) NULL,
  [BalRecovery] [decimal](16, 2) NULL,
  [RecSchNumber] [varchar](5) NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [date] NULL
)
ON [PRIMARY]
GO