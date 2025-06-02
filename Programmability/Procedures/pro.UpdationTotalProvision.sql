SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*==============================          
Author : SANJEEV KUMAR SHARMA   
CREATE DATE : 29-11-2018          
MODIFY DATE : 29-11-2018         
DESCRIPTION : UPDATE TOTAL PROVISION          
--EXEC [pro].[UpdationTotalProvision] @TimeKey =25410            
--=========================================*/                
Create PROCEDURE [pro].[UpdationTotalProvision]
@TimeKey int  --=26886 
with recompile               
AS              
  BEGIN              
   SET NOCOUNT ON;              
              
 BEGIN TRY              

 
DECLARE @PROCESSINGDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)
DECLARE @PROCESSDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)
	DECLARE @SUB_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)													
	DECLARE @DB1_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)													
	DECLARE @DB2_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)													


 -----CALCULATE ProvisionPer NEW FRAUD ACCOUNTS AND WHERE ProvisionPer IS NULL OR ZERO --- AMAR SIR,PRANAY 2022-12-06
 	UPDATE a SET ProvisionPer=(100-(((ISNULL(Provsecured,0)+ISNULL(ProvUnsecured,0))/ISNULL(NetBalance,0))*100))/4 -- 	(100-isnull(ProvisionSecured,0))/4
				 ,ProvisionAmtAtFraud=ISNULL(b.PROVSECURED,0)+ISNULL(b.PROVUNSECURED,0)  -- store provision amt at the time of fraud-- 2022-12-22 Pranay
                                 ,ProvisionAmtAtFraudPer=((ISNULL(b.PROVSECURED,0)+ISNULL(b.PROVUNSECURED,0))/ISNULL(NetBalance,0)) *100
	FROM FraudAccountsDetails a 
		INNER JOIN PRO.AccountCal b
	ON a.CustomerAcID=b.CustomerAcID
		WHERE ISNULL(A.ProvisionPer,0)=0  
		AND ISNULL(NetBalance,0)>0

Update a Set ProvisionPer=(((ISNULL(Provsecured,0)+ISNULL(ProvUnsecured,0))/ISNULL(NetBalance,0))*100)/4 --Provision Computation Revised for STD to Fraud Accounts After Observation Raised by bank and Discussion with Amar sir and Tushar , Changed by shubham on 2024-02-13
            ,ProvisionAmtAtFraud=0  
            ,ProvisionAmtAtFraudPer=0
FROM FraudAccountsDetails a 
	INNER JOIN PRO.AccountCal b
ON a.CustomerAcID=b.CustomerAcID
	WHERE ISNULL(A.ProvisionPer,0)=0  
	AND ISNULL(NetBalance,0)>0
	AND ISNULL(a.ActualAssetClassAlt_Key,1)=1 -- /*Changed by D2k 19FEB24 - Shubham -added */
	AND ISNULL(a.FinalAssetClassAlt_Key,1)=6
	--And CustomerEntityID = 5725108
	
	
	


 UPDATE  PRO.ACCOUNTCAL              
 SET TOTALPROVISION = 0  ,BANKTOTALPROVISION=0,RBITOTALPROVISION=0

 
 UPDATE  PRO.CUSTOMERCAL              
 SET TOTPROVISION = 0  ,BANKTOTPROVISION=0,RBITOTPROVISION=0
              
 UPDATE A                   
 SET  
	   TOTALPROVISION       =(ISNULL(A.PROVSECURED,0) + ISNULL(A.PROVUNSECURED,0)  + (ISNULL(A.ADDLPROVISION,0))+ ISNULL(A.PROVCOVERGOVGUR,0)+  ISNULL(A.PROVDFV,0)) 
      ,BANKTOTALPROVISION  =(ISNULL(A.BANKPROVSECURED,0) + ISNULL(A.BANKPROVUNSECURED,0)  + (ISNULL(A.ADDLPROVISION,0))+ ISNULL(A.PROVCOVERGOVGUR,0)+   ISNULL(A.PROVDFV,0)) 
	  ,RBITOTALPROVISION   =(ISNULL(A.RBIPROVSECURED,0) +  ISNULL(A.RBIPROVUNSECURED,0)  +  (ISNULL(A.ADDLPROVISION,0))+ ISNULL(A.PROVCOVERGOVGUR,0)+   ISNULL(A.PROVDFV,0))                                           
 FROM  PRO.ACCOUNTCAL    A             
 


 UPDATE A SET TOTALPROVISION=RBITOTALPROVISION,PROVSECURED=RBIPROVSECURED,PROVUNSECURED=RBIPROVUNSECURED,ADDLPROVISION=ADDLPROVISION,PROVCOVERGOVGUR=PROVCOVERGOVGUR,PROVDFV=PROVDFV
 FROM PRO.ACCOUNTCAL A  where ISNULL(A.RBITOTALPROVISION,0)>ISNULL(A.BANKTOTALPROVISION,0)
 
   UPDATE A SET TOTALPROVISION=BANKTOTALPROVISION,PROVSECURED=BANKPROVSECURED,PROVUNSECURED=BANKPROVUNSECURED,ADDLPROVISION=ADDLPROVISION,PROVCOVERGOVGUR=PROVCOVERGOVGUR,PROVDFV=PROVDFV
 FROM PRO.ACCOUNTCAL A  where ISNULL(A.BANKTOTALPROVISION,0)>ISNULL(A.RBITOTALPROVISION,0)

  -----------------fRAUD ACCOUNT RELATED CHANGES--------PRANAY & AMAR SIR 2022-12-03-----------------------------------------


  UPDATE B SET UsedFraudProvAmt= CASE WHEN A.TotalProvision>=NetBalance
										THEN 0
									WHEN  NetBalance>=((b.ProvisionAmtAtFraudPer * NetBalance)/100)+(isnull(NetBalance,0)*(ProvisionPer*QTR))/100 --- UPDATE FraudProvAmt applicable for the QTR
										THEN (isnull(NetBalance,0)*(ProvisionPer*QTR))/100
								ELSE NetBalance-TotalProvision
							end
				,FraudProvAmt=(isnull(NetBalance,0)*(ProvisionPer*QTR))/100
 FROM PRO.ACCOUNTCAL A	
  INNER JOIN FraudAccountsDetails B
  ON A.CustomerAcID=B.CustomerAcID 
  WHERE ISNULL(NetBalance,0)>0

----/**********TotalProvision for FRAUD Accounts will be calculated at the end of the Quarter ***changes done by Pranay****mail dated 2022-12-23*******/
IF( (month(@PROCESSINGDATE) in(3,12) and day(@PROCESSINGDATE)=31 ) 
       OR (month(@PROCESSINGDATE) in(6,9) and day(@PROCESSINGDATE)=30 ))

	BEGIN
			  UPDATE A SET --A.TotalProvision=isnull(ProvisionAmtAtFraud,0) + FraudProvAmt -- added by pranay to add ProvisionAmtAtFraud in total provision 2022-12-21
			   A.TotalProvision=((b.ProvisionAmtAtFraudPer * NetBalance)/100) + isnull(FraudProvAmt,0)
			  --UPDATE A SET A.TotalProvision=TotalProvision+ UsedFraudProvAmt ---- UPDATE FINAL ASSET IN ACCOUNTCAL TABLE AND PROVISION CALCULATION
			  ------,FinalAssetClassAlt_Key=6
			  FROM PRO.ACCOUNTCAL A 
			  INNER JOIN FraudAccountsDetails B
			  ON A.CustomerAcID=B.CustomerAcID 
			  WHERE ISNULL(NetBalance,0)>0
			  and (((b.ProvisionAmtAtFraudPer*NetBalance)/100) + isnull(FraudProvAmt,0))>(isnull(a.Provsecured,0)+isnull(a.ProvUnsecured,0))
	END
else
        BEGIN
         UPDATE A SET -- A.TotalProvision=isnull(ProvisionAmtAtFraud,0) + FraudProvAmt
                                   A.TotalProvision=((isnull(ProvisionAmtAtFraudPer,0)*NetBalance)/100 )+ isnull(C.FraudProvAmt,0)
                           -- added by pranay to add ProvisionAmtAtFraud in total provision 2022-12-21
                          --UPDATE A SET A.TotalProvision=TotalProvision+ UsedFraudProvAmt ---- UPDATE FINAL ASSET IN ACCOUNTCAL TABLE AND PROVISION CALCULATION
                          ------,FinalAssetClassAlt_Key=6
                          FROM PRO.ACCOUNTCAL A
                          INNER JOIN FraudAccountsDetails_hist B
                          ON A.CustomerAcID=B.CustomerAcID
                           INNER JOIN FraudAccountsDetails C
                          ON A.CustomerAcID=C.CustomerAcID
                          WHERE ISNULL(NetBalance,0)>0
                          and (((isnull(ProvisionAmtAtFraudPer,0)*NetBalance)/100) + isnull(C.FraudProvAmt,0))>(isnull(a.Provsecured,0)+isnull(a.ProvUnsecured,0))
                          and b.EffectiveFromTimeKey in (select  LastQtrDateKey from SysDayMatrix where TimeKey=@TimeKey)
 END


 UPDATE B SET 
             RBIProvsecured = 0  --TotalProvision Computation Revised for STD to Fraud Accounts After Observation Raised by bank and Discussion with Amar sir and Tushar , Changed by shubham on 2024-02-13
			,BankProvsecured = 0
            ,Provsecured = 0
			,RBIProvUnsecured = 0
			,BankProvUnsecured = 0
 			,ProvUnsecured = 0
			,RBITotalProvision = 0  -- Added on 2024-02-15 by Shubham on UAT after observation for totalbankProvision to be updated 0
			,BankTotalProvision = 0  -- Added on 2024-02-15 by Shubham on UAT after observation for totalbankProvision to be updated 0
			,b.TotalProvision=a.FraudProvAmt
FROM FraudAccountsDetails a 
	INNER JOIN PRO.AccountCal b
ON a.CustomerAcID=b.CustomerAcID
	WHERE ISNULL(NetBalance,0)>0
	AND ISNULL(a.ActualAssetClassAlt_Key,1)=1  -- /*Changed by D2k 19FEB24 - Shubham -added */
	AND ISNULL(a.FinalAssetClassAlt_Key,1)=6
	ANd ISNULL(b.FinalAssetClassAlt_Key,1)=6

UPDATE B SET UsedFraudProvAmt= CASE WHEN A.TotalProvision>=NetBalance -- Update Added on 2024-02-15 by Shubham for Used Fraud Amount Correction for STD to Fraud Accounts 
										THEN 0
									WHEN  NetBalance>=((b.ProvisionAmtAtFraudPer * NetBalance)/100)+(isnull(NetBalance,0)*(ProvisionPer*QTR))/100 --- UPDATE FraudProvAmt applicable for the QTR
										THEN (isnull(NetBalance,0)*(ProvisionPer*QTR))/100
								ELSE NetBalance-TotalProvision
							end
FROM FraudAccountsDetails B 
	INNER JOIN PRO.AccountCal A
ON a.CustomerAcID=b.CustomerAcID
	WHERE ISNULL(NetBalance,0)>0
	AND ISNULL(b.ActualAssetClassAlt_Key,1)=1  --AND ISNULL(a.InitialAssetClassAlt_Key,1)=1 /*Changed by D2k 19FEB24 - Shubham -added */
	ANd ISNULL(b.FinalAssetClassAlt_Key,1)=6


 /* bELOW UPDATES ARE COMMENTED ON 2022-12-09 BY PRANAY TO ELIMINATE LOSS MARKING */

   UPDATE A SET SysAssetClassAlt_Key=6  ---- UPDATE FINAL ASSET IN CUSTOMERCAL TABLE
   FROM PRO.CUSTOMERCAL A 
  INNER JOIN FraudAccountsDetails B
  ON A.RefCustomerID=B.CustomerID and A.Asset_Norm <>'ALWYS_STD'
  INNER JOIN [DATAUPLOAD].[FRAUDACCOUNTSDATAUPLOAD] C 
