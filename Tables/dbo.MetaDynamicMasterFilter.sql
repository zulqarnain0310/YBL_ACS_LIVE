CREATE TABLE [dbo].[MetaDynamicMasterFilter] (
  [EntityKey] [smallint] IDENTITY,
  [MasterFilterGrpKey] [smallint] NOT NULL,
  [MasterFilterKey] [smallint] NOT NULL,
  [ControlID] [int] NOT NULL,
  [FilterMasterControlName] [varchar](50) NOT NULL,
  [RefColumnName] [varchar](50) NULL,
  [FilterByColumnName] [varchar](50) NULL,
  [FilterBySelectValue] [varchar](100) NULL,
  [FilterByRemoveValue] [varchar](100) NULL,
  [MenuID] [smallint] NULL,
  [ExpectedValue] [varchar](50) NULL
)
ON [PRIMARY]
GO