CREATE TABLE [dbo].[DimCollateralSubType] (
  [EntityKey] [int] IDENTITY,
  [CollateralSubTypeAltKey] [int] NULL,
  [CollateralTypeAltKey] [int] NULL,
  [CollateralSubTypeID] [varchar](20) NULL,
  [CollateralSubType] [varchar](20) NULL,
  [CollateralSubTypeDescription] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL
)
ON [PRIMARY]
GO