SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[Rpt-20027]
      @TimeKey AS INT,
	  @ExceptionCode AS VARCHAR(500),
	  @Cost    AS FLOAT
AS


--DECLARE 
--      @TimeKey AS INT =25383,
--	  @ExceptionCode AS VARCHAR(500)='11',
--	  @Cost    AS FLOAT=1


SELECT 
SourceName, 
UCIF_ID,
RefCustomerID,
CustomerName,
PANNO,
CustomerAcID,
ISNULL(DPD_Max,0)                      AS DPD_Max,
DPDPreviousDay,
DPDCurrentDay,
ISNULL(POS,0)/@Cost                    AS POS,
CONVERT(VARCHAR(20),SysNPA_Dt,103)     AS SysNPA_Dt,
FinalAssetClassName,
ExceptionCode,
ExceptionDescription

FROM ControlScripts
              
WHERE EffectiveFromTimeKey<=@Timekey AND  EffectiveToTimeKey>=@Timekey AND ExceptionCode IN (SELECT * FROM[Split](@ExceptionCode,','))

GO