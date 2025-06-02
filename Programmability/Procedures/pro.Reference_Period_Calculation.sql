SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=========================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 18-11-2017
 DESCRIPTION : Calculation Reference Period WITH HELPOF REFPERIOD
 --EXEC [pro].[Reference_Period_Calculation] @TIMEKEY=25202 
=============================================*/
CREATE PROCEDURE [pro].[Reference_Period_Calculation] 
@TIMEKEY INT
AS
BEGIN
    SET NOCOUNT ON
  BEGIN TRY
	--declare @timekey int =49999
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
+' AND ProductCode NOT IN(''660'',''661'',''889'',''681'',''682'',''693'',''694'',''695'',''696'',''715'',''716'',''717'',''718'',''755'',''756'',''758'',''763'',''764'',''765'',''766'',''787'',''788'',''789'',''795'',''796'',''797'',''798'',''799'',''220'',''237'',''869'',''219'',''819'',''891'',''703'',''704'',''705'',''209'',''605'',''740'',''778'',''235'')'
WHERE BusinessRule='LookBackPeriodClass' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


--------1---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService=366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456'''
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


--------2---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2


--------3---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3


--------4---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

--------5---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

--------6---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

--------7---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

--------8---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

--------9---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

--------10---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

--------11---------------------------------
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11

update pro.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_Borrowertypemst B ON A.BORROWERTYPEID=B.BORROWERTYPEID WHERE A.BORROWERTYPEID=41'
WHERE BusinessRule='Other than Individuals OTC' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_Borrowertypemst B ON A.BORROWERTYPEID=B.BORROWERTYPEID WHERE A.BORROWERTYPEID=21'
WHERE BusinessRule='Other than Individuals' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_Borrowertypemst B ON A.BORROWERTYPEID=B.BORROWERTYPEID WHERE A.BORROWERTYPEID=22'
WHERE BusinessRule='Joint Liability Group-Member' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_Borrowertypemst B ON A.BORROWERTYPEID=B.BORROWERTYPEID WHERE A.BORROWERTYPEID=23'
WHERE BusinessRule='Joint Liability Group-Representative' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_Borrowertypemst B ON A.BORROWERTYPEID=B.BORROWERTYPEID WHERE A.BORROWERTYPEID=24'
WHERE BusinessRule='Individual Farmer' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 
 update pro.RefPeriod SET LogicSql='UPDATE D SET D.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' from YBL_ACS_MIS.DBO.AccountData A INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_hdr B ON A.ProductCode=B.ProductID INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_dtl C ON C.criteriaid=B.criteriaid inner join pro.AccountCal D ON A.AccountID=D.CustomerAcID WHERE npa_criteria_value=''90'' and SourceSystemName=''FINNONE'' AND C.npa_stageid=''NPA'''
WHERE BusinessRule='FINNONE90' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE D SET D.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' from YBL_ACS_MIS.DBO.AccountData A INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_hdr B ON A.ProductCode=B.ProductID INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_dtl C ON C.criteriaid=B.criteriaid inner join pro.AccountCal D ON A.AccountID=D.CustomerAcID WHERE npa_criteria_value=''91'' and SourceSystemName=''FINNONE'' AND C.npa_stageid=''NPA'''
WHERE BusinessRule='FINNONE91' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE D SET D.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' from YBL_ACS_MIS.DBO.AccountData A INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_hdr B ON A.ProductCode=B.ProductID INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_dtl C ON C.criteriaid=B.criteriaid inner join pro.AccountCal D ON A.AccountID=D.CustomerAcID WHERE npa_criteria_value=''365'' AND SourceSystemName=''FINNONE'' AND C.npa_stageid=''NPA'''
WHERE BusinessRule='FINNONE365' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE D SET D.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' from YBL_ACS_MIS.DBO.AccountData A INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_hdr B ON A.ProductCode=B.ProductID INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_dtl C ON C.criteriaid=B.criteriaid inner join pro.AccountCal D ON A.AccountID=D.CustomerAcID WHERE npa_criteria_value=''366'' AND SourceSystemName=''FINNONE'' AND C.npa_stageid=''NPA'''
WHERE BusinessRule='FINNONE366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

