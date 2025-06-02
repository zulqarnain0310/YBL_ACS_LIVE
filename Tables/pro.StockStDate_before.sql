CREATE TABLE [pro].[StockStDate_before] (
  [EntityKey] [int] IDENTITY,
  [ICRABorrowerID] [varchar](30) NULL,
  [PDTSID] [varchar](30) NULL,
  [SegmentID] [int] NULL,
  [Segment] [varchar](100) NULL,
  [CustomerName] [varchar](500) NULL,
  [RMName] [varchar](500) NULL,
  [CovenantType] [varchar](100) NULL,
  [CovenantDescription] [varchar](max) NULL,
  [DueDate] [date] NULL,
  [Remark] [varchar](max) NULL,
  [DeferralDate] [date] NULL,
  [DPDCriteria] [int] NULL,
  [DPD] [int] NULL,
  [NoofGraceDays] [int] NULL,
  [Frequency] [varchar](20) NULL,
  [ActualDueDate] [date] NULL,
  [ActualStockduedate] [date] NULL,
  [ActualStockDPD] [int] NULL,
  [Processingdate] [date] NULL,
  [Authority] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO