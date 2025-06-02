CREATE TABLE [dbo].[UcifidMaster] (
  [UCIFEntityID] [int] NULL,
  [UCIFID] [varchar](50) NULL,
  [EffectiveFromTimekey] [int] NOT NULL,
  [EffectiveToTimekey] [int] NOT NULL
)
ON [PRIMARY]
GO