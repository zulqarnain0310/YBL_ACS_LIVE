CREATE TABLE [dbo].[DimBankingArrangement_Mod] (
  [EntityKey] [int] IDENTITY,
  [BankingArrangementAlt_Key] [smallint] NULL,
  [ArrangementDescription] [varchar](200) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [ChangeFields] [varchar](100) NULL,
  [Remarks] [varchar](100) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL
)
ON [PRIMARY]
GO