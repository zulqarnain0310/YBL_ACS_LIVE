CREATE TABLE [pro].[CUSTOMERMASTER] (
  [CustomerEntityID] [int] IDENTITY,
  [SourceCustomerID] [varchar](30) NULL,
  [EffectiveFromTimekey] [int] NULL,
  [EffectiveToTimekey] [int] NULL
)
ON [PRIMARY]
GO