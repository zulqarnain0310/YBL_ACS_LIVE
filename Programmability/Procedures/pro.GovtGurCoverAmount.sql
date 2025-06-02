SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*=====================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE : 05-07-2018
MODIFY DATE : 05-07-2018
DESCRIPTION : Govt Gur Cover Amount
EXEC pro.GovtGurCoverAmount  @TIMEKEY=25410
====================================*/
CREATE PROCEDURE [pro].[GovtGurCoverAmount] 
@TimeKey INT
with recompile
AS
  BEGIN
        SET NOCOUNT ON
        BEGIN TRY
 

		    

Declare @FITL  AS SmallInt = (SELECT ProvisionAlt_Key FROM DimProvision_Seg WHERE EffectiveFromTimeKey < = @TimeKey and EffectiveToTimeKey >= @TimeKey and ProvisionShortNameEnum = 'FITL')

	--UPDATE pro.AccountCal set   CoverGovGur=0 

		
--	UPDATE A SET A.CoverGovGur =
			
--			                         ( CASE
                                      
--									   WHEN ISNULL(DAC.AssetClassShortNameEnum,'')='STD' 
--									            THEN     (CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) 
--									 WHEN  ISNULL(DAC.AssetClassShortNameEnum,'')='LOS' 
--									                  THEN ( case when ISNULL(A.AppGovGur,0) >0 then ISNULL(A.AppGovGur,0) else 0 end )					  
													
--									else 
--													(CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) end) 
																   
		
	
--	FROM  PRO.AccountCal A 
--	INNER JOIN PRO.CustomerCal B  ON A.CustomerEntityID=B.CustomerEntityID

--	INNER JOIN (SELECT  AccountEntityId, BillNo, Balance
--					  , IIF(ClaimType IN ('ECGC','DICGC'),ISNULL(ClaimReceivedAmt,0),0) AS ClaimReceivedAmt
--					  , (CASE WHEN (ISNULL(ClaimReceivedAmt,0) >0  AND ISNULL(ClaimCoverAmt,0) > 0) 
--								--OR ClaimType IN ('ECGC','DICGC') 
--								   THEN 0 
--						 ELSE ISNULL(ClaimCoverAmt,0) 
--						 END) AS ClaimCoverAmt
--				FROM CurDat.AdvFacBillDetail
--				where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
--				) FBD ON FBD.AccountEntityID=A.AccountEntityId
--			                                -- AND FBC.Billno =FBD.BillNo 
   
--	INNER JOIN DimProvision_Seg DP ON DP.EffectiveFromTimeKey<=@TimeKey
--	                          AND DP.EffectiveTOTimeKey>=@TimeKey 
--	                          AND ISNULL(A.ProvisionALt_Key,1) =DP.ProvisionAlt_key 
--	INNER JOIN DimAssetClass DAC ON DAC.EffectiveFromTimeKey<=@TimeKey
--	                            AND DAC.EffectiveTOTimeKey>=@TimeKey 
--	                            AND ISNULL(A.FinalAssetClassAlt_Key,1) =DAC.AssetClassAlt_Key 
--	LEFT JOIN DimGLProduct DGP ON DGP.EffectiveFromTimeKey<=@TimeKey
--	                           AND DGP.EffectiveTOTimeKey>=@TimeKey 
--	                           AND A.GLProductALt_Key=DGp.GLProductAlt_Key 
--	LEFT JOIN DimScheme DSE ON DSE.EffectiveFromTimeKey<=@TimeKey
--	                        AND DSE.EffectiveTOTimeKey>=@TimeKey 
--	                        AND A.SchemeALt_Key = DSE.SchemeAlt_Key
--	LEFT JOIN CURDAT.AdvAcOtherDetail OthDtl ON  OthDtl.AccountEntityId = A.AccountEntityID
--	                                 and OthDtl.EffectiveFromTimeKey<=@TimeKey and OthDtl.EffectiveToTimeKey>=@TimeKey
--	LEFT JOIN dbo.DimAcSplCategory AcSplCat ON  AcSplCat.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg1Alt_Key,0) = AcSplCat.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat1 ON AcSplCat1.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat1.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg2Alt_Key,0)= AcSplCat1.SplCatAlt_Key
--    LEFT JOIN dbo.DimAcSplCategory AcSplCat3 ON  AcSplCat3.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat3.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg3Alt_Key,0) = AcSplCat3.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat4 ON AcSplCat4.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat4.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg4Alt_Key,0)= AcSplCat4.SplCatAlt_Key
--	WHERE ISNULL(B.FlgProcessing,'N') ='N' 
--	AND ISNULL(a.GrossUnSecuredAmt,0)>0 

