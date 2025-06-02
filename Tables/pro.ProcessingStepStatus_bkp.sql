CREATE TABLE [pro].[ProcessingStepStatus_bkp] (
  [id] [int] IDENTITY,
  [ProcessingStepName] [varchar](50) NULL,
  [Completed] [char](1) NULL,
  [ErrorDescription] [varchar](max) NULL,
  [ErrorDate] [date] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO