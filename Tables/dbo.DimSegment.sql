CREATE TABLE [dbo].[DimSegment] (
  [Segment_Key] [smallint] IDENTITY,
  [SegmentAlt_Key] [smallint] NOT NULL,
  [SegmentName] [varchar](50) NULL,
  [SegmentShortName] [varchar](20) NULL,
  [SegmentShortNameEnum] [varchar](20) NULL,
  [SegmentGroup] [varchar](50) NULL,
  [SegmentSubGroup] [varchar](50) NULL,
  [SegmentValidCode] [char](1) NULL,
  [SegmentOrder] [smallint] NULL,
  [Green] [smallint] NULL,
  [Amber] [smallint] NULL,
  [Red] [smallint] NULL,
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