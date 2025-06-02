CREATE TABLE [dbo].[ControlScripts] (
  [EntityKey] [int] IDENTITY,
  [UCIF_ID] [varchar](50) NULL,
  [PANNO] [varchar](12) NULL,
  [CustomerAcID] [varchar](30) NULL,
  [RefCustomerID] [varchar](50) NULL,
  [SourceSystemCustomerID] [varchar](50) NULL,
  [CustomerName] [varchar](225) NULL,
  [SourceName] [varchar](20) NULL,
  [DPD_Max] [int] NULL,
  [POS] [decimal](16, 2) NULL,
  [BalanceInCrncy] [decimal](16, 2) NULL,
  [Balance] [decimal](16, 2) NULL,
  [SysNPA_Dt] [varchar](20) NULL,
  [FinalAssetClassName] [varchar](20) NULL,
  [ExceptionCode] [smallint] NULL,
  [ExceptionDescription] [varchar](200) NULL,
  [DPDPreviousDay] [int] NULL,
  [DPDCurrentDay] [int] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO