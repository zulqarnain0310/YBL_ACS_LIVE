CREATE TABLE [dbo].[MetaDynamicMaster] (
  [Entitykey] [smallint] IDENTITY,
  [ControlID] [int] NULL,
  [MasterTable] [varchar](50) NULL,
  [MasterColumnName] [varchar](50) NULL,
  [DisplayColumnName] [varchar](50) NULL,
  [Condition] [varchar](200) NULL,
  [CodeColumn] [varchar](50) NULL,
  [NameColumn] [varchar](50) NULL
)
ON [PRIMARY]
GO