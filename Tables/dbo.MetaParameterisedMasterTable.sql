CREATE TABLE [dbo].[MetaParameterisedMasterTable] (
  [EntityKey] [int] IDENTITY,
  [SourceTableName] [nvarchar](50) NOT NULL,
  [XMLTableName] [varchar](50) NOT NULL,
  [ColumnSelect] [varchar](1000) NULL,
  [InnerJoin] [varchar](500) NULL,
  [WhereCondition] [varchar](200) NULL,
  [GroupBy] [varchar](200) NULL,
  [OrderBy] [varchar](100) NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [MetaEntityKey] [int] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [char](2) NULL,
  [D2Ktimestamp] [timestamp],
  [DateModified] [smalldatetime] NULL
)
ON [PRIMARY]
GO