CREATE TABLE [dbo].[DimLineCode] (
  [LineCode_Key] [smallint] IDENTITY,
  [LineCodeAlt_Key] AS ([LineCode_Key]),
  [LineCode] [varchar](20) NULL,
  [LineCodeName] [varchar](200) NULL,
  [LineCodeShortName] [varchar](20) NULL,
  [LineCodeShortNameEnum] [varchar](20) NULL,
  [LineCodeGroup] [varchar](50) NULL,
  [LineCodeSubGroup] [varchar](50) NULL,
  [LineCodeSegment] [varchar](50) NULL,
  [LineCodeValidCode] [char](1) NULL,
  [SrcSysLineCodeCode] [varchar](50) NULL,
  [SrcSysLineCodeName] [varchar](50) NULL,
  [DestSysLineCodeCode] [varchar](10) NULL,
  [AssetNorm] [varchar](10) NULL,
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
  PRIMARY KEY CLUSTERED ([LineCode_Key])
)
ON [PRIMARY]
GO