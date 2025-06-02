CREATE TABLE [dbo].[LineCodeMaster_stg] (
  [Entity_Key] [int] IDENTITY,
  [SLNO] [varchar](max) NULL,
  [SOURCESYSTEM] [varchar](max) NULL,
  [CODEVALUE] [varchar](max) NULL,
  [CODETYPE] [varchar](max) NULL,
  [CODEDESCRIPTION] [varchar](max) NULL,
  [sheetname] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO