CREATE TABLE [dbo].[DimAssetClassDPD] (
  [AssetClassDPD_Key] [smallint] IDENTITY,
  [DpdPlan] [int] NULL,
  [DpdNamePlan] [varchar](30) NULL,
  [DpdClassCriteria] [char](1) NULL,
  [DpdClassCriteriaDesc] [varchar](10) NULL,
  [DpdClassValues] [varchar](30) NULL,
  [DpdSrlNO] [int] NULL,
  [DpdValue] [int] NULL,
  [DpdMonth] [char](1) NULL,
  [DpdCRR] [int] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO