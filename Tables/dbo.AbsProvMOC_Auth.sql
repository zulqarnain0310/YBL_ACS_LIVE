CREATE TABLE [dbo].[AbsProvMOC_Auth] (
  [AccountEntityID] [varchar](30) NULL,
  [UCIF_ID] [varchar](30) NULL,
  [CustomerID] [varchar](30) NULL,
  [SourceSystemCustomerID] [varchar](30) NULL,
  [BranchCode] [varchar](30) NULL,
  [OriginalProvision] [varchar](30) NULL,
  [NetBalance] [varchar](30) NULL,
  [CustomerACID] [varchar](30) NULL,
  [ExistingProvision] [varchar](30) NULL,
  [AdditionalProvision] [varchar](30) NULL,
  [FinalProvision] [varchar](30) NULL,
  [MOCREASON] [varchar](500) NULL,
  [AbsProvMOCEntityId] [int] NULL,
  [MOC_DATE] [date] NULL,
  [UserId] [varchar](30) NULL
)
ON [PRIMARY]
GO