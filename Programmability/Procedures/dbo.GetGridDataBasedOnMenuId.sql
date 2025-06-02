SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



Create PROC [dbo].[GetGridDataBasedOnMenuId]
@MenuId AS Int
, @SearchFrom VARCHAR(500)=''
, @Mode Int =''
, @TimeKey Int = 49999
,@SearchCondition VARCHAR(MAX)=''
AS
BEGIN

	DECLARE @SQL VARCHAR(MAX)=''

		/* Stock Statement Details */
		IF @MenuId = 602 AND @SearchFrom='QuickAccess'
		BEGIN
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'
						SET @SQL = 
						'SELECT ''GridData'' TableName
							, M.StockDataEntityId BaseColumn 
							, CustomerAcID
							, CustomerID
							, ICRABorrowerId
							, CustomerName
							, CONVERT(VARCHAR(10),StockStatementDate,103) StockStatementDate
							, StockValue
							, ISNULL(ModifiedBy,CreatedBy) CrModApBy
							, AuthorisationStatus
							, ''Y'' IsMainTable
						FROM DataUpload.StockStatementDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''
						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)
							END
						SET @SQL = @SQL+'UNION ALL

						SELECT ''GridData'' TableName
							, B.StockDataEntityId BaseColumn 
							, CustomerAcID
							, CustomerID
							, ICRABorrowerId
							, CustomerName
							, CONVERT(VARCHAR(10),StockStatementDate,103) StockStatementDate
							, StockValue
							, ISNULL(ModifiedBy,CreatedBy) CrModApBy
							, AuthorisationStatus
							, ''N'' IsMainTable
							FROM DataUpload.StockStatementDataUpload_Mod B
							INNER JOIN 
							(
								SELECT StockDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.StockStatementDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY StockDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									PRINT @SQL
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END
					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN
							SET @SQL = 'SELECT ''GridData'' TableName 
										, B.StockDataEntityId BaseColumn 
										, CustomerAcID
										, CustomerID
										, ICRABorrowerId
										, CustomerName
										, CONVERT(VARCHAR(10),StockStatementDate,103) StockStatementDate
										, StockValue	
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
									FROM DataUpload.StockStatementDataUpload_Mod B
								INNER JOIN 
								(
									SELECT StockDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.StockStatementDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY StockDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END

						END
				END 


		END

		/* Review Details */ 
		ELSE IF @MenuId = 622 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT 'Review Details FROM GetGridDataBasedOnMenuId SP'
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'
							
						SET @SQL = 'SELECT ''GridData'' TableName
										, M.ReviewDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
						FROM DataUpload.ReviewRenewalDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''

						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)
							END
						SET @SQL = @SQL+'UNION ALL

						SELECT ''GridData'' TableName
										, B.ReviewDataEntityId BaseColumn 
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''N'' IsMainTable
							FROM DataUpload.ReviewRenewalDataUpload_Mod B
							INNER JOIN 
							(
								SELECT ReviewDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.ReviewRenewalDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY ReviewDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END

					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN
								
								SET @SQL = 'SELECT ''GridData'' TableName 
										, B.ReviewDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
									FROM DataUpload.ReviewRenewalDataUpload_Mod B
								INNER JOIN 
								(
									SELECT ReviewDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.ReviewRenewalDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY ReviewDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
								IF ISNULL(@SearchCondition,'')<>''
								BEGIN
									
										SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
										EXEC(@SQL)
								END
								ELSE 
								BEGIN
									
									EXEC(@SQL)
								END

						END
				END 

		END

		/* Fraud Details */ 
		ELSE IF @MenuId = 621 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT 'FROM GetGridDataBasedOnMenuId SP'
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'
							
						SET @SQL = 'SELECT ''GridData'' TableName
										, M.FraudAccountDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
						FROM DataUpload.FraudAccountsDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''

						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)
							END
						SET @SQL = @SQL+'UNION ALL

						SELECT ''GridData'' TableName
										, B.FraudAccountDataEntityId BaseColumn 
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''N'' IsMainTable
							FROM DataUpload.FraudAccountsDataUpload_Mod B
							INNER JOIN 
							(
								SELECT FraudAccountDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.FraudAccountsDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY FraudAccountDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END

					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN
								
								SET @SQL = 'SELECT ''GridData'' TableName 
										, B.FraudAccountDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ''Y'' IsMainTable
									FROM DataUpload.FraudAccountsDataUpload_Mod B
								INNER JOIN 
								(
									SELECT FraudAccountDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.FraudAccountsDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY FraudAccountDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
								IF ISNULL(@SearchCondition,'')<>''
								BEGIN
									
										SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
										EXEC(@SQL)
								END
								ELSE 
								BEGIN
									
									EXEC(@SQL)
								END

						END
				END 

		END

		/* Security Details */ 
		ELSE IF @MenuId = 607 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT 'FROM GetGridDataBasedOnMenuId SP'
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'
							
						SET @SQL = 'SELECT ''GridData'' TableName
										, M.SecurityDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
						FROM DataUpload.SecurityDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''

						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)
							END
						SET @SQL = @SQL+'UNION ALL

						SELECT ''GridData'' TableName
										, B.SecurityDataEntityId BaseColumn 
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''N'' IsMainTable
							FROM DataUpload.SecurityDataUpload_Mod B
							INNER JOIN 
							(
								SELECT SecurityDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.SecurityDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY SecurityDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									PRINT @SQL
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
								PRINT @SQL	
								EXEC(@SQL)
							END

					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN
								
								SET @SQL = 'SELECT ''GridData'' TableName 
										, B.SecurityDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
									FROM DataUpload.SecurityDataUpload_Mod B
								INNER JOIN 
								(
									SELECT SecurityDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.SecurityDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY SecurityDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
								IF ISNULL(@SearchCondition,'')<>''
								BEGIN
									
										SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
										EXEC(@SQL)
								END
								ELSE 
								BEGIN
									
									EXEC(@SQL)
								END

						END
				END 

		END

		/* Provision percent for corporate facilities */
		ELSE IF @MenuId = 616 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT 'FROM GetGridDataBasedOnMenuId SP'
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'
							
						SET @SQL = 'SELECT ''GridData'' TableName
										, M.ProvisionDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
						FROM DataUpload.ProvisionDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''

						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)
							END
						SET @SQL = @SQL+' UNION ALL

						SELECT ''GridData'' TableName
										, B.ProvisionDataEntityId BaseColumn 
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''N'' IsMainTable
							FROM DataUpload.ProvisionDataUpload_Mod B
							INNER JOIN 
							(
								SELECT ProvisionDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.ProvisionDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY ProvisionDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END

					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN
								
								SET @SQL = 'SELECT ''GridData'' TableName 
										, B.ProvisionDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
									FROM DataUpload.ProvisionDataUpload_Mod B
								INNER JOIN 
								(
									SELECT ProvisionDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.ProvisionDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY ProvisionDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
								IF ISNULL(@SearchCondition,'')<>''
								BEGIN
									
										SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
										EXEC(@SQL)
								END
								ELSE 
								BEGIN
									
									EXEC(@SQL)
								END

						END
				END 

		END

		/* Repossession of Assets Details */
		ELSE IF @MenuId = 641 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT 'FROM GetGridDataBasedOnMenuId SP'
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'
							
						SET @SQL = 'SELECT ''GridData'' TableName
										, M.RePossessedDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, CustomerAcID
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
						FROM DataUpload.RePossessedAccountDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''

						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)
							END
						SET @SQL = @SQL+' UNION ALL

						SELECT ''GridData'' TableName
										, B.RePossessedDataEntityId BaseColumn 
										, CustomerID
										, CustomerName
										, CustomerAcID
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''N'' IsMainTable
							FROM DataUpload.RePossessedAccountDataUpload_Mod B
							INNER JOIN 
							(
								SELECT RePossessedDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.RePossessedAccountDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY RePossessedDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END

					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN
								
								SET @SQL = 'SELECT ''GridData'' TableName 
										, B.RePossessedDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, CustomerAcID
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
									FROM DataUpload.RePossessedAccountDataUpload_Mod B
								INNER JOIN 
								(
									SELECT RePossessedDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.RePossessedAccountDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY RePossessedDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
								IF ISNULL(@SearchCondition,'')<>''
								BEGIN
									
										SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
										EXEC(@SQL)
								END
								ELSE 
								BEGIN
									
									EXEC(@SQL)
								END

						END
				END 

		END

		/* Restructure Details */
		ELSE IF @MenuId = 620 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT 'FROM GetGridDataBasedOnMenuId SP'
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'
							
						SET @SQL = 'SELECT ''GridData'' TableName
										, M.RestructureDataEntityId BaseColumn
										, CustomerID
										, CustomerAcID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
						FROM DataUpload.RestructureDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''

						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)
							END
						SET @SQL = @SQL+' UNION ALL

						SELECT ''GridData'' TableName
										, B.RestructureDataEntityId BaseColumn 
										, CustomerID
										, CustomerAcID
										, CustomerName
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''N'' IsMainTable
							FROM DataUpload.RestructureDataUpload_Mod B
							INNER JOIN 
							(
								SELECT RestructureDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.RestructureDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY RestructureDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END

					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN
								
								SET @SQL = 'SELECT ''GridData'' TableName 
										, B.RestructureDataEntityId BaseColumn
										, CustomerID
										, CustomerName
										, CustomerAcID
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
									FROM DataUpload.RestructureDataUpload_Mod B
								INNER JOIN 
								(
									SELECT RestructureDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.RestructureDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY RestructureDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
								IF ISNULL(@SearchCondition,'')<>''
								BEGIN
									
										SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
										EXEC(@SQL)
								END
								ELSE 
								BEGIN
									
									EXEC(@SQL)
								END

						END
				END 

		END

		/* NPA Date Details */
		ELSE IF @MenuId = 642 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT 'FROM GetGridDataBasedOnMenuId SP'
				PRINT @MenuId
				PRINT @SearchFrom
				PRINT @Mode
				PRINT @TimeKey
				
				IF @Mode <>16
				BEGIN
					BEGIN
						print cast(@Mode as VARCHAR(2)) + ' Mode'                      --Added by Shubham on 2024-01-10 for NPA date Reason Storing
							
						SET @SQL = 'SELECT ''GridData'' TableName
										, M.NpaDateDataEntityId BaseColumn
										, UCIF_ID
										, CONVERT(VARCHAR(10),NPADate,103) NPADate
										, NPADATECHANGEREASON
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
						FROM DataUpload.NPADateDataUpload M
							WHERE  M.EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND M.EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
							
							AND ISNULL(M.AuthorisationStatus,''A'')=''A'''

						IF ISNULL(@SearchCondition,'')<>''
							BEGIN
								SET @SQL = ISNULL(@SQL,'') + SPACE(1) + 'AND ' + @SearchCondition +SPACE(1)               --Added by Shubham on 2024-01-10 for NPA date Reason Storing
							END
						SET @SQL = @SQL+' UNION ALL

						SELECT ''GridData'' TableName
										, B.NpaDateDataEntityId BaseColumn 
										, UCIF_ID
										, CONVERT(VARCHAR(10),NPADate,103) NPADate
										, NPADATECHANGEREASON
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''N'' IsMainTable
							FROM DataUpload.NPADateDataUpload_Mod B
							INNER JOIN 
							(
								SELECT NpaDateDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.NPADateDataUpload_Mod
								WHERE EffectiveFromTimeKey <= '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
								AND AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
								GROUP BY NpaDateDataEntityId
							)C ON  B.EntityKey = C.EntityKey'

							IF ISNULL(@SearchCondition,'')<>''
							BEGIN
									
									SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
									EXEC(@SQL)
							END
							ELSE 
							BEGIN
									
								EXEC(@SQL)
							END

					END
						
				END 
				ELSE 
				BEGIN
							
						PRINT CAST(@mode AS VARCHAR(2))+'mode' 
						BEGIN                                            --Added by Shubham on 2024-01-10 for NPA date Reason Storing
								
								SET @SQL = 'SELECT ''GridData'' TableName 
										, B.NpaDateDataEntityId BaseColumn
										, UCIF_ID
										, CONVERT(VARCHAR(10),NPADate,103) NPADate
										, NPADATECHANGEREASON                         
										, ISNULL(ModifiedBy,CreatedBy) CrModApBy
										, AuthorisationStatus
										, ''Y'' IsMainTable
									FROM DataUpload.NPADateDataUpload_Mod B
								INNER JOIN 
								(
									SELECT NpaDateDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.NPADateDataUpload_Mod
									WHERE 
									EffectiveFromTimeKey <=  '+CAST(@Timekey AS VARCHAR(10))+' AND EffectiveToTimeKey >= '+CAST(@Timekey AS VARCHAR(10))+'
									AND 
									AuthorisationStatus IN(''NP'',''MP'',''DP'',''RM'')
									GROUP BY NpaDateDataEntityId
								)C
								ON B.Entitykey = c.Entitykey'
								
								IF ISNULL(@SearchCondition,'')<>''
								BEGIN
									
										SET @SQL = ISNULL(@SQL,'')+SPACE(1)+'AND ' +@SearchCondition
										EXEC(@SQL)
								END
								ELSE 
								BEGIN
									
									EXEC(@SQL)
								END

						END
				END 

		END

END
GO