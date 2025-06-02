CREATE TABLE [dbo].[DimBusinessAcSegment] (
  [BusinessSegments_Key] [smallint] IDENTITY,
  [BusinessSegmentsAlt_Key] AS ([BusinessSegments_Key]),
  [BusinessSegmentsCode] [varchar](20) NULL,
  [BusinessSegmentsName] [varchar](200) NULL,
  [BusinessSegmentsShortName] [varchar](20) NULL,
  [BusinessSegmentsShortNameEnum] [varchar](20) NULL,
  [BusinessSegmentsGroup] [varchar](50) NULL,
  [BusinessSegmentsSubGroup] [varchar](50) NULL,
  [BusinessSegmentsSegment] [varchar](50) NULL,
  [SrcSysBusinessSegmentsCode] [varchar](10) NULL,
  [SrcSysBusinessSegmentsName] [varchar](50) NULL,
  [DestSysBusinessSegmentsCode] [varchar](10) NULL,
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