ON A.REFCUSTOMERID=C.CUSTOMERID AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)


  UPDATE B SET FinalAssetClassAlt_Key=6 -- UPDATE ALL ACCOUNT AS FRAUD WHERE CUSTOMER IS FRAUD
   FROM PRO.CUSTOMERCAL A 
  INNER JOIN PRO.AccountCal B
  ON A.RefCustomerID=B.RefCustomerID
  WHERE A.SysAssetClassAlt_Key=6 and B.Asset_Norm <>'ALWYS_STD'

  -----------------fRAUD ACCOUNT RELATED CHANGES--END-----------------------------------------------
 IF OBJECT_ID('TEMPDB..#TOTALPROVCUST') IS NOT NULL
     DROP TABLE #TOTALPROVCUST

SELECT					CUSTOMERENTITYID,
						SUM(ISNULL(TOTALPROVISION,0)) TOTALPROVISION, 
						SUM(ISNULL(BANKTOTALPROVISION,0)) BANKTOTPROVISION ,
						SUM(ISNULL(RBITOTALPROVISION,0)) RBITOTPROVISION 
						INTO #TOTALPROVCUST  FROM PRO.ACCOUNTCAL
GROUP BY CUSTOMERENTITYID


UPDATE A SET A.TOTPROVISION=B.TOTALPROVISION,A.BANKTOTPROVISION=B.BANKTOTPROVISION,A.RBITOTPROVISION=B.RBITOTPROVISION
FROM PRO.CUSTOMERCAL A INNER JOIN #TOTALPROVCUST B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID

--DELETE  FROM  CURDAT.AdvCustNPAdetail WHERE EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY

IF OBJECT_ID ('TEMPDB..#AdvCustNPAdetail') IS NOT NULL
DROP TABLE #AdvCustNPAdetail

CREATE TABLE [#AdvCustNPAdetail](
	[CustomerEntityId] [int] NOT NULL,
	[Cust_AssetClassAlt_Key] [smallint] NULL,
	[NPADt] [date] NULL,
	[LastInttChargedDt] [date] NULL,
	[DbtDt] [date] NULL,
	[LosDt] [date] NULL,
	[DefaultReason1Alt_Key] [smallint] NULL,
	[DefaultReason2Alt_Key] [smallint] NULL,
	[StaffAccountability] [char](1) NULL,
	[LastIntBooked] [date] NULL,
	[RefCustomerID] [varchar](30) NULL,
	[AuthorisationStatus] [varchar](2) NULL,
	[EffectiveFromTimeKey] [int] NOT NULL,
	[EffectiveToTimeKey] [int] NOT NULL,
	[CreatedBy] [varchar](20) NULL,
	[DateCreated] [date] NULL,
	[ModifiedBy] [varchar](20) NULL,
	[DateModified] [date] NULL,
	[ApprovedBy] [varchar](20) NULL,
	[DateApproved] [date] NULL,
	[MocStatus] [char](1) NULL,
	[MocDate] [date] NULL,
	[MocTypeAlt_Key] [int] NULL,
	[WillfulDefault] [char](1) NULL,
	[WillfulDefaultReasonAlt_Key] [smallint] NULL,
	[WillfulRemark] [varchar](1000) NULL,
	[WillfulDefaultDate] [date] NULL,
	[NPA_Reason] [varchar](1000) NULL,
    [SourceSystemCustomerID] [varchar](50) NULL
) ON [PRIMARY]



INSERT INTO #AdvCustNPAdetail