--	-------CC
	
--	UPDATE A SET CoverGovGur =



--	  ( CASE
                                      
--									   WHEN ISNULL(DAC.AssetClassShortNameEnum,'')='STD' 
--									            THEN     (CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) 
--									 WHEN  ISNULL(DAC.AssetClassShortNameEnum,'')='LOS' 
--									                  THEN ( case when ISNULL(A.AppGovGur,0) >0 then ISNULL(A.AppGovGur,0) else 0 end )					  
													
--									else 
--													(CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) end) 


		
	
	
--	FROM  PRO.AccountCal A 
--	INNER JOIN PRO.CustomerCal B  ON A.CustomerEntityID=B.CustomerEntityID

--	INNER JOIN (SELECT  AccountEntityId,
--					   IIF(ClaimType IN ('ECGC','DICGC'),ISNULL(ClaimReceivedAmt,0),0) AS ClaimReceivedAmt
--					  , (CASE WHEN (ISNULL(ClaimReceivedAmt,0) >0  AND ISNULL(ClaimCoverAmt,0) > 0) 
--								--OR ClaimType IN ('ECGC','DICGC') 
--								   THEN 0 
--						 ELSE ISNULL(ClaimCoverAmt,0) 
--						 END) AS ClaimCoverAmt
--				FROM CurDat.AdvFacCCDetail
--				where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
--				) FBD ON FBD.AccountEntityID=A.AccountEntityId
--			                                -- AND FBC.Billno =FBD.BillNo 
   
--	INNER JOIN DimProvision_Seg DP ON DP.EffectiveFromTimeKey<=@TimeKey
--	                          AND DP.EffectiveTOTimeKey>=@TimeKey 
--	                          AND ISNULL(A.ProvisionALt_Key,1) =DP.ProvisionAlt_key 
--	INNER JOIN DimAssetClass DAC ON DAC.EffectiveFromTimeKey<=@TimeKey
--	                            AND DAC.EffectiveTOTimeKey>=@TimeKey 
--	                            AND ISNULL(A.FinalAssetClassAlt_Key,1) =DAC.AssetClassAlt_Key 
--	LEFT JOIN DimGLProduct DGP ON DGP.EffectiveFromTimeKey<=@TimeKey
--	                           AND DGP.EffectiveTOTimeKey>=@TimeKey 
--	                           AND A.GLProductALt_Key=DGp.GLProductAlt_Key 
--	LEFT JOIN DimScheme DSE ON DSE.EffectiveFromTimeKey<=@TimeKey
--	                        AND DSE.EffectiveTOTimeKey>=@TimeKey 
--	                        AND A.SchemeALt_Key = DSE.SchemeAlt_Key
--	LEFT JOIN CURDAT.AdvAcOtherDetail OthDtl ON  OthDtl.AccountEntityId = A.AccountEntityID
--	                                 and OthDtl.EffectiveFromTimeKey<=@TimeKey and OthDtl.EffectiveToTimeKey>=@TimeKey
--	LEFT JOIN dbo.DimAcSplCategory AcSplCat ON  AcSplCat.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg1Alt_Key,0) = AcSplCat.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat1 ON AcSplCat1.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat1.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg2Alt_Key,0)= AcSplCat1.SplCatAlt_Key
--    LEFT JOIN dbo.DimAcSplCategory AcSplCat3 ON  AcSplCat3.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat3.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg3Alt_Key,0) = AcSplCat3.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat4 ON AcSplCat4.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat4.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg4Alt_Key,0)= AcSplCat4.SplCatAlt_Key
--	WHERE ISNULL(B.FlgProcessing,'N') ='N' 
--	AND ISNULL(a.GrossUnSecuredAmt,0)>0 

		  
--UPDATE A SET CoverGovGur =  ( CASE
                                      
--									   WHEN ISNULL(DAC.AssetClassShortNameEnum,'')='STD' 
--									            THEN     (CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) 
--									 WHEN  ISNULL(DAC.AssetClassShortNameEnum,'')='LOS' 
--									                  THEN ( case when ISNULL(A.AppGovGur,0) >0 then ISNULL(A.AppGovGur,0) else 0 end )					  
													
--									else 
--													(CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) end) 
			
	
--	FROM  PRO.AccountCal A 
--	INNER JOIN PRO.CustomerCal B  ON A.CustomerEntityID=B.CustomerEntityID

--	INNER JOIN (SELECT  AccountEntityId
--					  , IIF(ClaimType IN ('ECGC','DICGC'),ISNULL(ClaimReceivedAmt,0),0) AS ClaimReceivedAmt
--					  , (CASE WHEN (ISNULL(ClaimReceivedAmt,0) >0  AND ISNULL(ClaimCoverAmt,0) > 0) 
--								--OR ClaimType IN ('ECGC','DICGC') 
--								   THEN 0 
--						 ELSE ISNULL(ClaimCoverAmt,0) 
--						 END) AS ClaimCoverAmt
--				FROM CurDat.AdvFacDLDetail
--				where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
--				) FBD ON FBD.AccountEntityID=A.AccountEntityId
--			                                -- AND FBC.Billno =FBD.BillNo 
   
--	INNER JOIN DimProvision_Seg DP ON DP.EffectiveFromTimeKey<=@TimeKey
--	                          AND DP.EffectiveTOTimeKey>=@TimeKey 
--	                          AND ISNULL(A.ProvisionALt_Key,1) =DP.ProvisionAlt_key 
--	INNER JOIN DimAssetClass DAC ON DAC.EffectiveFromTimeKey<=@TimeKey
--	                            AND DAC.EffectiveTOTimeKey>=@TimeKey 
--	                            AND ISNULL(A.FinalAssetClassAlt_Key,1) =DAC.AssetClassAlt_Key 
--	LEFT JOIN DimGLProduct DGP ON DGP.EffectiveFromTimeKey<=@TimeKey
--	                           AND DGP.EffectiveTOTimeKey>=@TimeKey 
--	                           AND A.GLProductALt_Key=DGp.GLProductAlt_Key 
--	LEFT JOIN DimScheme DSE ON DSE.EffectiveFromTimeKey<=@TimeKey
--	                        AND DSE.EffectiveTOTimeKey>=@TimeKey 
--	                        AND A.SchemeALt_Key = DSE.SchemeAlt_Key
--	LEFT JOIN CURDAT.AdvAcOtherDetail OthDtl ON  OthDtl.AccountEntityId = A.AccountEntityID
--	                                 and OthDtl.EffectiveFromTimeKey<=@TimeKey and OthDtl.EffectiveToTimeKey>=@TimeKey
--	LEFT JOIN dbo.DimAcSplCategory AcSplCat ON  AcSplCat.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg1Alt_Key,0) = AcSplCat.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat1 ON AcSplCat1.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat1.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg2Alt_Key,0)= AcSplCat1.SplCatAlt_Key
--    LEFT JOIN dbo.DimAcSplCategory AcSplCat3 ON  AcSplCat3.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat3.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg3Alt_Key,0) = AcSplCat3.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat4 ON AcSplCat4.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat4.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg4Alt_Key,0)= AcSplCat4.SplCatAlt_Key
--	WHERE ISNULL(B.FlgProcessing,'N') ='N'
--	AND ISNULL(a.GrossUnSecuredAmt,0)>0 
	
	
--	--PC
--	UPDATE A SET CoverGovGur =

