CREATE TABLE [dbo].[DimAcCategory] (
  [AcCategory_Key] [smallint] NOT NULL,
  [AcCategoryAlt_key] [varchar](10) NOT NULL,
  [AcCategoryName] [varchar](100) NULL,
  [AcCategoryShortName] [varchar](20) NULL,
  [AcCategoryShortNameEnum] [varchar](20) NULL,
  [AcCategoryGroup] [varchar](50) NULL,
  [AcCategorySubGroup] [varchar](50) NULL,
  [AcCategorySegment] [varchar](50) NULL,
  [AcCategoryValidCode] [char](1) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp] NULL,
  [DestSysAreaTXN_Code] [varchar](10) NULL,
  [DestSysAreaTXN_Name] [varchar](50) NULL
)
ON [PRIMARY]
GO