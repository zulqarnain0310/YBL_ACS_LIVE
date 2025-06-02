CREATE TABLE [dbo].[DimCurCovRate] (
  [Currency_Key] [int] IDENTITY,
  [CurrencyAlt_Key] [smallint] NOT NULL,
  [CurrencyCode] [varchar](10) NULL,
  [CurrencyName] [varchar](50) NULL,
  [ConvRate] [decimal](18, 8) NULL,
  [ConvDate] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO