CREATE TABLE [dbo].[DimSourceDB] (
  [Source_Key] [smallint] NOT NULL,
  [SourceAlt_Key] [smallint] NULL,
  [SourceName] [varchar](50) NULL,
  [SourceShortName] [varchar](20) NULL,
  [SourceShortNameEnum] [varchar](20) NULL,
  [SourceGroup] [varchar](50) NULL,
  [SourceSubGroup] [varchar](50) NULL,
  [SourceSegment] [varchar](50) NULL,
  [SourceDBName] [varchar](100) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [RecordStatus] [char](1) NOT NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NOT NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NOT NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO