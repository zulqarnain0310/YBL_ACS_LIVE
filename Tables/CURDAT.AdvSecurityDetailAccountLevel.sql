CREATE TABLE [CURDAT].[AdvSecurityDetailAccountLevel] (
  [EntityKey] [bigint] IDENTITY,
  [CustomerAcID] [varchar](50) NULL,
  [RefCustomerID] [varchar](50) NULL,
  [Security_RefNo] [varchar](50) NULL,
  [CollateralID] [varchar](50) NULL,
  [SecurityDesc] [varchar](500) NULL,
  [ValuationDate] [date] NULL,
  [ValueAtSanctionTime] [decimal](18, 2) NULL,
  [ValuationExpiryDate] [date] NULL,
  [CurrentValue] [decimal](18, 2) NULL,
  [AuthorisationStatus] [varchar](1) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [date] NULL,
  [D2Ktimestamp] [datetime] NULL,
  [CurrencyAlt_Key] [int] NULL,
  [CurrentValueInCurrency] [decimal](18, 2) NULL,
  [Currencycode] [varchar](10) NULL,
  [OrgCurrentValueInCurrency] [decimal](18, 2) NULL
)
ON [PRIMARY]
GO