CREATE TABLE [CURDAT].[AdvSecurityDetailFdBacked] (
  [EntityKey] [bigint] IDENTITY,
  [UCIF_ID] [varchar](50) NULL,
  [Security_RefNo] [varchar](50) NULL,
  [CollateralID] [varchar](50) NULL,
  [SecurityParticular] [varchar](1000) NULL,
  [ValuationDate] [datetime] NULL,
  [ValueAtSanctionTime] [decimal](16, 2) NULL,
  [ValuationExpiryDate] [datetime] NULL,
  [CurrentValue] [decimal](16, 2) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NULL,
  [SourceCurrencycode] [varchar](10) NULL,
  [CurrencyAlt_Key] [int] NULL,
  [CurrencyValue] [decimal](18, 2) NULL
)
ON [PRIMARY]
GO