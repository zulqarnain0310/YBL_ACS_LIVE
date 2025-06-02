CREATE TABLE [dbo].[FactBranch_Moc] (
  [BranchCode] [varchar](10) NULL,
  [TimeKey] [smallint] NULL,
  [UnderAudit] [char](1) NULL,
  [BO_MOC_Frozen] [char](1) NULL,
  [BO_MOC_FreezingDate] [smalldatetime] NULL,
  [BO_MOC_FreezingBy] [varchar](20) NULL,
  [RO_MOC_Frozen] [char](1) NULL,
  [RO_MOC_FreezingDate] [smalldatetime] NULL,
  [RO_MOC_FreezingBy] [varchar](20) NULL,
  [ZO_MOC_Frozen] [char](1) NULL,
  [ZO_MOC_FreezingDate] [smalldatetime] NULL,
  [ZO_MOC_FreezingBy] [varchar](20) NULL
)
ON [PRIMARY]
GO