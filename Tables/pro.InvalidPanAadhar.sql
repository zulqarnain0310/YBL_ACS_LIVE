CREATE TABLE [pro].[InvalidPanAadhar] (
  [SrNO] [int] IDENTITY,
  [DateOfData] [date] NULL,
  [CustomerID] [varchar](50) NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [CustomerName] [varchar](300) NULL,
  [SourceSystemName] [varchar](50) NULL,
  [PanNo] [varchar](20) NULL,
  [AadharCard] [varchar](30) NULL,
  [EffectiveFromTimekey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO