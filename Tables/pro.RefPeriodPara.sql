CREATE TABLE [pro].[RefPeriodPara] (
  [Rule_Key] [smallint] NOT NULL,
  [RuleAlt_Key] [smallint] NULL,
  [RuleType] [varchar](50) NULL,
  [BusinessRule] [varchar](1000) NULL,
  [BusienssRuleName] [varchar](1000) NULL,
  [ColumnName] [varchar](1000) NULL,
  [RefValue] [varchar](1000) NULL,
  [RefUnit] [varchar](1000) NULL,
  [LogicSql] [varchar](5000) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [SourceSystemAlt_Key] [int] NULL,
  [IRACParameter] [varchar](50) NULL,
  [Grade] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EntityKey] [int] IDENTITY,
  [DateModified] [smalldatetime] NULL
)
ON [PRIMARY]
GO