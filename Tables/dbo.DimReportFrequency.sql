CREATE TABLE [dbo].[DimReportFrequency] (
  [ReportFrequency_Key] [smallint] NOT NULL,
  [ReportFrequencyAlt_Key] [smallint] NOT NULL,
  [ReportFrequency_Name] [varchar](100) NULL,
  [ReportFrequencyShortNameEnum] [varchar](20) NULL,
  [ReportFrequencySubGroup] [varchar](50) NULL,
  [ReportFrequencyGroup] [varchar](50) NULL,
  [NoofDays] [smallint] NULL,
  [ReportingDay] [varchar](30) NULL,
  [EffectiveFromTimeKey] [smallint] NULL,
  [EffectiveToTimeKey] [smallint] NULL,
  [RecordStatus] [char](1) NOT NULL,
  [DateCreated] [smalldatetime] NULL,
  [DateModified] [smalldatetime] NULL,
  [CreatedBy] [varchar](8) NULL,
  [ApprovedBy] [varchar](8) NULL,
  [Remark] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO