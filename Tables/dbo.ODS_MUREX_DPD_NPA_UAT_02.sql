CREATE TABLE [dbo].[ODS_MUREX_DPD_NPA_UAT_02] (
  [ContractOriginReference] [varchar](500) NULL,
  [TrnInternalTradeNo] [varchar](500) NULL,
  [PeriodExpiryDate] [varchar](500) NULL,
  [TranDate] [varchar](500) NULL,
  [Portfolio] [varchar](500) NULL,
  [InitialCapital1stLeg] [varchar](500) NULL,
  [CurrentCapital1stLeg] [varchar](500) NULL,
  [SecurityCode] [varchar](500) NULL,
  [SecurityCurrency] [varchar](500) NULL,
  [SecurityDisplayedLabel] [varchar](500) NULL,
  [SecurityIssuerCustomerName] [varchar](500) NULL,
  [SecurityLotSize] [varchar](500) NULL,
  [CounterpartLabel] [varchar](500) NULL,
  [NextPaymentDate1stLeg] [varchar](500) NULL,
  [NextPaymentDate2ndLeg] [varchar](500) NULL,
  [FCC_CustomerID] [varchar](500) NULL,
  [ExposureType] [varchar](500) NULL,
  [MTM_VALUE] [varchar](500) NULL,
  [DATE_OF_DATA] [varchar](500) NULL,
  [Match_FCR] [varchar](500) NULL,
  [CTP_NPA_FLAG] [varchar](500) NULL,
  [CTP_NPA_DATE] [varchar](500) NULL,
  [ISS_NPA_FLAG] [varchar](500) NULL,
  [ISS_NPA_DATE] [varchar](500) NULL
)
ON [PRIMARY]
GO