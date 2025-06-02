CREATE TABLE [pro].[EXTDATE_MISDB] (
  [ID] [int] IDENTITY,
  [StartDate] [date] NULL,
  [EndDate] [date] NULL,
  [TimeKey] [int] NULL,
  [Flg] [char](1) NULL,
  [LAST_EXTDATE] [date] NULL,
  PRIMARY KEY CLUSTERED ([ID])
)
ON [PRIMARY]
GO