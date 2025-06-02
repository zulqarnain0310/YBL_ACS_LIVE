CREATE TABLE [dbo].[DimAssetsNature] (
  [AssetsNature_Key] [smallint] IDENTITY,
  [AssetsNatureAlt_Key] [smallint] NOT NULL,
  [AssetsNatureName] [varchar](50) NULL,
  [AssetsNatureShortName] [varchar](20) NULL,
  [AssetsNatureShortNameEnum] [varchar](20) NULL,
  [AssetsNatureGroup] [varchar](50) NULL,
  [AssetsNatureGroupOrderKey] [tinyint] NULL,
  [AssetsNatureSubGroup] [varchar](50) NULL,
  [AssetsNatureSubGroupOrderKey] [tinyint] NULL,
  [AssetsNatureSegment] [varchar](50) NULL,
  [AssetsNatureValidCode] [char](1) NULL,
  [SrcSysClassName] [varchar](10) NULL,
  [SrcSysClassCode] [varchar](10) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [DateCreated] [smalldatetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [D2Ktimestamp] [timestamp] NULL
)
ON [PRIMARY]
GO