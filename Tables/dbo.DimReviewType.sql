CREATE TABLE [dbo].[DimReviewType] (
  [Review_Key] [smallint] NOT NULL,
  [ReviewAlt_Key] [smallint] NULL,
  [ReviewName] [varchar](50) NULL,
  [ReviewShortName] [varchar](20) NULL,
  [ReviewShortNameEnum] [varchar](20) NULL,
  [ReviewGroup] [varchar](50) NULL,
  [ReviewSubGroup] [varchar](50) NULL,
  [ReviewSegment] [varchar](50) NULL,
  [ReviewValidCode] [char](1) NULL,
  [SrcSysReviewCode] [varchar](50) NULL,
  [SrcSysReviewName] [varchar](50) NULL,
  [DestSysReviewTypeCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO