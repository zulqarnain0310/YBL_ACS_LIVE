CREATE TABLE [pro].[ChangedMocAclStatus] (
  [EntityKey] [int] NOT NULL,
  [RefCustomerID] [varchar](50) NULL,
  [CustomerEntityID] [int] NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [MOC_AssetClass_Alt_Key] [smallint] NULL,
  [Old_AssetClassAlt_Key] [smallint] NULL,
  [MocTypeAlt_Key] [smallint] NULL,
  [MocDate] [date] NULL,
  [UserID] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [date] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [date] NULL,
  [D2Ktimestamp] [timestamp],
  [AuthorisationStatus] [varchar](2) NULL
)
ON [PRIMARY]
GO