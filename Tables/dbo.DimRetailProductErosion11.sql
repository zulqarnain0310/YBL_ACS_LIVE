CREATE TABLE [dbo].[DimRetailProductErosion11] (
  [Product_Key] [smallint] IDENTITY,
  [ProductCode] [varchar](20) NULL,
  [ProductName] [varchar](200) NULL,
  [SourceSystemName] [varchar](20) NULL,
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