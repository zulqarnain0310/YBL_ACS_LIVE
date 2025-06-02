CREATE TABLE [dbo].[MetaDynamicGrid] (
  [EntityKey] [int] NOT NULL,
  [ControlId] [int] NULL,
  [Label] [varchar](50) NULL,
  [EnableColumnMenu] [bit] NULL,
  [HeaderToolTip] [varchar](20) NULL,
  [EnableColumnResizing] [bit] NULL,
  [Width] [smallint] NULL,
  [CellTemplate] [varchar](100) NULL,
  [visible] [bit] NULL CONSTRAINT [DF__MetaDynam__visib__2B34E633] DEFAULT ('1')
)
ON [PRIMARY]
GO