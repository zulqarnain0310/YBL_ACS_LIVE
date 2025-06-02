CREATE TABLE [dbo].[ExcelUploadHistory] (
  [UniqueUploadID] [int] IDENTITY,
  [UploadedBy] [varchar](100) NULL,
  [DateofUpload] [datetime] NULL,
  [AuthorisationStatus] [varchar](20) NULL,
  [UploadType] [varchar](50) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO