CREATE TABLE [dbo].[AdvAcProjectDetail_Upload_Mod] (
  [EntityKey] [int] IDENTITY,
  [CustomerEntityID] [int] NULL,
  [CustomerID] [varchar](20) NULL,
  [CustomerName] [varchar](100) NULL,
  [AccountID] [varchar](30) NULL,
  [OriginalEnvisagCompletionDt] [datetime] NULL,
  [RevisedCompletionDt] [datetime] NULL,
  [ActualCompletionDt] [datetime] NULL,
  [ProjectCat] [varchar](100) NULL,
  [ProjectDelReason] [varchar](100) NULL,
  [StandardRestruct] [varchar](100) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL
)
ON [PRIMARY]
GO