﻿CREATE TABLE [dbo].[DimUserParameters] (
  [EntityKey] [smallint] IDENTITY NOT FOR REPLICATION,
  [SeqNo] [smallint] NOT NULL,
  [ParameterType] [varchar](500) NULL,
  [ShortNameEnum] [varchar](20) NOT NULL,
  [ParameterValue] [int] NULL,
  [MinValue] [smallint] NULL,
  [MaxValue] [smallint] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO