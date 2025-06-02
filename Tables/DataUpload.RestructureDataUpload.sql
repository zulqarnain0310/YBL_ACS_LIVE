CREATE TABLE [DataUpload].[RestructureDataUpload] (
  [Entitykey] [int] IDENTITY,
  [RestructureDataEntityId] [int] NULL,
  [CustomerID] [varchar](50) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [CustomerName] [varchar](225) NULL,
  [RestructureDate] [date] NULL,
  [OriginalDCCODate] [date] NULL,
  [ExtendedDCCODate] [date] NULL,
  [ActualDCCODate] [date] NULL,
  [Infrastructure] [char](1) NULL,
  [DFVAmount] [decimal](18, 2) NULL,
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
  [EffectiveNPADate] [date] NULL,
  [NPAReason] [varchar](500) NULL
)
ON [PRIMARY]
GO