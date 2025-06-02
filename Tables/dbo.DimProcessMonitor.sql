CREATE TABLE [dbo].[DimProcessMonitor] (
  [Process_Key] [smallint] NOT NULL,
  [ProcessAlt_Key] [smallint] NULL,
  [ProcessName] [varchar](200) NULL,
  [ProcessShortName] [varchar](200) NULL,
  [ProcessShortNameEnum] [varchar](200) NULL,
  [ProcessGroup] [varchar](200) NULL,
  [ProcessSubGroup] [varchar](200) NULL,
  [ProcessSegment] [varchar](200) NULL,
  [ProcessDBName] [varchar](200) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [RecordStatus] [char](1) NOT NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NOT NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NOT NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO