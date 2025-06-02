SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [pro].[ProcessMonitor] (
  [IdentityKey] [int] IDENTITY,
  [UserID] [varchar](50) NULL,
  [Description] [varchar](100) NULL,
  [Mode] [varchar](15) NULL,
  [StartTime] [datetime] NULL,
  [EndTime] [datetime] NULL,
  [TimeTaken_Sec] AS (datediff(second,[StartTime],[EndTime])) PERSISTED,
  [TimeKey] [int] NULL,
  [SetID] [int] NULL,
  [Proc_Loc] [varchar](50) NULL,
  [StatusFlag] [varchar](100) NULL,
  PRIMARY KEY CLUSTERED ([IdentityKey])
)
ON [PRIMARY]
GO