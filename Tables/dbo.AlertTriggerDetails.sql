CREATE TABLE [dbo].[AlertTriggerDetails] (
  [EntityKey] [int] IDENTITY,
  [Alert_Date] [datetime] NULL,
  [AlertNameAlt_Key] [int] NULL,
  [AlertScopeAlt_Key] [int] NULL,
  [AlertFrequencyAlt_Key] [int] NULL,
  [PrimaryRecipientEmailID] [varchar](1000) NULL,
  [SecondaryRecipientEmailID] [varchar](1000) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL
)
ON [PRIMARY]
GO