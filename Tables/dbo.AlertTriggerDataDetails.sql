CREATE TABLE [dbo].[AlertTriggerDataDetails] (
  [EntityKey] [int] IDENTITY,
  [AlertNameAlt_Key] [int] NULL,
  [AlertDate] [datetime] NULL,
  [Borrower_PAN] [varchar](12) NULL,
  [UCIC_ID] [varchar](20) NULL,
  [Customer_ID] [varchar](20) NULL,
  [Borrower_Name] [varchar](100) NULL,
  [Name_of_reporting_Bank] [varchar](100) NULL,
  [Banking_arrangement] [varchar](200) NULL,
  [Name_of_lead_bank] [varchar](100) NULL,
  [Risk_Review_Timeline] [datetime] NULL,
  [Revised_RP_deadline_to_track_reversal_of_provisions] [datetime] NULL,
  [Implementation_Status] [varchar](100) NULL,
  [RP_Implementation_Deadline] [datetime] NULL,
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