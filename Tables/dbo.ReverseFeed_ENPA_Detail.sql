CREATE TABLE [dbo].[ReverseFeed_ENPA_Detail] (
  [SrNo] [int] NULL,
  [ATHEZ-D-ORG] [varchar](3) NULL,
  [ATHEZ-D-ACCT-NBR] [varchar](19) NULL,
  [ATHEZ-D-CARD-SEQ-NBR] [varchar](4) NULL,
  [ATHEZ-D-FILE-CODE] [varchar](2) NULL,
  [ATHEZ-D-FIELD-CODE] [varchar](4) NULL,
  [ATHEZ-D-FIELD-OCCURRENCE] [varchar](4) NULL,
  [ATHEZ-D-FIELD-LENGTH] [varchar](3) NULL,
  [ATHEZ-D-BEFORE-DATA] [varchar](60) NULL,
  [ATHEZ-D-AFTER-DATA] [varchar](60) NULL,
  [ATHEZ-D-SIGNON] [varchar](20) NULL,
  [FILLER] [varchar](11) NULL,
  [ATHEZ-D-PLAN-NBR] [varchar](5) NULL,
  [ATHEZ-D-REC-NBR] [varchar](3) NULL,
  [ATHEZ-D-REC-TYPE-KEY] [varchar](2) NULL,
  [DateofData] [date] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO