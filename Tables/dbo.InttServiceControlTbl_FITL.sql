CREATE TABLE [dbo].[InttServiceControlTbl_FITL] (
  [ProcessingDate] [date] NULL,
  [NewIntDmdCountSrc] [int] NULL,
  [NewIntDmdCountDest] [int] NULL,
  [TotalDmdCountToBeServiced] [int] NULL,
  [MinDmdCountToBeServiced] [int] NULL,
  [TotalDmdCountServiced] [int] NULL,
  [MinDmdCountServiced] [int] NULL,
  [MissingUCIF_ID] [varchar](max) NULL,
  [Tallied] [char](1) NULL,
  [StartTime] [datetime] NULL,
  [EndTime] [datetime] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO