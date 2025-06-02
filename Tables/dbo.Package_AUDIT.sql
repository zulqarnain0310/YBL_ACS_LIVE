CREATE TABLE [dbo].[Package_AUDIT] (
  [IdentityKey] [int] NOT NULL,
  [UserID] [varchar](50) NULL,
  [Execution_date] [date] NULL,
  [PackageName] [nvarchar](100) NOT NULL,
  [TableName] [nvarchar](100) NOT NULL,
  [ExecutionStartTime] [smalldatetime] NULL,
  [ExecutionEndTime] [smalldatetime] NULL,
  [TimeDuration_Min] AS (datediff(minute,[ExecutionStartTime],[ExecutionEndTime])),
  [ExecutionStatus] [nvarchar](10) NOT NULL,
  [ProcessingDate] [date] NULL
)
ON [PRIMARY]
GO