--	  ( CASE
                                      
--									   WHEN ISNULL(DAC.AssetClassShortNameEnum,'')='STD' 
--									            THEN     (CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) 
--									 WHEN  ISNULL(DAC.AssetClassShortNameEnum,'')='LOS' 
--									                  THEN ( case when ISNULL(A.AppGovGur,0) >0 then ISNULL(A.AppGovGur,0) else 0 end )					  
													
--									else 
--													(CASE WHEN ISNULL(A.COMPUTEDCLAIM,0)>(ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--												              THEN (ISNULL(FBD.CLAIMCOVERAMT,0) + ISNULL(FBD.CLAIMRECEIVEDAMT,0) + ISNULL(A.APPGOVGUR,0))
--															  else ISNULL(A.COMPUTEDCLAIM,0) end) end) 


	
	
--	FROM  PRO.AccountCal A 
--	INNER JOIN PRO.CustomerCal B  ON A.CustomerEntityID=B.CustomerEntityID
	
--	INNER JOIN (SELECT  AccountEntityId
--					  , IIF(ClaimType IN ('ECGC','DICGC'),ISNULL(ClaimReceivedAmt,0),0) AS ClaimReceivedAmt
--					  , (CASE WHEN (ISNULL(ClaimReceivedAmt,0) >0  AND ISNULL(ClaimCoverAmt,0) > 0) 
--								--OR ClaimType IN ('ECGC','DICGC') 
--								   THEN 0 
--						 ELSE ISNULL(ClaimCoverAmt,0) 
--						 END) AS ClaimCoverAmt
--				FROM CurDat.AdvFacPCDetail
--				where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
--				) FBD ON FBD.AccountEntityID=A.AccountEntityId
--			                                -- AND FBC.Billno =FBD.BillNo 
   
--	INNER JOIN DimProvision_Seg DP ON DP.EffectiveFromTimeKey<=@TimeKey
--	                          AND DP.EffectiveTOTimeKey>=@TimeKey 
--	                          AND ISNULL(A.ProvisionALt_Key,1) =DP.ProvisionAlt_key 
--	INNER JOIN DimAssetClass DAC ON DAC.EffectiveFromTimeKey<=@TimeKey
--	                            AND DAC.EffectiveTOTimeKey>=@TimeKey 
--	                            AND ISNULL(A.FinalAssetClassAlt_Key,1) =DAC.AssetClassAlt_Key 
--	LEFT JOIN DimGLProduct DGP ON DGP.EffectiveFromTimeKey<=@TimeKey
--	                           AND DGP.EffectiveTOTimeKey>=@TimeKey 
--	                           AND A.GLProductALt_Key=DGp.GLProductAlt_Key 
--	LEFT JOIN DimScheme DSE ON DSE.EffectiveFromTimeKey<=@TimeKey
--	                        AND DSE.EffectiveTOTimeKey>=@TimeKey 
--	                        AND A.SchemeALt_Key = DSE.SchemeAlt_Key
--	LEFT JOIN CURDAT.AdvAcOtherDetail OthDtl ON  OthDtl.AccountEntityId = A.AccountEntityID
--	                                 and OthDtl.EffectiveFromTimeKey<=@TimeKey and OthDtl.EffectiveToTimeKey>=@TimeKey
--	LEFT JOIN dbo.DimAcSplCategory AcSplCat ON  AcSplCat.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg1Alt_Key,0) = AcSplCat.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat1 ON AcSplCat1.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat1.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg2Alt_Key,0)= AcSplCat1.SplCatAlt_Key
--    LEFT JOIN dbo.DimAcSplCategory AcSplCat3 ON  AcSplCat3.EffectiveFromTimeKey <= @TimeKey
--											AND AcSplCat3.EffectiveToTimeKey >= @TimeKey
--											AND ISNULL(OthDtl.SplCatg3Alt_Key,0) = AcSplCat3.SplCatAlt_Key
--	LEFT JOIN dbo.DimAcSplCategory AS AcSplCat4 ON AcSplCat4.EffectiveFromTimeKey < = @TimeKey
--												AND AcSplCat4.EffectiveToTimeKey > = @TimeKey
--												AND ISNULL(OthDtl.SplCatg4Alt_Key,0)= AcSplCat4.SplCatAlt_Key
--	WHERE ISNULL(B.FlgProcessing,'N') ='N'
--	AND ISNULL(a.GrossUnSecuredAmt,0)>0 
 
--    Update PRO.ACCOUNTCAL	set CoverGovGur= 0 where ISNULL(CoverGovGur,0) <0 

	

  	/******************************************************************************************************
	 ******************************************************************************************************
	                        Provision Compuatation on Govt. Guar. Cover poration
	 ******************************************************************************************************
	 ******************************************************************************************************/
	 	UPDATE A 
		SET ProvCoverGovGur =
										CASE 
											WHEN ISNULL(Acl.AssetClassShortNameEnum,'STD')='STD'  THEN
												ROUND(ISNULL(A.CoverGovGur,0) * Prov.ProvisionSecured  ,0)
											WHEN ISNULL(Acl.AssetClassShortNameEnum,'STD')='SUB' THEN 
												ROUND(ISNULL(A.CoverGovGur,0) * Prov.ProvisionSecured  ,0)
											ELSE
												0
										END
	
    FROM PRO.ACCOUNTCAL A   inner join pro.CustomerCal b on a.CustomerEntityID=b.CustomerEntityID					   
	INNER JOIN dbo.DimAssetClass Acl ON Acl.EffectiveFromTimeKey <= @TimeKey 
	                                AND Acl.EffectiveToTimeKey >= @TimeKey
									AND ISNULL(a.FinalAssetClassAlt_Key,1) = Acl.AssetClassAlt_Key 
	INNER JOIN dbo.DimProvision_Seg Prov ON Prov.EffectiveFromTimeKey <= @TimeKey
	                                AND Prov.EffectiveToTimeKey >= @TimeKey
	                                AND ISNULL(a.ProvisionAlt_Key,1) = Prov.ProvisionAlt_key  
	WHERE ISNULL(b.FlgProcessing,'N') ='N'
	  And ISNULL(a.CoverGovGur,0)>0   
	
	



UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='GovtGurCoverAmount'


END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='GovtGurCoverAmount'
END CATCH
	     SET NOCOUNT OFF 
END










GO