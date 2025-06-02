SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[LineCodeUploadGridData]
	 @Timekey INT
	,@UserLoginId VARCHAR(100)
	,@Menuid INT
	,@OperationFlag int
AS
--DECLARE @Timekey INT=49999
--	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
--	,@Menuid INT=161
BEGIN
		SET NOCOUNT ON;

    
 --Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
 -- where  Date=cast(getdate() as Date)

  Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')

    PRINT @Timekey 

--	IF (@OperationFlag=20) 

--BEGIN
--	SELECT * INTO #INT1 FROM(
--   SELECT  UniqueUploadID,UploadedBy
--   ,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload,
--   --,DateofUpload,
--   CASE WHEN  AuthorisationStatus='A' THEN 'Authorized'
--		WHEN  AuthorisationStatus='R' THEN 'Rejected'
--		WHEN  AuthorisationStatus='1A' THEN '1Authorized'
--		WHEN  AuthorisationStatus='NP' THEN 'Pending' ELSE NULL END AS AuthorisationStatus
--	---,Action
--	,UploadType
--	,IsNull(ModifyBy,CreatedBy)as CrModBy
--	,IsNull(DateModified,DateCreated)as CrModDate
--	,ISNULL(ApprovedBy,CreatedBy) as CrAppBy
--	,ISNULL(DateApproved,DateCreated) as CrAppDate
--	,ISNULL(ApprovedBy,ModifyBy) as ModAppBy
--	,ISNULL(DateApproved,DateModified) as ModAppDate
	
--   FROM ExcelUploadHistory
--   WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
--   and UploadType =CASE WHEN @Menuid=109942 THEN 'LineCode Upload'
--						ELSE  NULL END 
--   )   A
--   ORDER BY DateofUpload  DESC,CASE WHEN AuthorisationStatus='NP' THEN CAST(1 AS VARCHAR(50))
--                                WHEN AuthorisationStatus='A' THEN CAST(2 AS VARCHAR(50))
--                                WHEN AuthorisationStatus='R' THEN CAST(3 AS VARCHAR(50))
--								WHEN AuthorisationStatus='1A' THEN CAST (4 AS VARCHAR(50))
--                                ELSE (ROW_NUMBER () OVER(ORDER BY(AuthorisationStatus)+CAST(4 AS VARCHAR(50)))) 
--                                END ASC
				
	
	
	                     

--                                SELECT UniqueUploadID ,UploadedBy,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload,AuthorisationStatus,UploadType,
--								CrModBy,CrModDate,CrAppBy,CrAppDate,ModAppBy,ModAppDate
--                                FROM #INT1 Where AuthorisationStatus Not In ('Authorized','Rejected','Pending')
--                                 ORDER BY CASE WHEN AuthorisationStatus='Pending' THEN CAST(1 AS VARCHAR(50))
--                                WHEN AuthorisationStatus='Authorized' THEN CAST(2 AS VARCHAR(50))
--                                WHEN AuthorisationStatus='Rejected' THEN CAST(3 AS VARCHAR(50))
--								WHEN AuthorisationStatus='1Authorized' THEN CAST(4 AS VARCHAR(50))
--                                ELSE (ROW_NUMBER () OVER(ORDER BY(AuthorisationStatus)+CAST(4 AS VARCHAR(50)))) 
--                                END ASC,DateofUpload  DESC,UniqueUploadID Desc
			
--END
  
		--ELSE

		IF (@OperationFlag in(16))

BEGIN
print'1'

  SELECT * INTO #INT FROM(
   SELECT  UniqueUploadID,UploadedBy
   ,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload,
   --,DateofUpload,
   CASE WHEN  AuthorisationStatus='A' THEN 'Authorized'
		WHEN   AuthorisationStatus='R' THEN 'Rejected'
		WHEN  AuthorisationStatus='1A' THEN '1Authorized'
		WHEN  AuthorisationStatus='NP' THEN 'Pending' ELSE NULL END AS AuthorisationStatus
	---,Action
	,UploadType
	,IsNull(ModifyBy,CreatedBy)as CrModBy
	,IsNull(DateModified,DateCreated)as CrModDate
	,ISNULL(ApprovedBy,CreatedBy) as CrAppBy
	,ISNULL(DateApproved,DateCreated) as CrAppDate
	,ISNULL(ApprovedBy,ModifyBy) as ModAppBy
	,ISNULL(DateApproved,DateModified) as ModAppDate

   FROM ExcelUploadHistory
   WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
   and UploadType =CASE WHEN @Menuid=109942 THEN 'LineCode Upload'
						ELSE  NULL END 
   )   A
   ORDER BY DateofUpload  DESC,CASE WHEN AuthorisationStatus='NP' THEN CAST(1 AS VARCHAR(50))
       WHEN AuthorisationStatus='A' THEN CAST(2 AS VARCHAR(50))
                                WHEN AuthorisationStatus='R' THEN CAST(3 AS VARCHAR(50))
								WHEN  AuthorisationStatus='1A' THEN CAST(4 AS varchar(50))
                                ELSE (ROW_NUMBER () OVER(ORDER BY(AuthorisationStatus)+CAST(4 AS VARCHAR(50)))) 
                                END ASC


        --                        SELECT UniqueUploadID ,UploadedBy,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload,AuthorisationStatus,UploadType,
								--CrModBy,CrModDate,CrAppBy,CrAppDate,ModAppBy,ModAppDate
        --                        FROM #INT Where AuthorisationStatus Not In ('Authorized','Rejected','1Authorized')
        --                         ORDER BY CASE WHEN AuthorisationStatus='Pending' THEN CAST(1 AS VARCHAR(50))
        --                        WHEN AuthorisationStatus='Authorized' THEN CAST(2 AS VARCHAR(50))
        --                        WHEN AuthorisationStatus='Rejected' THEN CAST(3 AS VARCHAR(50))
								--WHEN  AuthorisationStatus='1Authorized' THEN CAST(4 AS VARCHAR(50))
        --                        ELSE (ROW_NUMBER () OVER(ORDER BY(AuthorisationStatus)+CAST(4 AS VARCHAR(50)))) 
        --                        END ASC,DateofUpload  DESC,UniqueUploadID Desc

		--Select '#INT',* from #INT
		

                                SELECT UniqueUploadID ,UploadedBy,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload,AuthorisationStatus,UploadType,
								CrModBy,CrModDate,CrAppBy,CrAppDate,ModAppBy,ModAppDate
                                FROM #INT Where AuthorisationStatus Not In ('Authorized','Rejected','1Authorized')
                                 ORDER BY  UniqueUploadID Desc
                                 
			
END  

END


GO