CREATE TABLE [dbo].[RPT_CONSOL_EXCEPTION_StockStatement] (
  [icra_borr_id] [varchar](50) NULL,
  [pdts_id] [varchar](50) NULL,
  [b_segment] [varchar](5000) NULL,
  [customer_name] [varchar](5000) NULL,
  [rm_name] [varchar](5000) NULL,
  [type_of_covenant] [varchar](5000) NULL,
  [covenant_desc] [varchar](max) NULL,
  [approving_authority] [varchar](500) NULL,
  [due_date] [varchar](max) NULL,
  [remarks] [varchar](max) NULL,
  [deff_date] [varchar](50) NULL,
  [days_past_due] [varchar](50) NULL,
  [no_of_days] [varchar](50) NULL,
  [frequency] [varchar](50) NULL,
  [maker_date] [varchar](50) NULL,
  [checker_date] [varchar](50) NULL,
  [trans_datetime] [varchar](50) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO