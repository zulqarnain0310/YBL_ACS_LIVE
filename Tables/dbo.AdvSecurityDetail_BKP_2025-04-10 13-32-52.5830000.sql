﻿CREATE TABLE [dbo].[AdvSecurityDetail_BKP_2025-04-10 13:32:52.5830000] (
  [ENTITYKEY] [bigint] NULL,
  [AccountEntityId] [int] NULL,
  [CustomerEntityId] [int] NULL,
  [SecurityType] [char](1) NULL,
  [CollateralType] [varchar](30) NULL,
  [SecurityAlt_Key] [smallint] NULL,
  [SecurityEntityID] [int] NOT NULL,
  [Security_RefNo] [varchar](20) NULL,
  [SecurityNature] [varchar](15) NULL,
  [SecurityChargeTypeAlt_Key] [int] NULL,
  [CurrencyAlt_Key] [smallint] NULL,
  [EntryType] [varchar](20) NULL,
  [ScrCrError] [varchar](100) NULL,
  [InwardNo] [smallint] NULL,
  [Limitnode_Flag] [char](1) NULL,
  [RefCustomerId] [varchar](50) NULL,
  [RefSystemAcId] [varchar](50) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NULL,
  [MocTypeAlt_Key] [int] NULL,
  [MocStatus] [varchar](1) NULL,
  [MocDate] [smalldatetime] NULL,
  [SecurityParticular] [varchar](1000) NULL,
  [OwnerTypeAlt_Key] [char](1) NULL,
  [AssetOwnerName] [varchar](200) NULL,
  [ValueAtSanctionTime] [decimal](16, 2) NULL,
  [BranchLastInspecDate] [date] NULL,
  [SatisfactionNo] [varchar](50) NULL,
  [SatisfactionDate] [date] NULL,
  [BankShare] [decimal](5, 2) NULL,
  [ActionTakenRemark] [varchar](1000) NULL,
  [SecCharge] [char](1) NULL,
  [CollateralID] [varchar](30) NULL,
  [UCICID] [varchar](50) NULL,
  [CustomerName] [varchar](200) NULL,
  [TaggingAlt_Key] [int] NULL,
  [DistributionAlt_Key] [int] NULL,
  [CollateralCode] [varchar](50) NULL,
  [CollateralSubTypeAlt_Key] [int] NULL,
  [CollateralOwnerShipTypeAlt_Key] [int] NULL,
  [ChargeNatureAlt_Key] [int] NULL,
  [ShareAvailabletoBankAlt_Key] [int] NULL,
  [CollateralShareamount] [decimal](18, 2) NULL,
  [IfPercentagevalue_or_Absolutevalue] [decimal](16, 2) NULL,
  [CollateralValueatSanctioninRs] [decimal](18, 2) NULL,
  [CollateralValueasonNPAdateinRs] [decimal](18, 2) NULL,
  [ApprovedByFirstLevel] [varchar](20) NULL,
  [DateApprovedFirstLevel] [smalldatetime] NULL,
  [ChangeField] [varchar](max) NULL,
  [LiabID] [varchar](100) NULL,
  [AssetID] [varchar](25) NULL,
  [Segment] [varchar](20) NULL,
  [CRE] [varchar](5) NULL,
  [CollateralSubTypeDescription] [varchar](500) NULL,
  [SeniorityofCharge] [varchar](50) NULL,
  [SecurityStatus] [varchar](25) NULL,
  [FDNo] [varchar](20) NULL,
  [ISINNo] [varchar](25) NULL,
  [FolioNo] [varchar](25) NULL,
  [QtyShares_MutualFunds_Bonds] [bigint] NULL,
  [Line_No] [varchar](300) NULL,
  [CrossCollateral_LiabID] [varchar](500) NULL,
  [NameSecuPvd] [varchar](500) NULL,
  [PropertyAdd] [varchar](2500) NULL,
  [PIN] [int] NULL,
  [DtStockAudit] [date] NULL,
  [SBLCIssuingBank] [varchar](100) NULL,
  [SBLCNumber] [varchar](25) NULL,
  [CurSBLCissued] [varchar](15) NULL,
  [SBLCFCY] [decimal](16, 2) NULL,
  [DtexpirySBLC] [date] NULL,
  [DtexpiryLIC] [date] NULL,
  [ModeOperation] [varchar](15) NULL,
  [ExceApproval] [varchar](15) NULL,
  [ValuationType] [varchar](200) NULL,
  [BusinessType] [varchar](200) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO