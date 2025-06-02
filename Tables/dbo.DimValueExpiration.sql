CREATE TABLE [dbo].[DimValueExpiration] (
  [EntityKey] [int] IDENTITY,
  [ValueExpirationAltKey] [int] NULL,
  [SecurityTypeAlt_Key] [int] NULL,
  [SecuritySubTypeAlt_Key] [int] NULL,
  [Documents] [varchar](50) NULL,
  [Validitycriteria] [varchar](500) NULL,
  [ExpirationPeriod] [int] NULL,
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