update pro.RefPeriod SET LogicSql='UPDATE D SET D.RefPeriodIntService='+CAST(RefValue AS varchar)+',RefPeriodNoCredit='+CAST(RefValue AS varchar)+',RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',RefPeriodOverdue='+CAST(RefValue AS varchar)+' from YBL_ACS_MIS.DBO.AccountData A INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_hdr B ON A.ProductCode=B.ProductID INNER JOIN YBL_ACS_MIS..ODS_RA_npa_criteria_dtl C ON C.criteriaid=B.criteriaid inner join pro.AccountCal D ON A.AccountID=D.CustomerAcID WHERE npa_criteria_value=''730'' AND SourceSystemName=''FINNONE'' AND C.npa_stageid=''NPA'''
WHERE BusinessRule='FINNONE730' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

/***************Below updates added by Pranay as discussed with Bank team*******mail dated*2023-05-02*****************************************/
UPDATE PRO.REFPERIOD SET LogicSql='UPDATE A SET RefPeriodOverdue='+CAST(RefValue AS varchar)
+' FROM PRO.AccountCal a INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND FLGLCBG=''Y'' AND SourceName IN(''FCR'' )'
WHERE BusinessRule IN ('FLGLCBG_FCR_91') AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

UPDATE PRO.REFPERIOD SET LogicSql='UPDATE A SET RefPeriodOverdue='+CAST(RefValue AS varchar)
+' FROM PRO.AccountCal a INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND FLGLCBG=''Y'' AND SourceName IN(''FCC'' )'
WHERE BusinessRule IN ('FLGLCBG_FCC_91') AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2


UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefperiodOverdue='+CAST(RefValue AS varchar)
+',RefperiodOverdrawn='+CAST(RefValue AS varchar)
+',RefPeriodnoCredit='+CAST(RefValue AS varchar)
+',RefperiodIntService='+CAST(RefValue AS varchar)
+' FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCR'' ) WHERE (ACCOUNTSTATUS LIKE ''%CROP LOAN (OTHER THAN PL%'' OR ACCOUNTSTATUS LIKE ''%CROP LOAN (PLANT N HORTI%'' OR ACCOUNTSTATUS LIKE ''%PRE AND POST-HARVEST ACT%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST HYPOTHEC%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST PLEDGE O%'' OR ACCOUNTSTATUS LIKE ''%PLANTATION/HORTICULTURE%'' OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_OTR THAN PL%'' OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_PLANT/HORTI%'' OR ACCOUNTSTATUS LIKE ''%365_DEVELOPMENTAL ACTIVI%'' OR ACCOUNTSTATUS LIKE ''%365_LAND DEVELOPMENT%'' OR ACCOUNTSTATUS LIKE ''%365_PLANTATION/HORTI%'')'

 WHERE BusinessRule IN('ACCOUNTSTATUS_FCR_366') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=1

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefperiodOverdue='+CAST(RefValue AS varchar)
+',RefperiodOverdrawn='+CAST(RefValue AS varchar)
+',RefPeriodnoCredit='+CAST(RefValue AS varchar)
+',RefperiodIntService='+CAST(RefValue AS varchar)+'FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCC'' ) WHERE (ACCOUNTSTATUS LIKE ''%CROP LOAN (OTHER THAN PL%'' OR ACCOUNTSTATUS LIKE ''%CROP LOAN (PLANT N HORTI%'' OR ACCOUNTSTATUS LIKE ''%PRE AND POST-HARVEST ACT%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST HYPOTHEC%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST PLEDGE O%'' OR ACCOUNTSTATUS LIKE ''%PLANTATION/HORTICULTURE%'' OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_OTR THAN PL%'' OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_PLANT/HORTI%'' OR ACCOUNTSTATUS LIKE ''%365_DEVELOPMENTAL ACTIVI%'' OR ACCOUNTSTATUS LIKE ''%365_LAND DEVELOPMENT%'' OR ACCOUNTSTATUS LIKE ''%365_PLANTATION/HORTI%'')'

 WHERE BusinessRule IN('ACCOUNTSTATUS_FCC_366') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=2

 
UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefPeriodSTKstatement='+CAST(RefValue AS varchar)
+',RefPeriodReview='+CAST(RefValue AS varchar)+' FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCR'' ) WHERE (ACCOUNTSTATUS LIKE ''%CROP LOAN (OTHER THAN PL%'' OR ACCOUNTSTATUS LIKE ''%CROP LOAN (PLANT N HORTI%'' OR ACCOUNTSTATUS LIKE ''%PRE AND POST-HARVEST ACT%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST HYPOTHEC%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST PLEDGE O%'' OR ACCOUNTSTATUS LIKE ''%PLANTATION/HORTICULTURE%''	OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_OTR THAN PL%'' OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_PLANT/HORTI%''	OR ACCOUNTSTATUS LIKE ''%365_DEVELOPMENTAL ACTIVI%'' OR ACCOUNTSTATUS LIKE ''%365_LAND DEVELOPMENT%'' OR ACCOUNTSTATUS LIKE ''%365_PLANTATION/HORTI%'')'

 WHERE BusinessRule IN('ACCOUNTSTATUS_FCR_181') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=1

 UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefPeriodSTKstatement='+CAST(RefValue AS varchar)
+',RefPeriodReview='+CAST(RefValue AS varchar)+'FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCC'' ) WHERE (ACCOUNTSTATUS LIKE ''%CROP LOAN (OTHER THAN PL%'' OR ACCOUNTSTATUS LIKE ''%CROP LOAN (PLANT N HORTI%'' OR ACCOUNTSTATUS LIKE ''%PRE AND POST-HARVEST ACT%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST HYPOTHEC%'' OR ACCOUNTSTATUS LIKE ''%FARMERS AGAINST PLEDGE O%'' OR ACCOUNTSTATUS LIKE ''%PLANTATION/HORTICULTURE%'' OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_OTR THAN PL%'' OR ACCOUNTSTATUS LIKE ''%365_CROP LOAN_PLANT/HORTI%''	OR ACCOUNTSTATUS LIKE ''%365_DEVELOPMENTAL ACTIVI%'' OR ACCOUNTSTATUS LIKE ''%365_LAND DEVELOPMENT%'' OR ACCOUNTSTATUS LIKE ''%365_PLANTATION/HORTI%'')'

 WHERE BusinessRule IN('ACCOUNTSTATUS_FCC_181') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=2

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefperiodOverdue='+CAST(RefValue AS varchar)
+',RefperiodOverdrawn='+CAST(RefValue AS varchar)
+',RefPeriodnoCredit='+CAST(RefValue AS varchar)
+',RefperiodIntService='+CAST(RefValue AS varchar)+' FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCR'' ) WHERE (LineCode LIKE ''%CROP_OD_F%'' or LineCode LIKE ''%CROP_DLOD%'' or LineCode LIKE ''%CROP_TL_F%'')'
 WHERE BusinessRule IN('LineCode_FCR_366') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=1

 UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefperiodOverdue='+CAST(RefValue AS varchar)
+',RefperiodOverdrawn='+CAST(RefValue AS varchar)
+',RefPeriodnoCredit='+CAST(RefValue AS varchar)
+',RefperiodIntService='+CAST(RefValue AS varchar)+' FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCC'' ) WHERE (LineCode LIKE ''%CROP_OD_F%'' or LineCode LIKE ''%CROP_DLOD%'' or LineCode LIKE ''%CROP_TL_F%'')'
 WHERE BusinessRule IN('LineCode_FCC_366') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=2


 UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefPeriodSTKstatement='+CAST(RefValue AS varchar)
+',RefPeriodReview='+CAST(RefValue AS varchar)+' FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCR'' ) WHERE (LineCode LIKE ''%CROP_OD_F%'' or LineCode LIKE ''%CROP_DLOD%'' or LineCode LIKE ''%CROP_TL_F%'')'
 WHERE BusinessRule IN('LineCode_FCR_181') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=1

 UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET RefPeriodSTKstatement='+CAST(RefValue AS varchar)
+',RefPeriodReview='+CAST(RefValue AS varchar)+' FROM PRO.AccountCal A INNER JOIN DimSourceDB b ON a.SourceAlt_Key=b.SourceAlt_Key AND SourceName IN(''FCC'') WHERE (LineCode LIKE ''%CROP_OD_F%'' or LineCode LIKE ''%CROP_DLOD%'' or LineCode LIKE ''%CROP_TL_F%'')'
 WHERE BusinessRule IN('LineCode_FCC_181') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
 AND SourceSystemAlt_Key=2

 


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodIntServiceUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodIntServiceUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodNoCreditUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodNoCreditUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

---
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

-----4----------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

------5---------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

------6---------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

--------7-------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7
-------8--------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

--------9-------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9
---------10------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

--------11-------------------------------------------------------------------
UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A 
WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key=
'++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
',A.RefPeriodIntService='+CAST(RefValue AS varchar)+
'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11



 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11


UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11



 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodIntService' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1



 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodNoCredit' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1



UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11





UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=2

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=3

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=4

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=5

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=6

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=7

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=8

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=9

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=10

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=11



--------12/*'SFIN' SmartFin  15102023*/---------------------------------

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+',A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService = 366 FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI366''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr366' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI456''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr456' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

UPDATE PRO.RefPeriod SET LogicSql='UPDATE A SET A.RefPeriodoverdue='+CAST(RefValue AS varchar)+' ,A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+' ,A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+' ,A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A INNER JOIN DimProduct B ON A.ProductAlt_Key=B.ProductAlt_Key and B.EffectiveFromTimeKey<='+cast(@TIMEKEY as varchar)+' AND B.EffectiveToTimeKey>='+cast(@TIMEKEY as varchar)+' AND B.ProductSubGroup=''AGRI731''' 
+' and SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodAgr731' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12


UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawnUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawnUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12


 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdueUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdueUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReviewUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReviewUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatementUpg='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatementUpg' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
',A.RefPeriodNoCredit='+CAST(RefValue AS varchar)+',A.RefPeriodIntService='+CAST(RefValue AS varchar)+'FROM PRO.ACCOUNTCAL A WHERE FACILITYTYPE IN (''BD'',''BP'',''PC'',''TL'',''DL'') and SourceAlt_Key='++CAST(SourceSystemAlt_Key AS CHAR(2))
where BusinessRule='FacilityType' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverdue='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverdue' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodOverDrawn='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodOverDrawn' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodStkStatement='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodStkStatement' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

 UPDATE PRO.RefPeriod SET LogicSql=' UPDATE A SET A.RefPeriodReview='+CAST(RefValue AS varchar)+
' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
WHERE BusinessRule='RefPeriodReview' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=12

--------12/*'SFIN' SmartFin  15102023*/---------------------------------

IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
DROP TABLE #TEMPTABLE

SELECT IDENTITY(INT,1,1) ID ,LOGICSQL INTO #TEMPTABLE FROM PRO.REFPERIOD 
WHERE (LOGICSQL IS NOT NULL AND LOGICSQL<>'') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY order by Rule_Key 

 
DECLARE @START INT=1 ,@TOTALCOUNT INT=(SELECT COUNT(1) FROM #TEMPTABLE)
DECLARE @RESULT VARCHAR(MAX)
WHILE(@START<=@TOTALCOUNT)
BEGIN
 SET @RESULT=(SELECT LOGICSQL FROM #TEMPTABLE WHERE ID=@START)
 EXEC (@RESULT)
 
 SET @START=@START+1

END

-----Change NPA identifcation of FCC system from 91 to 90 days as per mail dated 06-03-2020 from deemed NPA team(29-FEb-2020 Monthend observation)
--UPDATE A SET A.RefPeriodOverdue=90 FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key =2 
/********below hard-coded updates commented as we have added Business Rule in pro.RefPeriod*****changes done by pranay***mail dated*2023-05-02**************************/
--UPDATE A SET A.RefPeriodOverdue=91 FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key =2  --as discussed with pankaj_11/10/2022

-----Change NPA identifcation of of VISIONPLUS and GANASEVA 91 days as per mail dated 24-03-2020 
--UPDATE A SET A.RefPeriodOverdue=91 FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key in(4,10)

UPDATE A SET A.RefPeriodOverdue=91 FROM PRO.ACCOUNTCAL A WHERE isnull(RefPeriodOverdue,0)=0 -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
UPDATE A SET A.RefPeriodOverDrawn=91 FROM PRO.ACCOUNTCAL A WHERE isnull(RefPeriodOverDrawn,0)=0 -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
UPDATE A SET A.RefPeriodNoCredit=91 FROM PRO.ACCOUNTCAL A WHERE isnull(RefPeriodNoCredit,0)=0  -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Tushar 
UPDATE A SET A.RefPeriodIntService=91 FROM PRO.ACCOUNTCAL A WHERE isnull(RefPeriodIntService,0)=0 -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Tushar
UPDATE A SET A.RefPeriodStkStatement=181 FROM PRO.ACCOUNTCAL A WHERE isnull(RefPeriodStkStatement,0)=0 -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
UPDATE A SET A.RefPeriodReview=181 FROM PRO.ACCOUNTCAL A WHERE isnull(RefPeriodReview,0)=0 -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day


--UPDATE A SET 
-- A.RefPeriodOverDrawn  = 32677
--,A.RefPeriodNoCredit   = 32677
--,A.RefPeriodIntService  = 32677
----,A.RefPeriodStkStatement = 32677
----,A.RefPeriodReview    = 32677
--FROM PRO.ACCOUNTCAL A 
--WHERE FACILITYTYPE IN ('BD','BP','PC','TL','DL')


--------------------Change referecne period from 89 to 90 as per Mail dated 19-Feb-2020 from Deemeed NPA team

--UPDATE PRO.AccountCal SET RefPeriodOverdue=89 WHERE FLGLCBG='Y'

--UPDATE PRO.AccountCal SET RefPeriodOverdue=90 WHERE FLGLCBG='Y'

/********below hard-coded updates commented as we have added Business Rule in pro.RefPeriod*****changes done by pranay***mail dated*2023-05-02**************************/
--UPDATE PRO.AccountCal SET RefPeriodOverdue=91 WHERE FLGLCBG='Y'   --as discussed with pankaj_11/10/2022

--UPDATE A SET 
--A.REFPERIODOVERDUE=366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODOVERDRAWN  = 366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODNOCREDIT   = 366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODINTSERVICE  = 366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODSTKSTATEMENT = 181-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODREVIEW    = 181-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--FROM PRO.ACCOUNTCAL A 
-- WHERE (LineCode LIKE '%CROP_OD_F%' or LineCode LIKE '%CROP_DLOD%' or LineCode LIKE '%CROP_TL_F%')

-- UPDATE A SET 
-- A.REFPERIODOVERDUE=366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODOVERDRAWN  = 366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODNOCREDIT   = 366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODINTSERVICE  = 366-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODSTKSTATEMENT = 181-- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--,A.REFPERIODREVIEW    = 181 -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
--FROM PRO.ACCOUNTCAL A 
-- WHERE (ACCOUNTSTATUS LIKE '%CROP LOAN (OTHER THAN PL%' OR ACCOUNTSTATUS LIKE '%CROP LOAN (PLANT N HORTI%' OR ACCOUNTSTATUS LIKE '%PRE AND POST-HARVEST ACT%'
-- OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST HYPOTHEC%' OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST PLEDGE O%' OR ACCOUNTSTATUS LIKE '%PLANTATION/HORTICULTURE%'
-- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_OTR THAN PL%'
-- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_PLANT/HORTI%'
-- OR ACCOUNTSTATUS LIKE '%365_DEVELOPMENTAL ACTIVI%'
-- OR ACCOUNTSTATUS LIKE '%365_LAND DEVELOPMENT%'
-- OR ACCOUNTSTATUS LIKE '%365_PLANTATION/HORTI%'
-- )


DROP TABLE #TEMPTABLE

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Reference_Period_Calculation'
END TRY
BEGIN CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Reference_Period_Calculation'
END CATCH
 SET NOCOUNT OFF

END




GO