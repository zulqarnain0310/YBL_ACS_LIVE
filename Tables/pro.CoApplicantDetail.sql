CREATE TABLE [pro].[CoApplicantDetail] (
  [EntityKey] [int] IDENTITY,
  [RefCustomerID] [varchar](20) NULL,
  [CustomerAcid] [varchar](20) NULL,
  [JointBorFlg] [varchar](10) NULL,
  [EffectiveFromTimekey] [int] NULL,
  [EffectiveToTimekey] [int] NULL,
  PRIMARY KEY CLUSTERED ([EntityKey])
)
ON [PRIMARY]
GO