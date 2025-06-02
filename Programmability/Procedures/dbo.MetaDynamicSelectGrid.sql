SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



Create PROCEDURE [dbo].[MetaDynamicSelectGrid]

--DECLARE
	 @MenuId Int=710,
	 @TimeKey INT=25427,
	 @Mode TINYINT=1,
	 @ParentColumnValue varchar(50)='0',	 
	 @TabId INT = 0,
	 @SearchFrom VARCHAR(20)=N'Screen',
	 @UserLoginID VARCHAR(20) ='mischecker',
	 @XMLDocument XML=''
	 

 AS 
BEGIN
	SET DATEFORMAT DMY --Added by Tarkeshwar and shubham after discusion with amar sir 2024-04-25 against Observation for NPA DATe screen Not Successfully Filtering Records based on DAte due to Change int Date format from Frontend
	IF OBJECT_ID('TEMPDB..#SearchContitionTable') IS NOT NULL
				DROP TABLE #SearchContitionTable

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		,C.value('./SearchKey						[1]','VARCHAR(100)') SearchKey  
		,C.value('./SearchCondition					[1]','VARCHAR(100)') SearchCondition
		,C.value('./FirstSearchValue				[1]','VARCHAR(100)') FirstSearchValue
		,C.value('./SecondSearchValue				[1]','VARCHAR(100)') SecondSearchValue
		INTO #SearchContitionTable
		FROM @XMLDocument.nodes('/DataSet/DynamicGridDtls') AS t(c)


	 DECLARE @COUNT INT ,@COUNT1 INT =1, @SearchCondition VARCHAR(MAX)
	 SELECT @COUNT=ROW_NUMBER()OVER(ORDER BY Searchkey) FROM #SearchContitionTable

	 WHILE @COUNT1 <= @COUNT
	 BEGIN
		IF @SearchCondition <> ''
		BEGIN
			SET @SearchCondition = @SearchCondition + ' AND '
		END
		DECLARE @SearchK VARCHAR(100), @SearchC VARCHAR(100), @FirstSearchV VARCHAR(100), @SecondSearchV VARCHAR(100), @EndQueryString VARCHAR(100)
		SELECT @SearchK = SearchKey, @SearchC = SearchCondition, @FirstSearchV = FirstSearchValue, @SecondSearchV = SecondSearchValue FROM #SearchContitionTable WHERE RowNum=@COUNT1

		IF @SearchC = 'LIKE' 
			BEGIN 
				SET @EndQueryString = '''%' + @FirstSearchV + '%''' 
			END
		ELSE IF @SearchC = 'BETWEEN' 
			BEGIN 
				SET @EndQueryString = ' ''' + @FirstSearchV + ''' ' + ' AND ' + ' ''' + @SecondSearchV + ''' '
			END 		
		ELSE 
			BEGIN 
				SET @EndQueryString = '''' + @FirstSearchV + '''' 
			END

		SET @SearchCondition = ISNULL(@SearchCondition,'') + @SearchK + ' ' + @SearchC + ' ' + @EndQueryString
		
		
		SET @COUNT1 = @COUNT1 + 1
	 END
	 SELECT @SearchCondition
	--exec MetaDynamicSelectGrid @MenuId=6670,@TimeKey=49999,@Mode=N'2',@ParentColumnValue=3,@TabId=325
	DECLARE @SQL VARCHAR(MAX),
		@TableName varchar(500),
		@TableWithSchema varchar(50),
		@TableWithSchema_Mod varchar(50),
		@Schema varchar(5),
		@BaseColumn varchar(50),
		@EntityKey VARCHAR(50),
		@ChangeFields VARCHAR(200),
		@ParentColumn varchar(50)='',
		@ParentTable varchar(50),
		@IsScreenMenuId	CHAR(1)='N',
		@SelectColumns VARCHAR(MAX)

		--IF @SearchFrom = 'QuickAccess' AND @MenuId = 602
		--BEGIN
		--		SET @MenuId = 601
		--		SET @BaseColumn = @ParentColumn
		--		SET @ParentColumn = ''
		--END
	
		
	SET @ParentColumnValue = ISNULL(@ParentColumnValue,'0')
	SELECT @BaseColumn = ControlName FROM MetaDynamicScreenField where MenuId=@MenuId AND BaseColumnType='BASE' AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END  
											AND ValidCode='Y'
		SELECT @IsScreenMenuId = 'Y' FROM MetaDynamicScreenField where MenuId=@MenuId AND ControlName='ScreenMenuId' AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
								AND ValidCode='Y'
		
	SELECT @ParentColumn= SourceColumn,@ParentTable=SourceTable  from MetaDynamicScreenField where MenuId=@MenuId AND BaseColumnType='PARENT' 
				AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
				AND ValidCode='Y'
	
	--SELECT 	'BASECOLUMN',@BaseColumn		
	--SELECT 'ParentColumn',@ParentColumn	

	IF  OBJECT_ID('Tempdb..#TmmpQry') IS NOT NULL
			DROP TABLE #TmmpQry

	CREATE TABLE #TmmpQry ( SourceColumn varchar(50),SourceTable varchar(50),DataType varchar(50))
	
		PRINT @TabId
		INSERT INTO #TmmpQry (SourceColumn,SourceTable,DataType)
		SELECT DISTINCT c.SourceColumn, c.SourceTable ,
				B.NAME+ ''+
					(CASE 
						WHEN B.NAME IN ('VARCHAR','NVARCHAR','CHAR') 
							THEN  +'('+cast(A.max_length as varchar(4))+')'
						WHEN B.NAME IN ('decimal','numeric') 
							THEN  +'('+cast(A.precision as varchar(4))+','+CAST(A.scale as varchar(2))+')'
						ELSE '' END
					) AS Datatype
	FROM SYS.COLUMNS  A
		INNER JOIN SYS.types B 
			ON B.system_type_id=A.system_type_id
		INNER JOIN MetaDynamicScreenField C
			ON C.ControlName=A.name
		INNER JOIN MetaDynamicGrid D
			ON D.ControlId=C.ControlId
	WHERE MENUID=@MenuId
		AND ISNULL(C.ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(C.ParentcontrolID,0) END 
		AND ValidCode='Y'
		--AND (OBJECT_NAME(OBJECT_ID) NOT LIKE 'Dim%' AND (OBJECT_NAME(OBJECT_ID) NOT LIKE '%_Mod'))
		AND (OBJECT_NAME(OBJECT_ID) NOT LIKE '%_Mod')
		AND ISNULL(c.SourceColumn,'')<>'' 
		AND  OBJECT_NAME(OBJECT_ID)<>'ResSelect' AND B.NAME<>'sysname'
		AND OBJECT_NAME(A.OBJECT_ID) IN(SELECT SourceTable FROM MetaDynamicScreenField  
											WHERE MENUID=@MenuId AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
											AND SourceTable IS NOT NULL
											AND ValidCode='Y'
											GROUP BY SourceTable
						)


	
	  print '***********'


	  
	
		DECLARE @ColName VARCHAR(max)

		SELECT @ColName=STUFF((SELECT  ','+ m1.SourceColumn + ' ' +DataType
							FROM #TmmpQry m1
							FOR XML PATH('')),1,1,'')   
					FROM #TmmpQry M2
		
		SELECT @SelectColumns=STUFF((SELECT  ','+ m1.SourceColumn 
						FROM #TmmpQry m1
						FOR XML PATH('')),1,1,'')   
				FROM #TmmpQry M2

	
	PRINT @ColName +' Column name'
	IF  OBJECT_ID('Tempdb..#TmpGridSelect') IS NOT NULL
		DROP TABLE #TmpGridSelect

	--select * from #TmmpQry
	CREATE TABLE #TmpGridSelect (BaseColumn INT)


	SET @ColName = REPLACE(@ColName, 'VARCHAR(-1)', 'VARCHAR(MAX)')  --ADDED ON 18 APR 2018 BY HAMID FOR VARCHAR(-1)

	SET @SQL=' ALTER TABLE #TmpGridSelect ADD '+@ColName 
	PRINT @SQL
	EXEC (@SQL)

	print '***********2'
	--SELECT * FROM #TmpGridSelect

	ALTER TABLE #TmmpQry add IsMainTable char(1)

	UPDATE #TmmpQry SET IsMainTable= CASE WHEN SourceTable=@ParentTable THEN 'Y' ELSE 'N' END

	IF  OBJECT_ID('Tempdb..#TmpSrcTable') IS NOT NULL
		DROP TABLE #TmpSrcTable

	CREATE TABLE #TmpSrcTable (RowId TINYINT, SourceTable varchar(50))

	--SELECT * FROM #TmmpQry
	INSERT INTO #TmpSrcTable
	SELECT 1 , SourceTable FROM #TmmpQry WHERE IsMainTable='Y'

	DECLARE @RowId1 INT = (SELECT MAX(RowId) FROM #TmpSrcTable)
	INSERT INTO #TmpSrcTable
	SELECT ISNULL(@RowId1,0)+ROW_NUMBER() over (order by  SourceTable) AS RowId, SourceTable 
		FROM #TmmpQry WHERE IsMainTable='N'
		GROUP BY SourceTable

	--SELECT @BaseColumn,@ParentColumn
	--SELECT * FROM #TmpSrcTable
	--SELECT * FROM #TmmpQry
	
	DECLARE @RowId TINYINT=1
	
		WHILE @RowId<=(SELECT COUNT(1) FROM #TmpSrcTable)
			BEGIN		
					
					SELECT @TableName=SourceTable from #TmpSrcTable WHERE RowId=@RowId
				
					SELECT @EntityKey=NAME FROM SYS.columns WHERE OBJECT_NAME(OBJECT_ID)=@TableName AND IS_identity=1
					
					SELECT @TableWithSchema=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName
					SELECT @TableWithSchema_Mod=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName+'_Mod' , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName+'_Mod'
					
					--PRINT @ColName
					
					PRINT @ParentColumn + ' ParentColumn'
					PRINT @BaseColumn+' BaseColumn'
					PRINT @TableName+' TableName'
					PRINT CAST(@RowId AS VARCHAR) + ' RowId'
					IF @RowId=1
						BEGIN
							SELECT  @ColName=
							STUFF((
									SELECT  ' ,' +SourceColumn
										FROM #TmmpQry  A1
											WHERE SourceColumn<>@ParentColumn AND SourceColumn<>@BaseColumn
											AND SourceTable=@TableName
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2
						END					
					ELSE
						BEGIN
							SELECT  @ColName=STUFF((
									SELECT  ' ,A.' +SourceColumn +'=B.'+SourceColumn
										FROM #TmmpQry  A1
											WHERE SourceColumn<>@ParentColumn AND SourceColumn<>@BaseColumn
											AND SourceTable=@TableName
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2
						END

					PRINT '1'

					SET @ColName=RIGHT(@ColName,LEN(@ColName)-1)
					
					IF @RowId=1
						BEGIN
							
							--SET @ColName=	@EntityKey+','+@ColName
							print 'A1'

							SET @SQL='INSERT INTO  #TmpGridSelect( BaseColumn,'+ @ColName +')'
							
							
							SET @ColName='A.'+@ColName

							IF @Mode<>16 
								BEGIN			
								PRINT 'TRILOKI'
								   print @ParentColumn +' ParentColumn'
								   print @BaseColumn +'BaseColumn'
								   PRINT @ColName
									SET @SQL=ISNULL(@SQL,'')+ ' SELECT A.'+@BaseColumn+', '+  @ColName +' FROM  '+@TableWithSchema +' A ' 
									SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
									SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
									----SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN  @BaseColumn +'= ' +@ParentColumn  ELSE ' ' END  
								--	SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'<>' +@BaseColumn ELSE '' END
									SET @SQL=@SQL+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10))ELSE '' END
									
									SET @SQL=@SQL+' AND ISNULL(AuthorisationStatus,''A'')=''A'''
								
									/* ADDED QUICK SEARCH CONDITION*/
									IF @SearchCondition<>''
										BEGIN
											SET  @SQL=@SQL+ ' AND '+@SearchCondition
										END

									SET  @SQL=@SQL+ ' UNION '
									PRINT 'insert'+@SQL
									
								END
							
						
							SET @SQL=ISNULL(@SQL,'')+ ' SELECT A.'+ @BaseColumn+','+ @ColName +' FROM  '+@TableWithSchema_Mod+' A'   
							PRINT @SQL
							PRINT '11'
								
							SET @SQL=@SQL+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey + ','+@BaseColumn +' FROM ' +@TableWithSchema_Mod+' B WHERE ' 
															+ CASE WHEN @ParentColumnValue<>'0' THEN  @ParentColumn +'= ' +@ParentColumnValue  ELSE ' ' END  
															--+ CASE WHEN @ParentColumnValue<>'0' THEN  @BaseColumn +'= ' +@ParentColumn  ELSE ' ' END  
															--+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'<>' +@BaseColumn ELSE '' END  TEMP
															+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND B.ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END

															+CASE WHEN @ParentColumnValue<>'0' THEN ' AND ' ELSE ' ' END+ 'B.AuthorisationStatus IN(''NP'',''MP'',''DP'')'
															/* ADDED QUICK SEARCH CONDITION*/
															+ CASE WHEN @SearchCondition<>' ' THEN ' AND '+@SearchCondition ELSE  '' END

															+' GROUP BY B.'+@BaseColumn 
															+' ) B ON A. '
															+ @EntityKey +' = B.'+@EntityKey
							PRINT '11'+@SQL
							
						
							SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND A.'+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
							SET @SQL=@SQL+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
							SET @SQL=@SQL+ ' AND AuthorisationStatus IN (''NP'',''MP'',''DP'')'
					
						
							/* ADDED QUICK SEARCH CONDITION*/
							IF @SearchCondition<>''
								BEGIN
									SET  @SQL=@SQL+ ' AND '+@SearchCondition
								END
				
							PRINT 'insert in temp 122'+ @SQL
									
							EXEC (@SQL)
							
						END
					ELSE
						BEGIN
							PRINT 'UPDATE'
						
							SET @SQL='UPDATE A SET '+@ColName
							+' FROM #TmpGridSelect A '
							+' INNER JOIN '+ @TableWithSchema+ ' B ON (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							+' AND A.BaseColumn=B.'+@BaseColumn
							--+  CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
							+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
							+' AND ISNULL(AuthorisationStatus,''A'')=''A'''
							/* ADDED QUICK SEARCH CONDITION*/
							IF @SearchCondition<>''
								BEGIN
									SET  @SQL=@SQL+ ' AND '+@SearchCondition
								END							
							EXEC (@SQL)

							SET @SQL='UPDATE A SET '+@ColName
							+' FROM #TmpGridSelect A '
							+' INNER JOIN '+ @TableWithSchema_Mod+' B ON (EffectiveFromTimeKey<='+CAST(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							+' AND A.BaseColumn=B.'+@BaseColumn
							+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+  CAST(@MenuId AS VARCHAR(10)) ELSE '' END

							SET @SQL=@SQL+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey + ',C.'+@BaseColumn +' FROM ' +@TableWithSchema_Mod+' C ' 
															+' INNER JOIN #TmpGridSelect D ON D.BaseColumn=C.'+@BaseColumn
															+' WHERE C.AuthorisationStatus IN(''NP'',''MP'',''DP'')'
															+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
															+ CASE WHEN @SearchCondition<>' ' THEN ' AND '+@SearchCondition ELSE  '' END
															+' GROUP BY C.'+@BaseColumn 
															+' ) C ON C. '
															+ @EntityKey +' = B.'+@EntityKey
							SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							--SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
							SET @SQL=@SQL+' AND AuthorisationStatus IN (''NP'',''MP'',''DP'')'							
							+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
							/* ADDED QUICK SEARCH CONDITION*/
							IF @SearchCondition<>''
								BEGIN
									SET  @SQL=@SQL+ ' AND '+@SearchCondition
								END							
							PRINT 'abc'+ @SQL
						
								EXEC (@SQL)
							
						END					
				PRINT CAST(@RowId AS VARCHAR(10)) +'END RowId'
				SET @RowId=@RowId+1
				
			
			
			END
		

			DECLARE @UserLocation VARCHAR(10),@UserLocationCode VARCHAR(10) 
					
					SELECT @UserLocation= UserLocation 
					, @UserLocationCode = UserLocationCode
					FROM DimUserInfo
					WHERE EffectiveFromTimeKey <= @TimeKey
					AND EffectiveToTimeKey >= @TimeKey
					AND UserLoginID =  @UserLoginID

					--602,621,622
					--602,621,622,607,616,641
					--620,607,616,621,641,602,622  Menu's Under Operation
		IF @MenuId IN (602,621,622,607,616,641,620, 642) AND @SearchFrom='QuickAccess'
			BEGIN
					PRINT 'In MenuId 602,621,622,607,616,641' --602 622

					PRINT @MenuId
					PRINT @SearchFrom
					PRINT @Mode
					PRINT @TimeKey
				
					EXEC [DBO].[GetGridDataBasedOnMenuId] @MenuId=@MenuId, @SearchCondition=@SearchCondition, @SearchFrom=@SearchFrom, @Mode=@Mode, @TimeKey=@TimeKey

					--IF @Mode <>16
					--BEGIN
					--	BEGIN
					--		print cast(@Mode as VARCHAR(2)) + ' Mode'
							
					--		SELECT 'GridData' TableName
					--			, M.StockDataEntityId BaseColumn 
					--			, CustomerAcID
					--			, CustomerID
					--			, ICRABorrowerId
					--			, CustomerName
					--			, CONVERT(VARCHAR(10),StockStatementDate,103) StockStatementDate
					--			, StockValue
					--			, 'Y' IsMainTable
					--		FROM DataUpload.StockStatementDataUpload M
					--			WHERE  M.EffectiveFromTimeKey <= @TimeKey AND M.EffectiveToTimeKey >= @TimeKey
							
					--			AND ISNULL(M.AuthorisationStatus,'A')='A'
							
					--		UNION ALL

					--		SELECT 'GridData' TableName
					--			, B.StockDataEntityId BaseColumn 
					--			, CustomerAcID
					--			, CustomerID
					--			, ICRABorrowerId
					--			, CustomerName
					--			, CONVERT(VARCHAR(10),StockStatementDate,103) StockStatementDate
					--			, StockValue
					--			, 'N' IsMainTable
					--			FROM DataUpload.StockStatementDataUpload_Mod B
					--			INNER JOIN 
					--			(
					--				SELECT StockDataEntityId, MAX(Entitykey)EntityKey FROM DataUpload.StockStatementDataUpload_Mod
					--				WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
					--				AND AuthorisationStatus IN('NP','MP','DP','RM')
					--				GROUP BY StockDataEntityId
					--			)C ON  B.EntityKey = C.EntityKey
							
					--	END
						
					--END 
					--ELSE 
					--BEGIN
							
					--		PRINT CAST(@mode AS VARCHAR(2))+'mode'
					--		BEGIN
								
					--				SELECT 'GridData' TableName 
					--						, B.StockDataEntityId BaseColumn 
					--						, CustomerAcID
					--						, CustomerID
					--						, ICRABorrowerId
					--						, CustomerName
					--						, CONVERT(VARCHAR(10),StockStatementDate,103) StockStatementDate
					--						, StockValue	
					--						, 'Y' IsMainTable
					--				 FROM DataUpload.StockStatementDataUpload_Mod B
					--				INNER JOIN 
					--				(
					--					SELECT StockDataEntityId, MAX(Entitykey) Entitykey FROM DataUpload.StockStatementDataUpload_Mod
					--					WHERE 
					--					EffectiveFromTimeKey <=  @Timekey AND EffectiveToTimeKey >= @Timekey
					--					AND 
					--					AuthorisationStatus IN('NP','MP','DP','RM')
					--					GROUP BY StockDataEntityId
					--				)C
					--				ON B.Entitykey = c.Entitykey
								
					--		END
					--END 

			END

		ELSE IF @MenuId = 602
			BEGIN
				PRINT '602'
				PRINT CAST(@Mode AS VARCHAR(2)) +' Mode'
				SELECT 'GridData' TableName
								--, StockDataEntityId 
								,BaseColumn 
								, CustomerAcID
								, CustomerID
								, ICRABorrowerId
								, CustomerName
								, CONVERT(VARCHAR(10),StockStatementDate,103) StockStatementDate
								, StockValue

				FROM #TmpGridSelect	A	
			END 

		ELSE IF @MenuId = 710 AND @SearchFrom='QuickAccess'
		BEGIN
			PRINT '710'
		--	DECLARE @CustomerID VARCHAR(50),@CustomerName VARCHAR(250) 
			
		--	SET @SQL=''+' 
		--		SELECT	DISTINCT CAL.RefCustomerID		CustomerID
		--		,CAL.CustomerName			
		--		,ISNULL(CAL.BranchCode,'''')	BranchCode
		--		,BR.BranchName
		--		,Temp.BaseColumn
		--		,''GridData'' as TableName
		--FROM PRO.CustomerCal CAL
		--LEFT JOIN #TmpGridSelect Temp
		--	ON Temp.CustomerId=CAL.RefCustomerId
		--LEFT OUTER JOIN DimBranch BR
		--	ON CAL.BranchCode = BR.BranchCode '
			
		--	IF @SearchCondition<>''
		--		BEGIN
		--			SET @SearchCondition=REPLACE(@SearchCondition,'CustomerID','CAL.REFCustomerID')
		--			SET @SearchCondition=REPLACE(@SearchCondition,'CustomerName','CAL.CustomerName')

		--			SET  @SQL=@SQL+ ' WHERE '+  @SEARCHCONDITION --LIKE '%CUSTOMERID%' THEN +' CAL.REF' + @SEARCHCONDITION ELSE ' CAL.' + @SEARCHCONDITION END
		--		END							
		--			PRINT 'ABC'+ @SQL
						
								

		--	PRINT '************701 STARTED************'
		--	PRINT ''+@SQL+''
		--	EXEC (@SQL)
		IF @Mode = 16
		BEGIN
			
			PRINT '16'

			SELECT	T.CustomerID 
					,T.CustomerName
					,BR.BranchCode
					,BR.BranchName
					,BaseColumn
					,'GridData' TableName
			FROM #TmpGridSelect T
			INNER JOIN PRO.CustomerCal C
				ON C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
				AND C.RefCustomerID = T.CustomerID
			INNER JOIN DimBranch BR
				ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
				AND BR.BranchCode = C.BranchCode
		END
		ELSE
		BEGIN
			PRINT '<>16'
			IF ISNULL(@SearchCondition,'')<>''
			BEGIN

				DECLARE @MenuId710 VARCHAR(MAX)

				SELECT @SearchCondition =  REPLACE(@SearchCondition,'CustomerID','RefCustomerID')
				
				SELECT @SearchCondition = REPLACE(@SearchCondition,'CustomerName','C.CustomerName')
				
			
				

				SET @MenuId710 = 
				'SELECT   COALESCE(U.CustomerID, C.RefCustomerID) CustomerID 
						,COALESCE(U.CustomerName, C.CustomerName) CustomerName
						,BR.BranchCode
						,BR.BranchName
						,CASE	WHEN	ISNULL(U.BaseColumn	,'''')<>'''' 
								THEN	U.BaseColumn  
								ELSE	NULL 
						  END AS  BaseColumn
						,''GridData'' TableName 
				FROM PRO.CustomerCal C

				LEFT OUTER JOIN #TmpGridSelect U
						ON U.CustomerID = C.RefCustomerID

				LEFT OUTER JOIN DimBranch BR
						ON BR.EffectiveFromTimeKey <= '+CAST(@TimeKey AS VARCHAR(5))+' AND BR.EffectiveToTimeKey >= '+CAST(@TimeKey AS varchar(5))+'
						AND BR.BranchCode = C.BranchCode

				WHERE C.EffectiveFromTimeKey <= '+CAST(@TimeKey AS VARCHAR(5))+' AND C.EffectiveToTimeKey>= '+CAST(@TimeKey AS VARCHAR(5))

				SET @MenuId710 = @MenuId710 +' AND '+@SearchCondition



				PRINT @MenuId710
				EXEC (@MenuId710)

			END
			ELSE 
			BEGIN
				SELECT   COALESCE(U.CustomerID, C.RefCustomerID) CustomerID 
						,COALESCE(U.CustomerName, C.CustomerName) CustomerName
						,BR.BranchCode
						,BR.BranchName
						, BaseColumn
						,'GridData' TableName 
				FROM PRO.CustomerCal C

				LEFT OUTER JOIN #TmpGridSelect U
						ON U.CustomerID = C.RefCustomerID

				LEFT OUTER JOIN DimBranch BR
						ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
						AND BR.BranchCode = C.BranchCode

				WHERE C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey>= @TimeKey
				
			END
		END
END
ELSE
		BEGIN
			PRINT 'ELSE'
			SELECT 'GridData' TableName , * FROM #TmpGridSelect	
		END
			
END			
 

GO