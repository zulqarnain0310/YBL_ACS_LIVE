SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[MOCDetailSelect]
@CustomerEntityId  INT=0
,@OperationFlag    INT=1
,@UserId	   VARCHAR(50)=''
,@TimeKey		   INT=0
WITH RECOMPILE
AS
--BEGIN
		/*****************************************************************************************************************************************

						CUSTOMER DATA FROM MocCustomerDataUpload

		*****************************************************************************************************************************************/
		
		IF OBJECT_ID('Tempdb..#MocCustomerCal_hist')	IS NOT NULL
				DROP TABLE #MocCustomerCal_hist

        select * into #MocCustomerCal_hist  FROM PRO.CustomerCal 
			WHERE CustomerEntityID = @CustomerEntityId --AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey  


		IF OBJECT_ID('Tempdb..#MocAccountCal_hist')	IS NOT NULL
				DROP TABLE #MocAccountCal_hist

        select * into #MocAccountCal_hist  FROM PRO.accountCal 
			WHERE CustomerEntityID = @CustomerEntityId --AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey  


			--DECLARE @Timekey INT = 25302, @CustomerEntityId INT =2875, 
			DECLARE @CustomerID VARCHAR(20)
							SELECT @CustomerID= RefCustomerID 
							
							FROM #MocCustomerCal_hist
							WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
							AND CustomerEntityID = @CustomerEntityId
		
			IF OBJECT_ID('Tempdb..#MocCustomerDataUpload')	IS NOT NULL
				DROP TABLE #MocCustomerDataUpload
			SELECT * 
			INTO #MocCustomerDataUpload
			FROM 
			(
			SELECT      A.MocCustomerDataEntityId 
						,@CustomerEntityId		CustomerEntityId
						,SourceSystemCustomerID
						,AssetClassification AS SysAssetClassAlt_Key
						,CONVERT(varchar(20), NPADate,103) SysNPA_Dt
						,ISNULL(SecurityValue,0) AS   CurntQtrRv
						,ISNULL(AdditionalProvision,0) AddlProvisionPer
						,MOCReason
						,MOCTYPE
						,ISNULL(A.ModifiedBy,A.CreatedBy) AS CrModApBy
						,'CustomerData' TableName 
						FROM DataUpload.MocCustomerDataUpload_Mod  A
			INNER JOIN 
			(
					SELECT MocCustomerDataEntityId ,CustomerID, MAX(Entitykey)  Entitykey 
					FROM DataUpload.MocCustomerDataUpload_Mod 
					WHERE EffectiveFromTimeKey  <= @Timekey AND EffectiveToTimeKey >= @Timekey
					AND AuthorisationStatus in('NP','MP','DP','RM')
					AND CustomerID = @CustomerID
					GROUP BY MocCustomerDataEntityId ,CustomerID
			)B				
			ON A.Entitykey = B.Entitykey
			
			UNION
			
			SELECT      MocCustomerDataEntityId
						,@CustomerEntityId CustomerEntityId
						,SourceSystemCustomerID
						,AssetClassification AS SysAssetClassAlt_Key
						,CONVERT(varchar(20), NPADate,103) SysNPA_Dt
						,ISNULL(SecurityValue,0) AS   CurntQtrRv
						,ISNULL(AdditionalProvision,0) AddlProvisionPer
						,MOCReason
						,MOCTYPE
						,ISNULL(ModifiedBy,CreatedBy) AS CrModApBy
						,'CustomerData' TableName 
			FROM DataUpload.MocCustomerDataUpload
			WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
			AND ISNULL(AuthorisationStatus,'A')='A'
			AND CustomerID = @CustomerID
			
			)A



		
			/*****************************************************************************************************************************************

								END CUSTOMER DATA 

		*****************************************************************************************************************************************/
	
			IF EXISTS (SELECT 1 FROM #MocCustomerDataUpload)
			BEGIN 
			
				SELECT * FROM #MocCustomerDataUpload
			END
			ELSE 
			BEGIN
					SELECT  NULL MocCustomerDataEntityId
						,CustomerEntityId
						,SourceSystemCustomerID
						,B.AssetClassShortName SysAssetClassAlt_Key
						,CONVERT(varchar(20), SysNPA_Dt,103) SysNPA_Dt
						,ISNULL(CurntQtrRv,0) AS   CurntQtrRv
						,AddlProvisionPer
						,MOCReason
						,'AUTO' MOCTYPE
						,ISNULL(ModifiedBy,CreatedBy) AS CrModApBy
						,'CustomerData' TableName
						 from #MocCustomerCal_hist  A
						
						INNER JOIN DimAssetClass  B ON B.AssetClassAlt_Key=A.SysAssetClassAlt_Key
						
						WHERE (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY) AND 
						(B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY) AND CustomerEntityId=@CustomerEntityId
			END


			--SET @TIMEKEY =25141
			SELECT AssetClassShortName AS AssetClassAlt_Key --AssetClassAlt_Key
			,AssetClassName,'AssetClass' TableName
			 FROM DimAssetClass   
			 WHERE (EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
	
			SELECT ParameterName AS Code, ParameterName AS Description, 'MOCTYPE' AS TableName FROM DimParameter WHERE DimParameterName='MOCTYPE' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

			SELECT 
			SUM(ISNULL(Balance,0)) Balance
			,0 TotalIR
			,SUM(ISNULL(PrincOutStd,0)) TotalPreBal
			,SUM(ISNULL(TotalProvision,0)) TotalProvision
			,'TotalList' TableName
			 FROM #MocAccountCal_hist
			 WHERE (EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)AND CustomerEntityId=@CustomerEntityId 
			 group by CustomerEntityId
			/*****************************************************************************************************************************************

						ACCOUNT  DATA FROM MocAccountDataUpload

		*****************************************************************************************************************************************/

	
	IF OBJECT_ID('Tempdb..#MocAccountDataUpload')	IS NOT NULL
		DROP TABLE #MocAccountDataUpload
	SELECT *
	INTO #MocAccountDataUpload
	FROM 
	(
	
	SELECT  A.MocAccountDataEntityId
			,CustomerID
			,SourceSystemCustomerID
			,CAST(NULL AS INT) AS AccountEntityId 
			,A.CustomerAcID
			,CustomerName
			,Balance
			,IntrestReversal
			,AdditionalProvision
			,AdditionalProvisionAmount
			,AppropriateSecurity
			,FITL
			,DFVAmount
			,RepossessionDate
			,RestructureDate
			,OriginalDCCODate
			,ExtendedDCCODate
			,ActualDCCODate
			,Infrastructure
			,MOCReason
	FROM DataUpload.MocAccountDataUpload_Mod A
	INNER JOIN 
	(
		SELECT CustomerAcID,MocAccountDataEntityId ,MAX(Entitykey)Entitykey
				from DataUpload.MocAccountDataUpload_Mod ACC
				WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey > =@Timekey
				AND AuthorisationStatus in('NP','MP','DP','RM')
				AND CustomerID =@CustomerID
		GROUP BY CustomerAcID,MocAccountDataEntityId
	)B
	ON A.Entitykey = B.Entitykey

	UNION 

	SELECT A.MocAccountDataEntityId
			,CustomerID
			,SourceSystemCustomerID
			,CAST(NULL AS INT) AS AccountEntityId
			,A.CustomerAcID
			,CustomerName
			,Balance
			,IntrestReversal
			,AdditionalProvision
			,AdditionalProvisionAmount
			,AppropriateSecurity
			,FITL
			,DFVAmount
			,RepossessionDate
			,RestructureDate
			,OriginalDCCODate
			,ExtendedDCCODate
			,ActualDCCODate
			,Infrastructure
			,MOCReason
	FROM DataUpload.MocAccountDataUpload A
	WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
	AND ISNULL(AuthorisationStatus,'A') ='A'
				AND CustomerID =@CustomerID
	)A


	--SELECT * 
	UPDATE ACC
	SET AccountEntityId = PRO.AccountEntityID
	FROM #MocAccountCal_hist  PRO
	INNER JOIN #MocAccountDataUpload ACC
		ON EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey AND PRO.CustomerAcID =ACC.CustomerAcID



			SELECT  
			CASE WHEN ISNULL(POST.MocAccountDataEntityId,0)=0 THEN NULL ELSE MocAccountDataEntityId END AS
			MocAccountDataEntityId
			,PRE.AccountEntityId
			,PRE.CustomerAcID
			,FacilityType
			,ActSegmentCode
			,PRE.Balance
			,TotalProvision
			,0 InterestReversal
			,isnull(PrincOutStd,0) PrincipalOSBal
			,AddlProvisionPer
			,AddlProvision
			--,case when SecApp='S' THEN 'Yes' else 'NO' END AS SecApp  
			,SecApp
			,FlgFITL
			,DFVAmt
			,PRE.MOCReason
			,PRE.Balance PreMOCBalance
			,PRE.AddlProvisionPer PreMOCAddlProvisionPer
			,PRE.AddlProvision PreMOCAddlProvision
			,PRE.SecApp PreMOCSecApp
			,PRE.FlgFITL	PreMOCFlgFITL
			,PRE.DFVAmt	PreMOCDFVAmt
			,CONVERT(VARCHAR(20),PRE.RepossessionDate,103)	PreMOCRepossessionDate
			,CONVERT(VARCHAR(20),RestructureDt,103)	PreMOCRestructureDt
			,CONVERT(VARCHAR(20),OriginalEnvisagCompletionDt,103)	PreMOCOriginalEnvisagCompletionDt
			,CONVERT(VARCHAR(20),ActualCompletionDt,103)	PreMOCActualCompletionDt
			,CONVERT(VARCHAR(20),RevisedCompletionDt,103)	PreMOCRevisedCompletionDt
			,PRE.FlgINFRA	PreMOCFlgINFRA
			,PRE.MOCReason	PreMOCMOCReason
			--*******************
			,CASE WHEN ISNULL(POST.Balance,0)=0 THEN ISNULL(PRE.Balance,0) ELSE ISNULL(POST.Balance,0) END PostMOCBalance
			--,ISNULL(POST.Balance,0)	PostMOCBalance

			,CASE WHEN ISNULL(POST.AdditionalProvision,0)=0 THEN ISNULL(PRE.AddlProvisionPer,0) ELSE ISNULL(POST.AdditionalProvision,0) END	PostMOCAddlProvisionPer
			--, POST.AdditionalProvision	PostMOCAddlProvisionPer

			,CASE WHEN ISNULL(POST.AdditionalProvisionAmount,0)=0 THEN ISNULL(PRE.AddlProvision,0) ELSE ISNULL(POST.AdditionalProvisionAmount,0) END	PostMOCAddlProvision
			--,POST.AdditionalProvisionAmount	PostMOCAddlProvision


			,POST.AppropriateSecurity  	PostMOCSecApp
			,CASE WHEN ISNULL(POST.FITL,'')='' THEN ISNULL(PRE.FlgFITL,'N') ELSE ISNULL(POST.FITL,'') END	PostMOCFlgFITL

			,CASE WHEN ISNULL(DFVAmount,0)=0 THEN ISNULL(PRE.DFVAmt,0) ELSE ISNULL(DFVAmount,0) END	PostMOCDFVAmt
			--,ISNULL(DFVAmount,0)	PostMOCDFVAmt

			,CASE WHEN ISNULL(CONVERT(VARCHAR(20),POST.RepossessionDate,103),'')='' THEN CONVERT(VARCHAR(20),PRE.RepossessionDate,103) ELSE CONVERT(VARCHAR(20),POST.RepossessionDate,103) END PostMOCRepossessionDate
			--,CONVERT(VARCHAR(20),POST.RepossessionDate,103)	PostMOCRepossessionDate	--


			,CASE WHEN ISNULL(CONVERT(VARCHAR(20),POST.RestructureDate,103),'')='' THEN CONVERT(VARCHAR(20),RestructureDt,103) ELSE CONVERT(VARCHAR(20),POST.RestructureDate,103) END PostMOCRestructureDt
			--,CONVERT(VARCHAR(20),POST.RestructureDate,103)	PostMOCRestructureDt
			
			,CASE WHEN ISNULL(CONVERT(VARCHAR(20),POST.OriginalDCCODate,103),'')='' THEN CONVERT(VARCHAR(20),OriginalEnvisagCompletionDt,103) ELSE CONVERT(VARCHAR(20),POST.RestructureDate,103) END PostMOCOriginalEnvisagCompletionDt
			--,CONVERT(VARCHAR(20),OriginalDCCODate,103)	PostMOCOriginalEnvisagCompletionDt

			,CASE WHEN ISNULL(CONVERT(VARCHAR(20),POST.ActualDCCODate,103),'')='' THEN CONVERT(VARCHAR(20),ActualCompletionDt,103) ELSE CONVERT(VARCHAR(20),POST.ActualDCCODate,103) END PostMOCRepossessionDate
			--,CONVERT(VARCHAR(20),ActualDCCODate,103)	PostMOCActualCompletionDt
			
			,CASE WHEN ISNULL(CONVERT(VARCHAR(20),POST.ExtendedDCCODate,103),'')='' THEN CONVERT(VARCHAR(20),RevisedCompletionDt,103) ELSE CONVERT(VARCHAR(20),POST.ActualDCCODate,103) END PostMOCRevisedCompletionDt
			--,CONVERT(VARCHAR(20),POST.ExtendedDCCODate,103)	PostMOCRevisedCompletionDt   

			,CASE WHEN ISNULL(POST.Infrastructure,'')='' THEN  ISNULL(PRE.FlgINFRA,'N') ELSE ISNULL(POST.Infrastructure,'N')  END PostMOCFlgINFRA
			--,POST.Infrastructure	PostMOCFlgINFRA

			,CASE WHEN ISNULL(POST.MOCReason,'')='' THEN  ISNULL(PRE.MOCReason,'') ELSE ISNULL(POST.MOCReason,'')  END PostMOCMOCReason
			--,POST.MOCReason	PostMOCMOCReason

			,'AccountList' TableName
			 FROM  #MocAccountCal_hist PRE
		

			 LEFT OUTER JOIN curdat.AdvAcRestructureDetail RES
					ON RES.EffectiveFromTimeKey <= @TImekey AND RES.EffectiveToTimeKey >= @TImekey
					AND RES.AccountEntityId = PRE.AccountEntityID

			LEFT OUTER JOIN AdvAcProjectDetail PRO 
					ON PRO.EffectiveFromTimeKey <= @TImekey AND PRO.EffectiveToTimeKey >= @TImekey
					AND PRO.RefAccountEntityId = PRE.AccountEntityID

			LEFT OUTER JOIN #MocAccountDataUpload POST
					ON POST.AccountEntityId = PRE.AccountEntityID

			 WHERE		PRE.EffectiveFromTimeKey<=@TIMEKEY AND PRE.EffectiveToTimeKey>=@TIMEKEY
					
					AND PRE.CustomerEntityId=@CustomerEntityId
	

	SELECT convert(varchar(10),getdate(),103) [CURDATE], 'CURDATE' as TableName
	
--END



GO