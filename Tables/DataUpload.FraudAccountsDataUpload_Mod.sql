CREATE TABLE [DataUpload].[FraudAccountsDataUpload_Mod] (
  [Entitykey] [int] IDENTITY,
  [FraudAccountDataEntityId] [int] NULL,
  [UCIF_ID] [varchar](30) NULL,
  [CustomerID] [varchar](50) NULL,
  [CustomerName] [varchar](225) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [DateofFraud] [date] NULL,
  [AmountofFraud] [decimal](18, 2) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [ChangeFields] [varchar](250) NULL,
  [SetID] [int] NULL,
  [EffectiveNPADate] [date] NULL,
  [ApprovedByFirstLevel] [varchar](50) NULL,
  [DateApprovedFirstLevel] [datetime] NULL
)
ON [PRIMARY]
GO