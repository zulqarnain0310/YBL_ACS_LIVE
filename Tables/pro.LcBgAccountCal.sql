CREATE TABLE [pro].[LcBgAccountCal] (
  [EntityKey] [int] IDENTITY,
  [CustomerAcID] [varchar](30) SPARSE NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [AccountOpenDate] [date] NULL,
  [OverDueSinceDt] [date] SPARSE NULL,
  [AccountStatus] [varchar](10) NULL,
  [CustStatus] [varchar](10) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AccountCloseDate] [date] NULL,
  [CustomerCloseDate] [date] NULL,
  [Remark] [varchar](50) NULL
)
ON [PRIMARY]
GO