CREATE TABLE [dbo].[C_Cube_Stock] (
  [ICRA_BORR_ID] [varchar](30) NULL,
  [PDTS_ID] [varchar](30) NULL,
  [SEG_ID] [int] NULL,
  [B_SEGMENT] [varchar](100) NULL,
  [CUSTOMER_NAME] [varchar](500) NULL,
  [RM_NAME] [varchar](500) NULL,
  [TYPE_OF_COVENANT] [varchar](100) NULL,
  [COVENANT_DESC] [varchar](max) NULL,
  [APPROVING_AUTHORITY] [varchar](500) NULL,
  [DUE_DATE] [date] NULL,
  [REMARKS] [varchar](max) NULL,
  [DEFF_DATE] [date] NULL,
  [DAYS_PAST_DUE_CRITERIA] [int] NULL,
  [DAYS_PAST_DUE] [int] NULL,
  [No_of_Days] [int] NULL,
  [Frequency] [varchar](20) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO