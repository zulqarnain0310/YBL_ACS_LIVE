SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*=====================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE : 05-07-2018
MODIFY DATE : 05-07-2018
DESCRIPTION : Security Appropriation MARKING
EXEC pro.SecurityAppropriation  @TIMEKEY=26051
====================================*/
Create PROCEDURE [pro].[SecurityAppropriation]
@TimeKey INT 
WITH RECOMPILE
AS
  BEGIN
       SET  NOCOUNT ON
        BEGIN TRY
		    
		
       
                      
  -----------======================Fetching Security Data from  customer Table================-----------------                    
                                    
          
DELETE FROM SecurityDetails WHERE TIMEKEY =@TIMEKEY          
           
INSERT INTO SecurityDetails          
(          
UCIF_ID,          
TotalSecurity,          
TIMEKEY          
)          
SELECT           
UCIF_ID,          
SUM(ISNULL(CurntQtrRv,0))TotalSecurity,          
@TIMEKEY TIMEKEY          
FROM           
PRO.CUSTOMERCAL 
where  ISNULL(CurntQtrRv,0)>0  
 and( UCIF_ID IS NOT NULL AND UCIF_ID<>'0' ) 
 and SourceAlt_Key in(1,2,7)    --Added 24/01/2022 As per Bank Mail          
GROUP BY UCIF_ID            
                                
      /*TempTableForSecurity  being create */                      
                                 
IF OBJECT_ID('SECURITYDETAIL') IS NOT NULL                      
DROP  TABLE SECURITYDETAIL                      
                                 
SELECT UCIF_ID,SUM(ISNULL(TOTALSECURITY,0)) AS TOTALSECURITY INTO SECURITYDETAIL FROM SECURITYDETAILS                       
WHERE TIMEKEY =@TIMEKEY                     
GROUP BY UCIF_ID                      
                     
                                                  
UPDATE  PRO.ACCOUNTCAL SET ApprRV=0                            
                      
--------Security App For Retail security only for that Account--------
--UPDATE A set ApprRV=
--CASE WHEN  ((A.NETBALANCE/A.BALANCE)*A.SecurityValue)>A.NETBALANCE THEN A.NETBALANCE       
--ELSE ((A.NETBALANCE/A.BALANCE)*A.SecurityValue) END  from pro.AccountCal A  
--WHERE isnull(BALANCE,0)>0 and isnull(SecurityValue,0)>0 and SecApp='S'

--changed made by Promod sir 23-02-2023
UPDATE A set ApprRV=
CASE WHEN  (A.SecurityValue)>A.NETBALANCE THEN A.NETBALANCE       
ELSE (A.SecurityValue) END  from pro.AccountCal A  
WHERE isnull(BALANCE,0)>0 and isnull(SecurityValue,0)>0 and SecApp='S'
  
--------Security App For Corporate Collateral Security--------

;WITH CTE(UCIF_ID,TOTOSFUNDED)                    
AS                    
(                    
SELECT B.UCIF_ID,SUM(ISNULL(A.NETBALANCE,0)) TOTOSFUNDED
 FROM  PRO.ACCOUNTCAL A    INNER JOIN PRO.CUSTOMERCAL B
  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID      --Condition chnaged  24/01/2022 As per Bank Mail
   AND A.UCIF_ID=B.UCIF_ID                              
WHERE A.NETBALANCE>0  
AND A.SecApp='S'
AND A.FinalAssetClassAlt_Key in (2,3,4,5)  
AND isnull(SecurityValue,0)=0 
and A.SourceAlt_Key in(1,2,7)   --Added 24/01/2022 As per Bank Mail
AND A.FacilityType<>'NF'     
AND (
LineCode NOT like '%294ODAGFD%' AND LineCode  NOT like '%ODAG-FCNR%' AND LineCode NOT like '%IBUODAGFD%' AND
 LineCode NOT like '%226TLAGFD%'  AND LineCode NOT like '%FCYAG-DEP%'   AND LineCode NOT like '%LDAG-FCNR%' and   LineCode NOT like'%FD-EXCLE%' ---Added on 20240524
 )

GROUP BY B.UCIF_ID                  
)                                          
            
UPDATE D SET D.                                    
APPRRV=  ((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY)                                                           
FROM CTE A INNER JOIN PRO.CUSTOMERCAL B ON A.UCIF_ID=B.UCIF_ID                             
INNER JOIN SECURITYDETAIL C ON C.UCIF_ID=B.UCIF_ID                    
INNER JOIN   PRO.ACCOUNTCAL D ON   D.SourceSystemCustomerID=B.SourceSystemCustomerID 
AND D.UCIF_ID=B.UCIF_ID                
WHERE C.TOTALSECURITY>0
AND D.SECAPP='S'
AND isnull(SecurityValue,0)=0  
AND D.FINALASSETCLASSALT_KEY IN (2,3,4,5)
and D.SourceAlt_Key in(1,2,7)   --Added 24/01/2022 As per Bank Mail
AND D.FacilityType<>'NF'  

AND (
 LineCode NOT like '%294ODAGFD%' AND LineCode  NOT like '%ODAG-FCNR%' AND LineCode NOT like '%IBUODAGFD%' AND
 LineCode NOT like '%226TLAGFD%'  AND LineCode NOT like '%FCYAG-DEP%'   AND LineCode NOT like '%LDAG-FCNR%' and   LineCode NOT like'%FD-EXCLE%'  ---Added on 20240524
 )




----New Condition Added 10/03/2023 for FD BRD----



IF OBJECT_ID('TEMPDB..#FDCustomerSecurity') IS NOT NULL

  DROP TABLE #FDCustomerSecurity

SELECT   UCIF_ID,SUM(ISNULL(CurrentValue,0)) AS CurrentValue
INTO    #FDCustomerSecurity
FROM 	[CURDAT].[AdvSecurityDetailUcifLevel]
WHERE EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey > = @TimeKey
GROUP  BY UCIF_ID


ALTER TABLE  #FDCustomerSecurity ADD  UCICIDIDTOTALCOUNT INT 
ALTER TABLE  #FDCustomerSecurity ADD  UCICIDIDSECURITYVALUE DECIMAL (18,2) 

IF OBJECT_ID('TEMPDB..#UCICIDIDTOTALCOUNTFD') IS NOT NULL
  DROP TABLE #UCICIDIDTOTALCOUNTFD

SELECT COUNT(DISTINCT A.SourceSystemCustomerID) AS NUMBER, A.UCIF_ID 
INTO #UCICIDIDTOTALCOUNTFD
FROM PRO.CUSTOMERCAL  A
INNER JOIN PRO.AccountCal B  ON A.UCIF_ID=B.UCIF_ID AND B.SecApp='U' AND A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE A.UCIF_ID IS NOT NULL
and a.SourceAlt_Key in(1,2,7) AND (

  LineCode like '%294ODAGFD%' OR LineCode like '%ODAG-FCNR%' OR LineCode like '%IBUODAGFD%' OR
 LineCode like '%226TLAGFD%'  OR LineCode like '%FCYAG-DEP%'   OR LineCode like '%LDAG-FCNR%' OR    LineCode  like'%FD-EXCLE%'  ---Added on 20240524
 )
GROUP BY A.UCIF_ID



UPDATE A SET UCICIDIDTOTALCOUNT= NUMBER 
FROM #FDCustomerSecurity A
INNER JOIN #UCICIDIDTOTALCOUNTFD B ON A.UCIF_ID=B.UCIF_ID

UPDATE #FDCustomerSecurity SET UCICIDIDSECURITYVALUE=(ISNULL(CurrentValue,0)/UCICIDIDTOTALCOUNT)
WHERE UCICIDIDTOTALCOUNT>=1


update b set CurntQtrRv=ISNULL(a.UCICIDIDSECURITYVALUE,0)
from #FDCustomerSecurity a
inner join pro.customercal b
on a.UCIF_ID=b.UCIF_ID  and b.sourcealt_key in (1,2,7) AND ISNULL(CurntQtrRv,0)=0
AND ISNULL(a.UCICIDIDSECURITYVALUE,0)>0


UPDATE A SET SECAPP='S'
 FROM PRO.ACCOUNTCAL A
 INNER JOIN DIMSOURCEDB C
ON A.SOURCEALT_KEY=C.SOURCEALT_KEY
AND C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY
INNER JOIN PRO.CUSTOMERCAL B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID
 WHERE ISNULL(B.CURNTQTRRV,0)>0 AND A.SECAPP='U'
;WITH CTEFD(UCIF_ID,TOTOSFUNDED)                    
AS                    
(                    
SELECT B.UCIF_ID,SUM(ISNULL(A.NETBALANCE,0)) TOTOSFUNDED
 FROM  PRO.ACCOUNTCAL A    INNER JOIN PRO.CUSTOMERCAL B
  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID     
   AND A.UCIF_ID=B.UCIF_ID                              
WHERE A.NETBALANCE>0  
AND A.SecApp='S'
AND A.FinalAssetClassAlt_Key in (2,3,4,5)  
AND isnull(SecurityValue,0)=0 
and A.SourceAlt_Key in(1,2,7)   
AND A.FacilityType<>'NF'     
AND (
 
 LineCode  like '%294ODAGFD%' OR LineCode   like '%ODAG-FCNR%' OR LineCode  like '%IBUODAGFD%' OR
 LineCode  like '%226TLAGFD%'  OR LineCode  like '%FCYAG-DEP%'   OR LineCode  like '%LDAG-FCNR%' OR LineCode  like'%FD-EXCLE%' ---Added on 20240524
 )

GROUP BY B.UCIF_ID                  
)                                          
            
UPDATE D SET D.                                    
APPRRV=  ((D.NETBALANCE/A.TOTOSFUNDED)*C.CurrentValue)                                                           
FROM CTEFD A INNER JOIN PRO.CUSTOMERCAL B ON A.UCIF_ID=B.UCIF_ID                             
INNER JOIN #FDCustomerSecurity C ON C.UCIF_ID=B.UCIF_ID                    
INNER JOIN   PRO.ACCOUNTCAL D ON   D.SourceSystemCustomerID=B.SourceSystemCustomerID 
AND D.UCIF_ID=B.UCIF_ID                
WHERE C.CurrentValue>0
AND D.SECAPP='S'
AND isnull(SecurityValue,0)=0  
AND D.FINALASSETCLASSALT_KEY IN (2,3,4,5)
and D.SourceAlt_Key in(1,2,7) 
AND D.FacilityType<>'NF'  

AND (
 LineCode  like '%294ODAGFD%' OR LineCode   like '%ODAG-FCNR%' OR LineCode  like '%IBUODAGFD%' OR
 LineCode  like '%226TLAGFD%'  OR LineCode  like '%FCYAG-DEP%'   OR LineCode  like '%LDAG-FCNR%' OR LineCode  like'%FD-EXCLE%' ---Added on 20240524
 )


    




--update A SET ApprRV=Balance,SecApp='S' FROM PRO.ACCOUNTCAL A 
-- INNER JOIN DIMSOURCEDB B ON A.SOURCEALT_KEY=B.SOURCEALT_KEY
--AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
--WHERE  ISNULL(A.BALANCE,0)>0  AND B.SOURCENAME IN ('ECBF') AND  A.FinalAssetClassAlt_Key in (2,3,4,5)



DROP TABLE #FDCustomerSecurity
DROP TABLE #UCICIDIDTOTALCOUNTFD


UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

	WHERE RUNNINGPROCESSNAME='SecurityAppropriation'

END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

	WHERE RUNNINGPROCESSNAME='SecurityAppropriation'

END CATCH
   SET  NOCOUNT OFF
END










GO