CREATE TABLE [DataUpload].[RePossessedAccountDataUpload_mod] (
  [Entitykey] [int] IDENTITY,
  [RePossessedDataEntityId] [int] NULL,
  [CustomerID] [varchar](50) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [CustomerName] [varchar](225) NULL,
  [RepossessionDate] [date] NULL,
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
  [ApprovedByFirstLevel] [varchar](50) NULL,
  [DateApprovedFirstLevel] [datetime] NULL
)
ON [PRIMARY]
GO