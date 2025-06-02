CREATE TABLE [DataUpload].[StockStatementDataUpload] (
  [Entitykey] [int] IDENTITY,
  [StockDataEntityId] [int] NULL,
  [CustomerAcID] [varchar](30) NULL,
  [CustomerID] [varchar](50) NULL,
  [ICRABorrowerId] [varchar](30) NULL,
  [CustomerName] [varchar](225) NULL,
  [StockStatementDate] [date] NULL,
  [StockValue] [decimal](18, 2) NULL,
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