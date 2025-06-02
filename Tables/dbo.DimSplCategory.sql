CREATE TABLE [dbo].[DimSplCategory] (
  [SplCat_Key] [smallint] NOT NULL,
  [SplCatAlt_Key] [smallint] NULL,
  [SplCatName] [varchar](50) NULL,
  [SplCatShortName] [varchar](20) NULL,
  [SplCatShortNameEnum] [varchar](20) NULL,
  [SplCatGroup] [varchar](50) NULL,
  [SplCatSubGroup] [varchar](50) NULL,
  [SplCatSegment] [varchar](50) NULL,
  [SplCatValidCode] [char](1) NULL,
  [AssetClass] [varchar](20) NULL,
  [Applicability] [varchar](20) NULL,
  [SrcSysSplCatCode] [varchar](50) NULL,
  [SrcSysSplCatName] [varchar](50) NULL,
  [DestSysSplCategoryCode] [varchar](10) NULL,
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