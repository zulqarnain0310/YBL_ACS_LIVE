CREATE TABLE [pro].[OverDueBucketDisb] (
  [Ac_Key] [int] IDENTITY,
  [AccountEntityID] [int] NULL,
  [CustomerAcid] [nvarchar](30) NULL,
  [DueDate] [date] NULL,
  [PrincOverdue] [decimal](18, 2) NULL,
  [IntOverdue] [decimal](18, 2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO