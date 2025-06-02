CREATE TABLE [dbo].[DimDefaultReason] (
  [NPAReasonKey] [smallint] NOT NULL,
  [NPAReasonKeyAlt_Key] [varchar](10) NOT NULL,
  [NPAReasonName] [varchar](150) NULL,
  [NPAReasonShortName] [varchar](50) NULL,
  [NPAReasonShortNameEnum] [varchar](50) NULL,
  [NPAReasonGroup] [varchar](20) NULL,
  [NPAReasonSubGroup] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [RecordStatus] [char](1) NOT NULL,
  [DateCreated] [smalldatetime] NULL,
  [DateModified] [smalldatetime] NULL,
  [CreatedBy] [varchar](8) NULL,
  [ApprovedBy] [varchar](8) NULL
)
ON [PRIMARY]
GO