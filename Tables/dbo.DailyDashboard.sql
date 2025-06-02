CREATE TABLE [dbo].[DailyDashboard] (
  [DateofData] [date] NULL,
  [SourceName] [varchar](50) NULL,
  [AssetClass] [varchar](50) NULL,
  [ENPACount] [int] NULL,
  [ENPAPOS] [decimal](18, 2) NULL,
  [SourceCount] [int] NULL,
  [SourcePOS] [decimal](18, 2) NULL,
  [MismatchCount] [int] NULL,
  [MismatchPOS] [decimal](18, 2) NULL,
  [EffectiveFromTimekey] [int] NULL
)
ON [PRIMARY]
GO