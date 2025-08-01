﻿CREATE TABLE [dbo].[COBORROWER_DATA] (
  [APPLID] [nvarchar](300) NULL,
  [AGREEMENTNO] [nvarchar](30) NULL,
  [FLAG] [char](1) NULL,
  [CO_APPLICANT_FIN_CUST_ID] [nvarchar](30) NULL,
  [CO_APPLICANT_FCR_CUST_ID] [nvarchar](45) NULL,
  [CO_APPLICANT_UCIC] [nvarchar](360) NULL,
  [CO_APPLICANT_NAME] [nvarchar](300) NULL,
  [APPLICANT_FIN_CUST_ID] [nvarchar](300) NULL,
  [APPLICANT_FCR_CUST_ID] [nvarchar](45) NULL,
  [APPLICANT_UCIC] [nvarchar](360) NULL,
  [APPLICANT_NAME] [nvarchar](300) NULL,
  [ETL_DATE] [date] NULL
)
ON [PRIMARY]
GO