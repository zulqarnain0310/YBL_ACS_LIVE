SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[RP_Portfolio_DetailsSearchList] 
--Declare
						 @PAN_No	                Varchar(12)	= ''
						,@CustomerID				Varchar(20)	= ''
						--@PageNo         INT         = 1, 
						--@PageSize       INT         = 10, 
						,@OperationFlag  INT         
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */


			IF(@OperationFlag <> 16)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT     A.PAN_No,
							A.UCIC_ID,
							A.CustomerID,
							A.CustomerName,
							A.BankingArrangementAlt_Key,
							A.ArrangementDescription,
							A.BorrowerDefaultDate,
							A.LeadBankAlt_Key,
							A.BankName,
							A.DefaultStatusAlt_Key,
							A.DefaultStatus,
							A.ExposureBucketAlt_Key,
							A.BucketName,
							A.ReferenceDate,
							A.ReviewExpiryDate,
							A.RP_ApprovalDate,
							A.RPNatureAlt_Key,
							A.RpDescription,
							A.If_other,
							A.RP_ExpiryDate,
							A.RP_ImplDate,
							A.RP_ImplStatusAlt_Key,
							A.RP_ImplStatus,
							A.RP_failed,
							A.Revised_RP_Expiry_Date,
							A.Actual_Impl_Date,
							A.RP_OutOfDateAllBanksDeadline,
							A.IsBankExposure,
							A.AssetClassAlt_Key,
							A.AssetClassName,
							A.RiskReviewExpiryDate,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.PAN_No,
							A.UCIC_ID,
							A.CustomerID,
							A.CustomerName,
							A.BankingArrangementAlt_Key,
							C.ArrangementDescription,
							(case when convert(DATE,A.BorrowerDefaultDate)='' then NULL else Convert(VARCHAR(20),BorrowerDefaultDate,103) End) BorrowerDefaultDate,
							A.LeadBankAlt_Key,
							B.BankName,
							A.DefaultStatusAlt_Key,
							H.ParameterName DefaultStatus,
							A.ExposureBucketAlt_Key,
							D.BucketName,
							(case when convert(DATE,A.ReferenceDate)='' then NULL else Convert(VARCHAR(20),ReferenceDate,103) End) ReferenceDate,
							(case when convert(DATE,A.ReviewExpiryDate)='' then NULL else Convert(VARCHAR(20),ReviewExpiryDate,103) End) ReviewExpiryDate,
							(case when convert(DATE,A.RP_ApprovalDate)='' then NULL else Convert(VARCHAR(20),RP_ApprovalDate,103) End) RP_ApprovalDate,
							A.RPNatureAlt_Key,
							E.RPDescription,
							A.If_other,
							(case when convert(DATE,A.RP_ExpiryDate)='' then NULL else Convert(VARCHAR(20),RP_ExpiryDate,103) End) RP_ExpiryDate,
							(case when convert(DATE,A.RP_ImplDate)='' then NULL else Convert(VARCHAR(20),RP_ImplDate,103) End) RP_ImplDate,
							A.RP_ImplStatusAlt_Key,
							I.ParameterName RP_ImplStatus,
							A.RP_failed,
							(case when convert(DATE,A.Revised_RP_Expiry_Date)='' then NULL else Convert(VARCHAR(20),Revised_RP_Expiry_Date,103) End) Revised_RP_Expiry_Date,
							(case when convert(DATE,A.Actual_Impl_Date)='' then NULL else Convert(VARCHAR(20),Actual_Impl_Date,103) End) Actual_Impl_Date,
							(case when convert(DATE,A.RP_OutOfDateAllBanksDeadline)='' then NULL else Convert(VARCHAR(20),RP_OutOfDateAllBanksDeadline,103) End) RP_OutOfDateAllBanksDeadline,
							A.IsBankExposure,
							A.AssetClassAlt_Key,
							G.AssetClassName,
							(case when convert(DATE,A.RiskReviewExpiryDate)='' then NULL else Convert(VARCHAR(20),RiskReviewExpiryDate,103) End) RiskReviewExpiryDate,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                     FROM RP_Portfolio_Details A
						  left Join DimBankRP B ON A.LeadBankAlt_Key=B.BankRPAlt_Key
						  And B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
						  Inner Join DimBankingArrangement C ON A.BankingArrangementAlt_Key=C.BankingArrangementAlt_Key
						  And C.EffectiveFromTimeKey<=@Timekey And C.EffectiveToTimeKey>=@TimeKey
						  Inner Join DimExposureBucket D ON A.ExposureBucketAlt_Key=D.ExposureBucketAlt_Key
						  And D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@TimeKey
						  left Join DimResolutionPlanNature E ON A.RPNatureAlt_Key=E.RPNatureAlt_Key
						  And E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
						  LEFT Join DimAssetClass G ON A.AssetClassAlt_Key=G.AssetClassAlt_Key
						  And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
						  Inner Join (Select ParameterAlt_Key,ParameterName,'BorrowerDefaultStatus' as Tablename 
						  from DimParameter where DimParameterName='BorrowerDefaultStatus'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.DefaultStatusAlt_Key
						  left join (Select ParameterAlt_Key,ParameterName,'ImplementationStatus' as Tablename 
						  from DimParameter where DimParameterName='ImplementationStatus'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
						  ON I.ParameterAlt_Key=A.RP_ImplStatusAlt_Key
						  WHERE A.EffectiveFromTimeKey <= @TimeKey
                          AND A.EffectiveToTimeKey >= @TimeKey
                          AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						  AND ((A.DefaultStatusAlt_Key NOT IN(2) and A.RP_ImplStatusAlt_Key NOT IN(1,4)))
						 -- AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
					      --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
                     UNION
                     SELECT A.PAN_No,
							A.UCIC_ID,
							A.CustomerID,
							A.CustomerName,
							A.BankingArrangementAlt_Key,
							C.ArrangementDescription,
							(case when convert(DATE,A.BorrowerDefaultDate)='' then NULL else Convert(VARCHAR(20),BorrowerDefaultDate,103) End) BorrowerDefaultDate,
							A.LeadBankAlt_Key,
							B.BankName,
							A.DefaultStatusAlt_Key,
							H.ParameterName DefaultStatus,
							A.ExposureBucketAlt_Key,
							D.BucketName,
							(case when convert(DATE,A.ReferenceDate)='' then NULL else Convert(VARCHAR(20),ReferenceDate,103) End) ReferenceDate,
							(case when convert(DATE,A.ReviewExpiryDate)='' then NULL else Convert(VARCHAR(20),ReviewExpiryDate,103) End) ReviewExpiryDate,
							(case when convert(DATE,A.RP_ApprovalDate)='' then NULL else Convert(VARCHAR(20),RP_ApprovalDate,103) End) RP_ApprovalDate,
							A.RPNatureAlt_Key,
							E.RPDescription,
							A.If_other,
							(case when convert(DATE,A.RP_ExpiryDate)='' then NULL else Convert(VARCHAR(20),RP_ExpiryDate,103) End) RP_ExpiryDate,
							(case when convert(DATE,A.RP_ImplDate)='' then NULL else Convert(VARCHAR(20),RP_ImplDate,103) End) RP_ImplDate,
							A.RP_ImplStatusAlt_Key,
							I.ParameterName RP_ImplStatus,
							A.RP_failed,
							(case when convert(DATE,A.Revised_RP_Expiry_Date)='' then NULL else Convert(VARCHAR(20),Revised_RP_Expiry_Date,103) End) Revised_RP_Expiry_Date,
							(case when convert(DATE,A.Actual_Impl_Date)='' then NULL else Convert(VARCHAR(20),Actual_Impl_Date,103) End) Actual_Impl_Date,
							(case when convert(DATE,A.RP_OutOfDateAllBanksDeadline)='' then NULL else Convert(VARCHAR(20),RP_OutOfDateAllBanksDeadline,103) End) RP_OutOfDateAllBanksDeadline,
							A.IsBankExposure,
							A.AssetClassAlt_Key,
							G.AssetClassName,
							(case when convert(DATE,A.RiskReviewExpiryDate)='' then NULL else Convert(VARCHAR(20),RiskReviewExpiryDate,103) End) RiskReviewExpiryDate,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                     FROM RP_Portfolio_Details_Mod A
					left Join DimBankRP B ON A.LeadBankAlt_Key=B.BankRPAlt_Key
					And B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					Inner Join DimBankingArrangement C ON A.BankingArrangementAlt_Key=C.BankingArrangementAlt_Key
					And C.EffectiveFromTimeKey<=@Timekey And C.EffectiveToTimeKey>=@TimeKey
					Inner Join DimExposureBucket D ON A.ExposureBucketAlt_Key=D.ExposureBucketAlt_Key
					And D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@TimeKey
					left Join DimResolutionPlanNature E ON A.RPNatureAlt_Key=E.RPNatureAlt_Key
					And E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
					LEFT Join DimAssetClass G ON A.AssetClassAlt_Key=G.AssetClassAlt_Key
					And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
					Inner Join (Select ParameterAlt_Key,ParameterName,'BorrowerDefaultStatus' as Tablename 
					from DimParameter where DimParameterName='BorrowerDefaultStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)H
					ON H.ParameterAlt_Key=A.DefaultStatusAlt_Key
					left join (Select ParameterAlt_Key,ParameterName,'ImplementationStatus' as Tablename 
					from DimParameter where DimParameterName='ImplementationStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)I
					ON I.ParameterAlt_Key=A.RP_ImplStatusAlt_Key
					WHERE A.EffectiveFromTimeKey <= @TimeKey
                    AND A.EffectiveToTimeKey >= @TimeKey
					AND ((A.DefaultStatusAlt_Key NOT IN(2) and A.RP_ImplStatusAlt_Key NOT IN(1,4)))
					--AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
					--AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
                    --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                    AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CustomerID
                     )
                 ) A 
                      
                 
                 GROUP BY A.PAN_No,
							A.UCIC_ID,
							A.CustomerID,
							A.CustomerName,
							A.BankingArrangementAlt_Key,
							A.ArrangementDescription,
							A.BorrowerDefaultDate,
							A.LeadBankAlt_Key,
							A.BankName,
							A.DefaultStatusAlt_Key,
							A.DefaultStatus,
							A.ExposureBucketAlt_Key,
							A.BucketName,
							A.ReferenceDate,
							A.ReviewExpiryDate,
							A.RP_ApprovalDate,
							A.RPNatureAlt_Key,
							A.RpDescription,
							A.If_other,
							A.RP_ExpiryDate,
							A.RP_ImplDate,
							A.RP_ImplStatusAlt_Key,
							A.RP_ImplStatus,
							A.RP_failed,
							A.Revised_RP_Expiry_Date,
							A.Actual_Impl_Date,
							A.RP_OutOfDateAllBanksDeadline,
							A.IsBankExposure,
							A.AssetClassAlt_Key,
							A.AssetClassName,
							A.RiskReviewExpiryDate,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'AutomationMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         WHERE ISNULL(PAN_No, '') LIKE '%'+@PAN_No+'%'
                               AND ISNULL(CustomerID, '') LIKE '%'+@CustomerID+'%'
							  
							   							   
							   
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 
			 /*  IT IS Used For GRID Search which are Pending for Authorization    */


             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.PAN_No,
							A.UCIC_ID,
							A.CustomerID,
							A.CustomerName,
							A.BankingArrangementAlt_Key,
							A.ArrangementDescription,
							A.BorrowerDefaultDate,
							A.LeadBankAlt_Key,
							A.BankName,
							A.DefaultStatusAlt_Key,
							A.DefaultStatus,
							A.ExposureBucketAlt_Key,
							A.BucketName,
							A.ReferenceDate,
							A.ReviewExpiryDate,
							A.RP_ApprovalDate,
							A.RPNatureAlt_Key,
							A.RpDescription,
							A.If_other,
							A.RP_ExpiryDate,
							A.RP_ImplDate,
							A.RP_ImplStatusAlt_Key,
							A.RP_ImplStatus,
							A.RP_failed,
							A.Revised_RP_Expiry_Date,
							A.Actual_Impl_Date,
							A.RP_OutOfDateAllBanksDeadline,
							A.IsBankExposure,
							A.AssetClassAlt_Key,
							A.AssetClassName,
							A.RiskReviewExpiryDate,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.PAN_No,
							A.UCIC_ID,
							A.CustomerID,
							A.CustomerName,
							A.BankingArrangementAlt_Key,
							C.ArrangementDescription,
							(case when convert(DATE,A.BorrowerDefaultDate)='' then NULL else Convert(VARCHAR(20),BorrowerDefaultDate,103) End) BorrowerDefaultDate,
							A.LeadBankAlt_Key,
							B.BankName,
							A.DefaultStatusAlt_Key,
							H.ParameterName DefaultStatus,
							A.ExposureBucketAlt_Key,
							D.BucketName,
							(case when convert(DATE,A.ReferenceDate)='' then NULL else Convert(VARCHAR(20),ReferenceDate,103) End) ReferenceDate,
							(case when convert(DATE,A.ReviewExpiryDate)='' then NULL else Convert(VARCHAR(20),ReviewExpiryDate,103) End) ReviewExpiryDate,
							(case when convert(DATE,A.RP_ApprovalDate)='' then NULL else Convert(VARCHAR(20),RP_ApprovalDate,103) End) RP_ApprovalDate,
							A.RPNatureAlt_Key,
							E.RPDescription,
							A.If_other,
							(case when convert(DATE,A.RP_ExpiryDate)='' then NULL else Convert(VARCHAR(20),RP_ExpiryDate,103) End) RP_ExpiryDate,
							(case when convert(DATE,A.RP_ImplDate)='' then NULL else Convert(VARCHAR(20),RP_ImplDate,103) End) RP_ImplDate,
							A.RP_ImplStatusAlt_Key,
							I.ParameterName RP_ImplStatus,
							A.RP_failed,
							(case when convert(DATE,A.Revised_RP_Expiry_Date)='' then NULL else Convert(VARCHAR(20),Revised_RP_Expiry_Date,103) End) Revised_RP_Expiry_Date,
							(case when convert(DATE,A.Actual_Impl_Date)='' then NULL else Convert(VARCHAR(20),Actual_Impl_Date,103) End) Actual_Impl_Date,
							(case when convert(DATE,A.RP_OutOfDateAllBanksDeadline)='' then NULL else Convert(VARCHAR(20),RP_OutOfDateAllBanksDeadline,103) End) RP_OutOfDateAllBanksDeadline,
							A.IsBankExposure,
							A.AssetClassAlt_Key,
							G.AssetClassName,
							(case when convert(DATE,A.RiskReviewExpiryDate)='' then NULL else Convert(VARCHAR(20),RiskReviewExpiryDate,103) End) RiskReviewExpiryDate,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                     FROM RP_Portfolio_Details_Mod A
					 left Join DimBankRP B ON A.LeadBankAlt_Key=B.BankRPAlt_Key
					And B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					Inner Join DimBankingArrangement C ON A.BankingArrangementAlt_Key=C.BankingArrangementAlt_Key
					And C.EffectiveFromTimeKey<=@Timekey And C.EffectiveToTimeKey>=@TimeKey
					Inner Join DimExposureBucket D ON A.ExposureBucketAlt_Key=D.ExposureBucketAlt_Key
					And D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@TimeKey
					left Join DimResolutionPlanNature E ON A.RPNatureAlt_Key=E.RPNatureAlt_Key
					And E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
					LEFT Join DimAssetClass G ON A.AssetClassAlt_Key=G.AssetClassAlt_Key
					And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
					Inner Join (Select ParameterAlt_Key,ParameterName,'BorrowerDefaultStatus' as Tablename 
					from DimParameter where DimParameterName='BorrowerDefaultStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)H
					ON H.ParameterAlt_Key=A.DefaultStatusAlt_Key
					left join (Select ParameterAlt_Key,ParameterName,'ImplementationStatus' as Tablename 
					from DimParameter where DimParameterName='ImplementationStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)I
					ON I.ParameterAlt_Key=A.RP_ImplStatusAlt_Key
					WHERE A.EffectiveFromTimeKey <= @TimeKey
                    AND A.EffectiveToTimeKey >= @TimeKey
					AND ((A.DefaultStatusAlt_Key NOT IN(2) and A.RP_ImplStatusAlt_Key NOT IN(1,4)))
					--AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
					--AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
                    --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                    AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CustomerID
                     )
                 ) A 
                      
                 
                 GROUP BY	A.PAN_No,
							A.UCIC_ID,
							A.CustomerID,
							A.CustomerName,
							A.BankingArrangementAlt_Key,
							A.ArrangementDescription,
							A.BorrowerDefaultDate,
							A.LeadBankAlt_Key,
							A.BankName,
							A.DefaultStatusAlt_Key,
							A.DefaultStatus,
							A.ExposureBucketAlt_Key,
							A.BucketName,
							A.ReferenceDate,
							A.ReviewExpiryDate,
							A.RP_ApprovalDate,
							A.RPNatureAlt_Key,
							A.RpDescription,
							A.If_other,
							A.RP_ExpiryDate,
							A.RP_ImplDate,
							A.RP_ImplStatusAlt_Key,
							A.RP_ImplStatus,
							A.RP_failed,
							A.Revised_RP_Expiry_Date,
							A.Actual_Impl_Date,
							A.RP_OutOfDateAllBanksDeadline,
							A.IsBankExposure,
							A.AssetClassAlt_Key,
							A.AssetClassName,
							A.RiskReviewExpiryDate,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'AutomationMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         WHERE ISNULL(PAN_No, '') LIKE '%'+@PAN_No+'%'
                              AND ISNULL(CustomerID, '') LIKE '%'+@CustomerID+'%'
							   							   

                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)
             END;

	END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH
					BEGIN

					Declare @Cust_Id Varchar(20)=(Select CustomerID From RP_Portfolio_Details A
												  Inner Join (Select ParameterAlt_Key,ParameterName,'BorrowerDefaultStatus' as Tablename 
												  from DimParameter where DimParameterName='BorrowerDefaultStatus'
												  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)H
												  ON H.ParameterAlt_Key=A.DefaultStatusAlt_Key
												  left join (Select ParameterAlt_Key,ParameterName,'ImplementationStatus' as Tablename 
												  from DimParameter where DimParameterName='ImplementationStatus'
												  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
												  ON I.ParameterAlt_Key=A.RP_ImplStatusAlt_Key
												  Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
												  And A.PAN_No=@PAN_No 
												  AND ((A.DefaultStatusAlt_Key NOT IN(2) and A.RP_ImplStatusAlt_Key NOT IN(1,4)))
												  --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
												  --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
												 )

						EXEC RPLenderDetailsSelect @CustomerID=@Cust_Id

					END

     END;
GO