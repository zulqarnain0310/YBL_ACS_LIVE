CREATE TABLE [dbo].[MetaDynamicCallStaticSP] (
  [Entitykey] [smallint] IDENTITY,
  [ControlID] [int] NULL,
  [SPName] [varchar](200) NULL,
  [ClientSideParams] [varchar](1000) NULL,
  [ServerSideParams] [varchar](1000) NULL
)
ON [PRIMARY]
GO