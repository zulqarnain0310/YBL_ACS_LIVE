CREATE TABLE [dbo].[customerdata] (
  [BranchCode] [varchar](10) NULL,
  [UCIC_ID] [varchar](30) NULL,
  [FCR_CustomerID] [varchar](30) NULL,
  [PAN] [varchar](30) NULL,
  [AadharCard] [varchar](20) NULL,
  [SourceSystemCustomerID] [varchar](30) NULL,
  [CustomerName] [varchar](300) NULL,
  [CustRevRenDate] [date] NULL,
  [CustomerBusinessSegment] [varchar](100) NULL,
  [AssetClass] [varchar](20) NULL,
  [CustomerNPA_Date] [date] NULL,
  [ParentCustomeID] [varchar](30) NULL,
  [SourceSystemName] [varchar](10) NULL,
  [IMAXID_CCube] [varchar](100) NULL,
  [DateOfData] [date] NULL,
  [Data_Date] [date] NULL,
  [Etl_Date] [date] NULL
)
ON [PRIMARY]
GO