(
 CustomerEntityId
,Cust_AssetClassAlt_Key
,NPADt
,LastInttChargedDt
,DbtDt
,LosDt
,DefaultReason1Alt_Key
,DefaultReason2Alt_Key
,StaffAccountability
,LastIntBooked
,RefCustomerID
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,MocStatus
,MocDate
,MocTypeAlt_Key
,WillfulDefault
,WillfulDefaultReasonAlt_Key
,WillfulRemark
,WillfulDefaultDate
,NPA_Reason
,SourceSystemCustomerID
)

			SELECT 
					CustomerEntityId
					,A.SysAssetClassAlt_Key Cust_AssetClassAlt_Key
					,SysNPA_Dt NPADt
					,NULL LastInttChargedDt
					,DbtDt DbtDt
					,LossDt LosDt
					,NULL DefaultReason1Alt_Key
					,NULL DefaultReason2Alt_Key
					,NULL StaffAccountability
					,NULL LastIntBooked
					,RefCustomerID RefCustomerID
					,NULL AuthorisationStatus
					,A.EffectiveFromTimeKey EffectiveFromTimeKey
					,49999 EffectiveToTimeKey
					,NULL CreatedBy
					,GETDATE() DateCreated
					,NULL ModifiedBy
					,NULL DateModified
					,NULL ApprovedBy
					,NULL DateApproved
					,NULL MocStatus
					,NULL MocDate
					,NULL MocTypeAlt_Key
					,NULL WillfulDefault
					,NULL WillfulDefaultReasonAlt_Key
					,NULL WillfulRemark
					,NULL WillfulDefaultDate
					,A.DegReason AS NPA_Reason
					,A.SourceSystemCustomerID AS SourceSystemCustomerID
		FROM PRO.CustomerCal A
			INNER JOIN dbo.DimAssetClass B
				ON  (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)AND
				 A.SysAssetClassAlt_Key=B.AssetClassAlt_Key
				AND ISNULL(B.AssetClassShortNameEnum,'STD')<>'STD'



Declare @vEffectiveto INT Set @vEffectiveto= (select Timekey-1 from PRO.EXTDATE_MISDB where Flg='Y')

MERGE CurDat.AdvCustNPAdetail AS O
USING  #AdvCustNPAdetail AS T
ON      O.SourceSystemCustomerID=T.SourceSystemCustomerID
    AND O.EFFECTIVETOTimekey=49999
	AND T.EFFECTIVETOTimekey=49999

 WHEN MATCHED AND 
(
          O.[Cust_AssetClassAlt_Key]		    <>	        T.[Cust_AssetClassAlt_Key]
         OR  O.[NPADt]							<>	        T.[NPADt]
         OR  O.[LastInttChargedDt]				<>	        T.[LastInttChargedDt]
         OR  O.[LosDt]							<>	        T.[LosDt]
         OR  ISNULL(O.[DbtDt],'')							<>	     ISNULL(T.[DbtDt],'')
         OR  O.[DefaultReason1Alt_Key]			<>	        T.[DefaultReason1Alt_Key]
         OR  O.[DefaultReason2Alt_Key]			<>	        T.[DefaultReason2Alt_Key]
         OR  O.[StaffAccountability]			<>	        T.[StaffAccountability]
         OR  O.[LastIntBooked]					<>	        T.[LastIntBooked]
         OR  O.[RefCustomerID]					<>	        T.[RefCustomerID]
         OR  O.[MocStatus]						<>	        T.[MocStatus]
         OR  O.[MocDate]						<>	        T.[MocDate]
         OR  O.[MocTypeAlt_Key]					<>	        T.[MocTypeAlt_Key]
         OR  O.[WillfulDefault]					<>	        T.[WillfulDefault]
         OR  O.[WillfulDefaultReasonAlt_Key]	<>	        T.[WillfulDefaultReasonAlt_Key]
         OR  O.[WillfulRemark]					<>	        T.[WillfulRemark]
         OR  O.[WillfulDefaultDate]				<>	        T.[WillfulDefaultDate]
         OR  O.[NPA_Reason]						<>	        T.[NPA_Reason]
         OR  O.[SourceSystemCustomerID]						<>	        T.[SourceSystemCustomerID]
) THEN 

 UPDATE SET 
 O.EFFECTIVETOTimekey=@vEffectiveto ,
 O.ModifiedBy='SSISUSER'       ,
 O.DateModified=CONVERT(DATE,GETDATE(),103) ;

 UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=Convert(date,getdate(),103),
 ModifiedBy='SSISUSER' 
