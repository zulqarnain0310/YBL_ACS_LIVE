CREATE TABLE [dbo].[DimAssetClass] (
  [AssetClass_Key] [smallint] NOT NULL,
  [AssetClassAlt_Key] [smallint] NOT NULL,
  [AssetClassSubGroupOrderKey] [tinyint] NULL,
  [AssetClassOrderKey] [tinyint] NULL,
  [AssetClassName] [varchar](50) NULL,
  [AssetClassShortName] [varchar](20) NULL,
  [AssetClassShortNameEnum] [varchar](20) NULL,
  [AssetClassGroup] [varchar](50) NULL,
  [AssetClassSubGroup] [varchar](50) NULL,
  [AssetClassSegment] [varchar](50) NULL,
  [AssetClassValidCode] [char](1) NULL,
  [CIBILAssetClass] [varchar](10) NULL,
  [SrcSysClassCode] [varchar](10) NULL,
  [SrcSysClassName] [varchar](50) NULL,
  [DestSysAssetClassCode] [varchar](10) NULL,
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