CREATE TABLE [dbo].[RP_Lender_Details] (
  [EntityKey] [int] IDENTITY,
  [CustomerID] [varchar](20) NULL,
  [ReportingLenderAlt_Key] [smallint] NULL,
  [InDefaultDate] [datetime] NULL,
  [OutOfDefaultDate] [datetime] NULL,
  [DefaultStatus] [varchar](30) NULL,
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