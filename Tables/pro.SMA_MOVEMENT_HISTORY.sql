CREATE TABLE [pro].[SMA_MOVEMENT_HISTORY] (
  [TIMEKEY] [int] NULL,
  [CustomerAcID] [varchar](30) NULL,
  [PrevStatus] [char](1) NULL,
  [CurrentStatus] [char](1) NULL,
  [PrevStatusDt] [date] NULL
)
ON [PRIMARY]
GO