FROM CURDAT.AdvCustNPAdetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM #AdvCustNPAdetail BB
				WHERE AA.SourceSystemCustomerID=BB.SourceSystemCustomerID
				AND BB.EffectiveToTimeKey =49999
				)


MERGE CurDat.AdvCustNPAdetail AS O
USING #AdvCustNPAdetail AS T
ON  O.SourceSystemCustomerID=T.SourceSystemCustomerID  
AND O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHEN  NOT MATCHED THEN INSERT

  (
	       [CustomerEntityId]
           ,[Cust_AssetClassAlt_Key]
           ,[NPADt]
           ,[LastInttChargedDt]
           ,[DbtDt] 
           ,[LosDt]
           ,[DefaultReason1Alt_Key]
           ,[DefaultReason2Alt_Key]
           ,[StaffAccountability]
           ,[LastIntBooked]
           ,[RefCustomerID]
           ,[AuthorisationStatus]
           ,[EffectiveFromTimeKey]
           ,[EffectiveToTimeKey]
           ,[CreatedBy]
           ,[DateCreated]
           ,[ModifiedBy]
           ,[DateModified]
           ,[ApprovedBy]
           ,[DateApproved]
           ,[MocStatus]
           ,[MocDate]
           ,[MocTypeAlt_Key]
           ,[WillfulDefault]
           ,[WillfulDefaultReasonAlt_Key]
           ,[WillfulRemark]
           ,[WillfulDefaultDate]
           ,[NPA_Reason]
			,[SourceSystemCustomerID]
)
VALUES
(
	       T.[CustomerEntityId]
           ,T.[Cust_AssetClassAlt_Key]
           ,T.[NPADt]
           ,T.[LastInttChargedDt]
           ,T.[DbtDt]
           ,T.[LosDt]
           ,T.[DefaultReason1Alt_Key]
           ,T.[DefaultReason2Alt_Key]
           ,T.[StaffAccountability]
           ,T.[LastIntBooked]
           ,T.[RefCustomerID]
           ,T.[AuthorisationStatus]
           ,T.[EffectiveFromTimeKey]
           ,T.[EffectiveToTimeKey]
           ,T.[CreatedBy]
           ,T.[DateCreated]
           ,T.[ModifiedBy]
           ,T.[DateModified]
           ,T.[ApprovedBy]
           ,T.[DateApproved]
           ,T.[MocStatus]
           ,T.[MocDate]
           ,T.[MocTypeAlt_Key]
           ,T.[WillfulDefault]
           ,T.[WillfulDefaultReasonAlt_Key]
           ,T.[WillfulRemark]
           ,T.[WillfulDefaultDate]
           ,T.[NPA_Reason]
			,T.[SourceSystemCustomerID]
		   );
UPDATE C SET EffectiveToTimeKey=@TIMEKEY-1
FROM  PRO.CustomerCal A
			INNER JOIN CURDAT.AdvCustNPAdetail C ON A.SourceSystemCustomerID=C.SourceSystemCustomerID
						INNER JOIN dbo.DimAssetClass B
				ON  (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)AND
				 A.SysAssetClassAlt_Key=B.AssetClassAlt_Key
				AND ISNULL(B.AssetClassShortNameEnum,'STD')='STD'
				WHERE (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)


DROP TABLE #TOTALPROVCUST

----Update dbt date where dbt date null due to co borrower issue

--update CURDAT.AdvCustNPAdetail set DBTDT=													
														
--(CASE 													
--WHEN  DATEADD(MONTH,@SUB_Months,A.NPADt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.NPADt)>@PROCESSDATE  THEN DATEADD(MONTH,@SUB_Months,A.NPADt)													
--WHEN  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.NPADt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months+@DB2_Months,A.NPADt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Months,A.NPADt)													
--WHEN  DATEADD(MONTH,(@DB1_Months+@SUB_Months+@DB2_Months),A.NPADt)<=@PROCESSDATE THEN DATEADD(MONTH,(@SUB_Months),A.NPADt)													
--ELSE A.DBTDT 													
--END)   													
														
