CREATE TABLE [dbo].[SysMasterTableVersion] (
  [TableVersionAlt_Key] [smallint] IDENTITY,
  [TableName] [varchar](50) NULL,
  [VersionNo] [int] NULL,
  [LastModifiedDate] [date] NULL
)
ON [PRIMARY]
GO