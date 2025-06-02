SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : Shubham Mankame
 CREATE DATE : 22-02-2024
 MODIFY DATE : 22-02-2024
 DESCRIPTION : SELECT DATA FROM AbsoluteBackdatedMOC 
 ===============================================*/
Create PROCEDURE [DataUpload].[AbsoluteBackdatedMOCUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

			IF @OperationFlag=2
			BEGIN
					SELECT 						
						AbsProvMOCEntityId
					   ,AccountEntityID
					   ,MOC_Date
					   ,UCIF_ID
					   ,CustomerID
					   ,SourceSystemCustomerID
					   ,NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
					   ,OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
					   ,CustomerACID
					   ,Branchcode
					   ,AdditionalProvision
					   ,ExistingProvision
					   ,FinalProvision
					   ,MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
					   ,AuthorisationStatus
					   ,EffectiveFromTimeKey
					   ,EffectiveToTimeKey
					   ,CreatedBy
					   ,DateCreated
					   ,ModifyBy
					   ,DateModified
					   ,ApprovedBy
					   ,DateApproved
					FROM DATAUPLOAD.AbsoluteBackdatedMOC TXN
					WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
					
					UNION

					SELECT 						
						txn.AbsProvMOCEntityId
					   ,AccountEntityID
					   ,MOC_Date
					   ,UCIF_ID
					   ,txn.CustomerID
					   ,SourceSystemCustomerID
					   ,NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
					   ,OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
					   ,txn.CustomerACID
					   ,Branchcode
					   ,AdditionalProvision
					   ,ExistingProvision
					   ,FinalProvision
					   ,MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
					   ,AuthorisationStatus
					   ,EffectiveFromTimeKey
					   ,EffectiveToTimeKey
					   ,CreatedBy
					   ,DateCreated
					   ,ModifyBy
					   ,DateModified
					   ,ApprovedBy
					   ,DateApproved
					FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod TXN
					INNER JOIN 
						(
							SELECT CUSTOMERID,CUSTOMERACID,AbsProvMOCEntityId,MAX(Entitykey)Entitykey
							FROM DataUpload.AbsoluteBackdatedMOC_Mod
							WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
							AND   AuthorisationStatus in('NP','MP','RM','1A','DP','1D')
							GROUP BY CustomerID,CustomerAcID,AbsProvMOCEntityId
						)B
			ON TXN.Entitykey = B.Entitykey			
			WHERE TXN.AuthorisationStatus IN('NP','MP','RM','1A')

			END
			ELSE IF @OperationFlag=20
			BEGIN

				SELECT 
						txn.AbsProvMOCEntityId
					   ,AccountEntityID
					   ,MOC_Date
					   ,UCIF_ID
					   ,txn.CustomerID
					   ,SourceSystemCustomerID
					   ,NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
					   ,OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
					   ,txn.CustomerACID
					   ,Branchcode
					   ,AdditionalProvision
					   ,ExistingProvision
					   ,FinalProvision
					   ,MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
					   ,AuthorisationStatus
					   ,EffectiveFromTimeKey
					   ,EffectiveToTimeKey
					   ,CreatedBy
					   ,DateCreated
					   ,ModifyBy
					   ,DateModified
					   ,ApprovedBy
					   ,DateApproved
				FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod TXN
				INNER JOIN 
				(
					SELECT CUSTOMERID,CUSTOMERACID,AbsProvMOCEntityId,MAX(Entitykey)Entitykey
					FROM DataUpload.AbsoluteBackdatedMOC_Mod
					WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
					AND   AuthorisationStatus in('1A')
					GROUP BY CustomerID,CustomerAcID,AbsProvMOCEntityId
				)B
				ON TXN.Entitykey = B.Entitykey
				WHERE ISNULL(ISNULL(TXN.ApprovedByLevel1,''),ISNULL(TXN.ModifyBy,'')) <> @UserId
					AND ISNULL(TXN.ModifyBy,TXN.CreatedBy) <> @UserId
					AND ISNULL(TXN.CreatedBy, '') <> @UserId

			END
			ELSE IF @OperationFlag=16
			BEGIN
				SELECT 
						txn.AbsProvMOCEntityId
					   ,AccountEntityID
					   ,MOC_Date
					   ,UCIF_ID
					   ,txn.CustomerID
					   ,SourceSystemCustomerID
					   ,NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
					   ,OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
					   ,txn.CustomerACID
					   ,Branchcode
					   ,AdditionalProvision
					   ,ExistingProvision
					   ,FinalProvision
					   ,MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
					   ,AuthorisationStatus
					   ,EffectiveFromTimeKey
					   ,EffectiveToTimeKey
					   ,CreatedBy
					   ,DateCreated
					   ,ModifyBy
					   ,DateModified
					   ,ApprovedBy
					   ,DateApproved
				FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod TXN
				INNER JOIN 
						(
							SELECT CUSTOMERID,CUSTOMERACID,AbsProvMOCEntityId,MAX(Entitykey)Entitykey
							FROM DataUpload.AbsoluteBackdatedMOC_Mod
							WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
							AND   AuthorisationStatus in('NP','MP','RM','DP')
							GROUP BY CustomerID,CustomerAcID,AbsProvMOCEntityId
						)B
			ON TXN.Entitykey = B.Entitykey						
			WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
				AND TXN.CreatedBy<>@UserId
			
-------------Line Added By Tarkeshwar Singh on 25 July 2024-----------
		Delete from AbsProvMOC_Auth where userid=@UserId

		Insert into AbsProvMOC_Auth
		(AccountEntityID
		,UCIF_ID
		,CustomerID
		,SourceSystemCustomerID
		,BranchCode
		,OriginalProvision
		,NetBalance
		,CustomerACID
		,ExistingProvision
		,AdditionalProvision
		,FinalProvision
		,MOCREASON
		,AbsProvMOCEntityId
		,MOC_DATE
		,UserId
		)
		Select
		AccountEntityID
		,UCIF_ID
		,TXN.CustomerID
		,SourceSystemCustomerID
		,BranchCode
		,OriginalProvision
		,NetBalance
		,TXN.CustomerACID
		,ExistingProvision
		,AdditionalProvision
		,FinalProvision
		,MOCREASON
		,TXN.AbsProvMOCEntityId
		,MOC_DATE
		,@UserId	
		FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod TXN
						INNER JOIN 
								(
									SELECT CUSTOMERID,CUSTOMERACID,AbsProvMOCEntityId,MAX(Entitykey)Entitykey
									FROM DataUpload.AbsoluteBackdatedMOC_Mod
									WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
									AND   AuthorisationStatus in('NP','MP','RM','DP')
									GROUP BY CustomerID,CustomerAcID,AbsProvMOCEntityId
								)B
					ON TXN.Entitykey = B.Entitykey						
					WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
						AND TXN.CreatedBy<>@UserId
						----------------------
END
END




GO