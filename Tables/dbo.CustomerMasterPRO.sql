CREATE TABLE [dbo].[CustomerMasterPRO] (
  [CustomerEntityID] [int] NOT NULL,
  [SourceCustomerID] [nvarchar](50) NOT NULL,
  [EffectiveFromTimekey] [int] NOT NULL,
  [EffectiveToTimekey] [int] NOT NULL
)
ON [PRIMARY]
GO