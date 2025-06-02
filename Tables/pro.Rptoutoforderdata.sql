CREATE TABLE [pro].[Rptoutoforderdata] (
  [PANNO] [varchar](12) SPARSE NULL,
  [UCIF_ID] [varchar](50) NULL,
  [RefCustomerID] [varchar](50) NULL,
  [CustomerName] [varchar](225) SPARSE NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [CustomerAcID] [varchar](30) SPARSE NULL,
  [CustSegmentCode] [varchar](10) SPARSE NULL,
  [ProductCode] [varchar](20) NULL,
  [ProductName] [varchar](200) NULL,
  [Balance] [decimal](16, 2) SPARSE NULL,
  [DPD_IntService] [int] SPARSE NULL,
  [GRTR_THAN_90] [decimal](16, 2) SPARSE NULL,
  [DAYS_61_TO_90] [decimal](16, 2) SPARSE NULL,
  [DAYS_31_TO_60] [decimal](16, 2) SPARSE NULL,
  [UPTO_30] [decimal](16, 2) SPARSE NULL,
  [OverdueAmt] [decimal](16, 2) SPARSE NULL,
  [BranchCode] [varchar](20) NULL,
  [BranchName] [varchar](50) NULL,
  [SourceName] [varchar](50) NULL,
  [TIMEKEY] [int] NULL
)
ON [PRIMARY]
GO