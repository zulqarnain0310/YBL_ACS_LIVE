﻿CREATE TABLE [dbo].[AdvSecurityValueDetail_BKP_2025-04-10 13:55:26.3770000] (
  [ENTITYKEY] [bigint] NULL,
  [SecurityEntityID] [bigint] NOT NULL,
  [ValuationSourceAlt_Key] [smallint] NULL,
  [ValuationDate] [datetime] NULL,
  [CurrentValue] [decimal](16, 2) NULL,
  [ValuationExpiryDate] [datetime] NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NULL,
  [CurrentValueSource] [decimal](18, 2) NULL,
  [CollateralValueatthetimeoflastreviewinRs] [decimal](18, 2) NULL,
  [CollateralID] [varchar](30) NULL,
  [ExpiryBusinessRule] [varchar](100) NULL,
  [Periodinmonth] [int] NULL,
  [TotalSecurityMarOfPreviousFY] [decimal](16, 2) NULL,
  [DISBURSALDATE] [date] NULL
)
ON [PRIMARY]
GO