CREATE TABLE [dbo].[StockStatement] (
  [icra_borr_id] [varchar](500) NULL,
  [pdts_id] [varchar](500) NULL,
  [b_segment] [varchar](500) NULL,
  [customer_name] [varchar](max) NULL,
  [rm_name] [varchar](max) NULL,
  [type_of_covenant] [varchar](max) NULL,
  [covenant_desc] [varchar](max) NULL,
  [approving_authority] [varchar](5000) NULL,
  [due_date] [varchar](50) NULL,
  [remarks] [varchar](5000) NULL,
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