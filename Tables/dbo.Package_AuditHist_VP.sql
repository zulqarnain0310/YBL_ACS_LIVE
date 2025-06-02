CREATE TABLE [dbo].[Package_AuditHist_VP] (
  [IdentityKey] [int] NOT NULL,
  [UserID] [varchar](50) NULL,
  [Execution_date] [date] NULL,
  [PackageName] [nvarchar](100) NOT NULL,
  [TableName] [nvarchar](100) NOT NULL,
  [ExecutionStartTime] [smalldatetime] NULL,
  [ExecutionEndTime] [smalldatetime] NULL,
  [TimeDuration_Min] [int] NULL,
  [ExecutionStatus] [nvarchar](10) NOT NULL,
  [ProcessingDate] [date] NULL,
  [timekey] [int] NULL
)
ON [PRIMARY]
GO