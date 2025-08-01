﻿CREATE TABLE [DataUpload].[SecurityDataUpload] (
  [Entitykey] [int] IDENTITY,
  [SecurityDataEntityId] [int] NULL,
  [UCIF_ID] [varchar](30) NULL,
  [CustomerID] [varchar](50) NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [CustomerName] [varchar](225) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [SecurityCode] [varchar](30) NULL,
  [SecurityDescription] [varchar](250) NULL,
  [SecurityName] [varchar](100) NULL,
  [SecurityType] [varchar](50) NULL,
  [CurrentValue] [decimal](18, 2) NULL,
  [ValuationDt] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [EffectiveNPADate] [date] NULL
)
ON [PRIMARY]
GO