--FROM CURDAT.AdvCustNPAdetail A INNER JOIN DimAssetClass B  ON A.Cust_AssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey													
--WHERE B.AssetClassShortName NOT IN('STD','LOS')  and A.DbtDt is null 													
--AND A.Cust_AssetClassAlt_Key IN(3,4,5)													
--AND A.EffectiveToTimeKey=49999													

--update pro.customercal  set DBTDT=B.DBTDT
--from pro.customercal  a
--inner join CURDAT.AdvCustNPAdetail b
--on a.CustomerEntityID=b.CustomerEntityID
--where SysAssetClassAlt_Key IN(3,4,5) AND b.EffectiveToTimeKey=49999
--and b.Cust_AssetClassAlt_Key IN(3,4,5)

/************FraudAccountsDetails_Hist data insert********2022-12-11 Pranay & Amar sir*********/
--INSERT INTO FraudAccountsDetails_Hist
--(
--	 UCIF_ID
--	,CustomerID
--	,CustomerAcID
--	,FinalAssetClassAlt_Key
--	,QTR
--	,UsedFraudProvAmt
--	,FraudProvAmt
--	,EffectiveFromTimeKey
--	,EffectiveToTimeKey
--)


--SELECT 
--	 A.UCIF_ID
--	,A.CustomerID
--	,A.CustomerAcID
--	,A.FinalAssetClassAlt_Key
--	,A.QTR
--	,A.UsedFraudProvAmt
--	,A.FraudProvAmt
--	,A.EffectiveFromTimeKey
--	,A.EffectiveToTimeKey
--FROM FraudAccountsDetails a
--LEFT JOIN FraudAccountsDetails_Hist b
--ON 
----	a.UCIF_ID		=	b.UCIF_ID
----AND a.CustomerID	=	b.CustomerID AND
-- a.CustomerAcID  =   b.CustomerAcID
--where b.CustomerAcID is null


MERGE FraudAccountsDetails_Hist AS O
USING FraudAccountsDetails AS T
ON O.CUSTOMERACID=T.CUSTOMERACID  
and O.EffectiveToTimeKey=49999
 WHEN MATCHED AND 
(
   isnull(T.FinalAssetClassAlt_Key,0)<>isnull(O.FinalAssetClassAlt_Key,0)
OR isnull(T.QTR,0)<>isnull(O.QTR,0)
OR isnull(T.UsedFraudProvAmt,0)<>isnull(O.UsedFraudProvAmt,0)
OR isnull(T.FraudProvAmt,0)<>isnull(O.FraudProvAmt,0)
)
Then
UPDATE SET 
O.EffectiveToTimeKey=@vEffectiveto;



UPDATE AA SET EffectiveToTimeKey = @vEffectiveto
--SELECT COUNT(1) 
FROM FraudAccountsDetails_Hist AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT * FROM
    (
    SELECT BB.CUSTOMERACID FROM FraudAccountsDetails BB
    WHERE AA.CUSTOMERACID=BB.CUSTOMERACID
    )A
    WHERE AA.CUSTOMERACID=A.CUSTOMERACID
    )
Merge FraudAccountsDetails_Hist ACBAL
USING FraudAccountsDetails T_ACBAL
ON ACBAL.CUSTOMERACID=T_ACBAL.CUSTOMERACID
AND ACBAL.EffectiveToTimeKey = 49999
WHEN NOT MATCHED
THEN
INSERT
(
	 UCIF_ID
	,CustomerID
	,CustomerAcID
	,FinalAssetClassAlt_Key
	,QTR
	,UsedFraudProvAmt
	,FraudProvAmt
	,EffectiveFromTimeKey
	,EffectiveToTimeKey
)
Values
(
	 T_ACBAL.UCIF_ID
	,T_ACBAL.CustomerID
	,T_ACBAL.CustomerAcID
	,T_ACBAL.FinalAssetClassAlt_Key
	,T_ACBAL.QTR
	,T_ACBAL.UsedFraudProvAmt
	,T_ACBAL.FraudProvAmt
	,@TIMEKEY
	,49999
); 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='UpdationTotalProvision'


END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='UpdationTotalProvision'
END CATCH  
   SET NOCOUNT OFF                   
END 














GO