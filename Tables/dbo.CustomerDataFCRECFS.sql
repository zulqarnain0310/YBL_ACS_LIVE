CREATE TABLE [dbo].[CustomerDataFCRECFS] (
  [BranchCode] [varchar](50) NULL,
  [UCIC_ID] [varchar](50) NULL,
  [FCR_CustomerID] [varchar](50) NULL,
  [PAN] [nvarchar](50) NULL,
  [AadharCard] [nvarchar](50) NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [CustomerName] [nvarchar](100) NULL,
  [CustRevRenDate] [nvarchar](50) NULL,
  [CustomerBusinessSegment] [nvarchar](50) NULL,
  [AssetClass] [varchar](50) NULL,
  [CustomerNPA_Date] [nvarchar](50) NULL,
  [ParentCustomeID] [nvarchar](50) NULL,
  [SourceSystemName] [nvarchar](50) NULL,
  [IMAXID_CCube] [nvarchar](50) NULL,
  [DateOfData] [nvarchar](50) NULL,
  [Data_Date] [datetime2] NULL,
  [Etl_Date] [datetime2] NULL,
  [CustomerPartnerSegment] [nvarchar](50) NULL
)
ON [PRIMARY]
GO