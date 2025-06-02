CREATE TABLE [dbo].[DimSecurityChargeType] (
  [SecurityChargeType_Key] [smallint] NOT NULL,
  [SecurityChargeTypeAlt_Key] [smallint] NULL,
  [SecurityChargeTypeCode] [varchar](10) NULL,
  [SecurityChargeTypeName] [varchar](100) NULL,
  [SecurityChargeTypeShortName] [varchar](20) NULL,
  [SecurityChargeTypeShortNameEnum] [varchar](20) NULL,
  [SecurityChargeTypeGroup] [varchar](20) NULL,
  [SecurityChargeTypeSubGroup] [varchar](20) NULL,
  [SecurityChargeTypeSegment] [varchar](50) NULL,
  [SecurityChargeTypeValidCode] [char](1) NULL,
  [SrcSysSecurityChargeTypeCode] [varchar](50) NULL,
  [SrcSysSecurityChargeTypeName] [varchar](50) NULL,
  [DestSysSecurityChargeTypeCode] [varchar](10) NULL,
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