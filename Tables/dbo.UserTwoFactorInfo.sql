CREATE TABLE [dbo].[UserTwoFactorInfo] (
  [EntityKey] [int] IDENTITY,
  [UserLoginID] [varchar](20) NOT NULL,
  [QuestionID] [int] NULL,
  [Answer] [varchar](max) NULL,
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
TEXTIMAGE_ON [PRIMARY]
GO