CREATE TABLE [dbo].[DimCurrency] (
  [Currency_Key] [smallint] NOT NULL,
  [CurrencyAlt_Key] [smallint] NOT NULL,
  [CurrencyCode] [varchar](10) NULL,
  [CurrencyNameOrderKey] [tinyint] NULL,
  [CurrencyName] [varchar](50) NULL,
  [CurrencyShortName] [varchar](20) NULL,
  [CurrencyShortNameEnum] [varchar](20) NULL,
  [CurrencyGroup] [varchar](50) NULL,
  [CurrencySubGroup] [varchar](50) NULL,
  [CurrencySegment] [varchar](50) NULL,
  [CurrencyValidCode] [char](1) NULL,
  [SrcSysCurrencyCode] [varchar](50) NULL,
  [SrcSysCurrencyName] [varchar](50) NULL,
  [DestSysturrencyCode] [varchar](10) NULL,
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
  [ApplicableForNewAc] [char](1) NULL
)
ON [PRIMARY]
GO