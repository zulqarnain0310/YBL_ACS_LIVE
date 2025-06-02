SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


 /*
 CREATED BY     : BAIJAYANTI
 CREATED DATE   : 22/05/2019
 REPORT NAME    : UCIC PAN Mismatch As On
 */

 Create PROC [dbo].[Rpt-20016]
 @TimeKey AS INT,
 @Source AS VARCHAR(200),
 @Cost AS FLOAT
 AS 

 --DECLARE 

 --@TimeKey AS INT=25302,
 --@Source AS VARCHAR(200)='1,2,3',
 --@Cost AS FLOAT=1



 SELECT 
 SourceName,
 CCH.PANNO,
 CCH.UCIF_ID,
 CCH.CustomerName,                                   
SUM(ISNULL(Balance,0))/@Cost                             AS Customer_OS_AMT_LCY


 FROM PRO.CUSTOMERCAL_HIST CCH
INNER JOIN PRO.ACCOUNTCAL_HIST   ACH        ON CCH.SourceSystemCustomerID=ACH.SourceSystemCustomerID
                                               AND CCH.EffectiveFromTimeKey<= @TimeKey
											   AND CCH.EffectiveToTimeKey>=@TimeKey  
                                               AND ACH.EffectiveFromTimeKey<= @TimeKey
											   AND ACH.EffectiveToTimeKey>=@TimeKey  


INNER JOIN DimSourceDB DSDB                 ON DSDB.SourceAlt_Key=ACH.SourceAlt_Key
                                               AND DSDB.EffectiveFromTimeKey<= @TimeKey
											   AND DSDB.EffectiveToTimeKey>=@TimeKey 
										   										            										   
											   								               
WHERE  (DSDB.SourceAlt_Key IN (SELECT * FROM DBO.SPLIT(@Source,',')) OR @Source='0')
	 AND ISNULL(ACH.AccountStatus,'N')<>'Z'
GROUP BY 

 SourceName,
 CCH.PANNO,
 CCH.UCIF_ID,                 
 CCH.CustomerName                  

 OPTION(RECOMPILE)
GO