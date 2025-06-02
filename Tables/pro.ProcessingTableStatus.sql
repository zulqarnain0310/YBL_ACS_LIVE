CREATE TABLE [pro].[ProcessingTableStatus] (
  [TableName] [varchar](50) NULL,
  [CurrentTimekey] [int] NULL,
  [DateCreated] [datetime] NULL DEFAULT (getdate())
)
ON [PRIMARY]
GO