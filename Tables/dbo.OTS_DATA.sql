CREATE TABLE [dbo].[OTS_DATA] (
  [SourceSystemName] [varchar](30) NULL,
  [FCR_CustomerID] [varchar](30) NULL,
  [AccountID] [varchar](30) NULL,
  [OTS_Settlement_Flag] [char](1) NULL,
  [OTS_Settlement_Date] [date] NULL,
  [ETL_Date] [date] NULL,
  [Data_date] [date] NULL,
  [EFFECTIVEFROMTIMEKEY] [int] NULL,
  [EFFECTIVETOTIMEKEY] [int] NULL
)
ON [PRIMARY]
GO