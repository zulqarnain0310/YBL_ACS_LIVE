CREATE TABLE [DataUpload].[NPADateDataUpload] (
  [Entitykey] [int] IDENTITY,
  [NpaDateDataEntityId] [int] NULL,
  [UCIF_ID] [varchar](30) NULL,
  [NPADate] [date] NULL,
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
  [ScreenFlag] [char](1) NULL,
  [NPADATECHANGEREASON] [varchar](100) NULL
)
ON [PRIMARY]
GO