CREATE TABLE [dbo].[DimUserQuestionMaster] (
  [EntityKey] [int] IDENTITY,
  [QuestionID] [int] NOT NULL,
  [QuestionDescription] [varchar](500) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL
)
ON [PRIMARY]
GO