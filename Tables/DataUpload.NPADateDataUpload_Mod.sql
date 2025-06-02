CREATE TABLE [DataUpload].[NPADateDataUpload_Mod] (
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
  [ChangeFields] [varchar](250) NULL,
  [ScreenFlag] [char](1) NULL,
  [SetID] [int] NULL,
  [ApprovedByFirstLevel] [varchar](50) NULL,
  [DateApprovedFirstLevel] [datetime] NULL,
  [NPADATECHANGEREASON] [varchar](100) NULL
)
ON [PRIMARY]
GO