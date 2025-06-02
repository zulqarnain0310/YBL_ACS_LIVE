CREATE TABLE [dbo].[DimCommercialFlag] (
  [CommercialFlag_Key] [smallint] IDENTITY,
  [CommercialFlagAlt_Key] AS ([CommercialFlag_Key]),
  [CommercialFlagCode] [varchar](20) NULL,
  [CommercialFlagName] [varchar](200) NULL,
  [CommercialFlagShortName] [varchar](20) NULL,
  [CommercialFlagShortNameEnum] [varchar](20) NULL,
  [CommercialFlagGroup] [varchar](50) NULL,
  [CommercialFlagSubGroup] [varchar](50) NULL,
  [CommercialFlagSegment] [varchar](50) NULL,
  [SrcSysCommercialFlagCode] [varchar](10) NULL,
  [SrcSysCommercialFlagName] [varchar](50) NULL,
  [DestSysCommercialFlagCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  PRIMARY KEY CLUSTERED ([CommercialFlag_Key])
)
ON [PRIMARY]
GO