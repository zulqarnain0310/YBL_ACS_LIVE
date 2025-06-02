CREATE TABLE [dbo].[Outoforder_source] (
  [UCIC] [nvarchar](255) NULL,
  [COD_ACCT_NO] [nvarchar](255) NULL,
  [COD_CUST] [nvarchar](255) NULL,
  [COD_ACCT_TITLE] [nvarchar](255) NULL,
  [BAL_BOOK] [float] NULL,
  [AMT_OD_LIMIT] [float] NULL,
  [MAX_DPD_DAYS] [float] NULL,
  [BUSINESS_SEGMENT] [nvarchar](255) NULL,
  [TXT_ACCT_STATUS] [nvarchar](255) NULL,
  [LIAB_NO] [float] NULL
)
ON [PRIMARY]
GO