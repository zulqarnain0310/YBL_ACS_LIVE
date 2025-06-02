CREATE TABLE [dbo].[VisionPlusENPAData] (
  [UCIF_ID] [varchar](50) NULL,
  [RefCustomerID] [varchar](50) NULL,
  [CustomerAcID] [varchar](50) NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [DPD_IntService] [varchar](50) NULL,
  [DPD_NoCredit] [varchar](50) NULL,
  [DPD_Overdrawn] [varchar](50) NULL,
  [DPD_Overdue] [varchar](50) NULL,
  [DPD_Renewal] [varchar](50) NULL,
  [DPD_StockStmt] [varchar](50) NULL,
  [DPD_Max] [varchar](50) NULL,
  [InitialAssetClassAlt_Key] [varchar](50) NULL,
  [FinalAssetClassAlt_Key] [varchar](50) NULL,
  [BankAssetClass] [varchar](50) NULL,
  [AccountStatus] [varchar](50) NULL,
  [AccountBlkCode1] [varchar](50) NULL,
  [AccountBlkCode2] [varchar](50) NULL,
  [cd] [varchar](50) NULL
)
ON [PRIMARY]
GO