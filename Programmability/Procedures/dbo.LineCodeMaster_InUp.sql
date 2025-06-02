SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_rename 'LineCodeMaster_InUp','LineCodeMaster_InUp_04032022'  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
CREATE PROC [dbo].[LineCodeMaster_InUp]  
  
--Declare  
        
      @CodeType    VARCHAR(100)=''  
      ,@ReviewLineCodeAlt_Key INT=0  
      ,@ReviewLineCode   VARCHAR(200)  
                        ,@ReviewLineCodeName VARCHAR(200)  
                        ,@Source VARCHAR(50)  
      ---------D2k System Common Columns  --  
      ,@Remark     VARCHAR(500) = ''  
      --,@MenuID     SMALLINT  = 0  change to Int  
      ,@MenuID                    Int=0  
      ,@OperationFlag    TINYINT   = 0  
      ,@AuthMode     CHAR(1)   = 'N'  
      ,@EffectiveFromTimeKey  INT  = 0  
      ,@EffectiveToTimeKey  INT  = 0  
      ,@TimeKey     INT  = 0  
      ,@CrModApBy     VARCHAR(20)  =''  
      ,@ScreenEntityId   INT    =null  
      ,@Result     INT    =0 OUTPUT  
        
        
AS  
BEGIN  
 SET NOCOUNT ON;  
  PRINT 1  
   
  SET DATEFORMAT DMY  
   
  DECLARE   
      @AuthorisationStatus  varchar(5)   = NULL   
      ,@CreatedBy     VARCHAR(20)  = NULL  
      ,@DateCreated    SMALLDATETIME = NULL  
      ,@ModifiedBy    VARCHAR(20)  = NULL  
      ,@DateModified    SMALLDATETIME = NULL  
      ,@ApprovedBy    VARCHAR(20)  = NULL  
      ,@DateApproved    SMALLDATETIME = NULL  
      ,@ErrorHandle    int    = 0  
      ,@ExEntityKey    int    = 0    
        
------------Added for Rejection Screen  29/06/2020   ----------  
  
  DECLARE   @Uniq_EntryID   int = 0  
      ,@RejectedBY   Varchar(50) = NULL  
      ,@RemarkBy    Varchar(50) = NULL  
      ,@RejectRemark   Varchar(200) = NULL  
      ,@ScreenName   Varchar(200) = NULL  
  
    SET @ScreenName = 'GLProductCodeMaster'  
  
    DECLARE @DelStatus CHAR(2)=''  
    DECLARE @CurrRecordFromTimeKey smallint=0  
    DECLARE @CurEntityKey INT=0  
  
    DECLARE @IsAvailable CHAR(1)='N'  
      ,@IsSCD2 CHAR(1)='N'  
  
 -------------------------------------------------------------  
  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')   
  
 SET @EffectiveFromTimeKey  = @TimeKey  
  
 SET @EffectiveToTimeKey = 49999  
              
 PRINT 'A'  
  
   DECLARE @AppAvail CHAR  
     SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)  
    IF(@AppAvail='N')                           
     BEGIN  
      SET @Result=-11  
      RETURN @Result  
     END  
IF ( @CodeType='CAM Renewal Code')   -----DimLineCodeReview 1  
 BEGIN  
 IF @OperationFlag=1  --- add  
 BEGIN  
 PRINT 1  
  -----CHECK DUPLICATE  
  IF EXISTS(                      
     SELECT  1 FROM DimLineCodeReview   
     WHERE  ---ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
      --AND 
	  ReviewLineCode=@ReviewLineCode  
     --AND ReviewLineCodeName=@ReviewLineCodeName  
     AND ISNULL(AuthorisationStatus,'A')='A'   
     and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey  
     UNION  
     SELECT  1 FROM DimLineCodeReview_Mod    
     WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
     --AND  ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
        AND
	  ReviewLineCode=@ReviewLineCode  
      --AND ReviewLineCodeName=@ReviewLineCodeName  
      AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM')   
    )   
    BEGIN  
       PRINT 2  
     SET @Result=-4  
     RETURN @Result -- USER ALEADY EXISTS  
    END  
  ELSE  
   BEGIN  
      PRINT 3  
  
      SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(ReviewLineCodeAlt_Key),0)+1 from   
            (Select ReviewLineCodeAlt_Key from DimLineCodeReview  
             UNION   
             Select ReviewLineCodeAlt_Key from DimLineCodeReview_Mod  
            )A)  
  
   END  
   
 END  
  
 IF @OperationFlag=2   
 BEGIN  
  
 PRINT 1  
  
  --UPDATE TEMP   
  --SET TEMP.ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
  -- FROM #final TEMP  
  
 END  
   
END  
  
IF ( @CodeType='Stock Statement Code')   -------DimLinecodeStockStatement 2  
 BEGIN  
 IF @OperationFlag=1  --- add  
 BEGIN  
 PRINT 1  
  -----CHECK DUPLICATE  
  IF EXISTS(                      
     SELECT  1 FROM DimLinecodeStockStatement   
     WHERE  --StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
     
	 StockLineCode=@ReviewLineCode  
       
     AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey  
     UNION  
     SELECT  1 FROM DimLinecodeStockStatement_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
      --AND  StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
      and StockLineCode=@ReviewLineCode  
      AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM')   
    )   
    BEGIN  
       PRINT 2  
     SET @Result=-4  
     RETURN @Result -- USER ALEADY EXISTS  
    END  
  ELSE  
   BEGIN  
      PRINT 3  
  
      SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(StockLineCodeAlt_Key),0)+1 from   
            (Select StockLineCodeAlt_Key from DimLinecodeStockStatement  
             UNION   
             Select StockLineCodeAlt_Key from DimLinecodeStockStatement_Mod  
            )A)  
  
  
  
  
  
   END  
   
 END  
   
  
 IF @OperationFlag=2   
 BEGIN  
  
 PRINT 1  
  
  --UPDATE TEMP   
  --SET TEMP.ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
  -- FROM #final TEMP  
  
 END  
 --select * from #final  
 --select * from TEMP  
END  
------------  
  
IF ( @CodeType='Product Code')   -------DimLineProductCodeReview  3  
               
 BEGIN  
 IF @OperationFlag=1  --- add  
 BEGIN  
 PRINT 1  
  -----CHECK DUPLICATE  
  IF EXISTS(                      
     SELECT  1 FROM DimLineProductCodeReview   
     WHERE  --ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
      ReviewLineProductCode=@ReviewLineCode  
     AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey  
     UNION  
     SELECT  1 FROM DimLineProductCodeReview_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
      --AND  ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
      and ReviewLineProductCode=@ReviewLineCode  
      AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM')   
    )   
    BEGIN  
       PRINT 2  
     SET @Result=-4  
     RETURN @Result -- USER ALEADY EXISTS  
    END  
  ELSE  
   BEGIN  
      PRINT 3  
  
      SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(ReviewLineProductCodeAlt_Key),0)+1 from   
            (Select ReviewLineProductCodeAlt_Key from DimLineProductCodeReview  
             UNION   
             Select ReviewLineProductCodeAlt_Key from DimLineProductCodeReview_Mod  
            )A)  
  
  
   END  
   
 END  
   
  
 IF @OperationFlag=2   
 BEGIN  
  
 PRINT 1  
  
  --UPDATE TEMP   
  --SET TEMP.ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
  -- FROM #final TEMP  
  
 END  
 --select * from #final  
 --select * from TEMP  
END  
  
-------------  
 BEGIN TRY  
 BEGIN TRANSACTION   
 -----  
IF (@CodeType='CAM Renewal Code')  
 BEGIN   
 PRINT 3   
  --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
 IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD  
  BEGIN  
         PRINT 'Add'  
      SET @CreatedBy =@CrModApBy   
      SET @DateCreated = GETDATE()  
      SET @AuthorisationStatus='NP'  
  
      GOTO ReviewLineCode_Insert  
     ReviewLineCode_Insert_Add:  
   END  
  
  
   ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE  
   BEGIN  
    Print 4  
    SET @CreatedBy= @CrModApBy  
    SET @DateCreated = GETDATE()  
    Set @Modifiedby=@CrModApBy     
    Set @DateModified =GETDATE()   
  
     PRINT 5  
  
     IF @OperationFlag = 2  
      BEGIN  
       PRINT 'Edit'  
       SET @AuthorisationStatus ='MP'  
         
      END  
  
     ELSE  
      BEGIN  
       PRINT 'DELETE'  
       SET @AuthorisationStatus ='DP'  
         
      END  
  
      ---FIND CREATED BY FROM MAIN TABLE  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DimLineCodeReview    
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  
    ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
    IF ISNULL(@CreatedBy,'')=''  
    BEGIN  
     PRINT 'NOT AVAILABLE IN MAIN'  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DimLineCodeReview_Mod   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','A','RM')  
                 
    END  
    ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE  
     BEGIN  
            Print 'AVAILABLE IN MAIN'  
      ----UPDATE FLAG IN MAIN TABLES AS MP  
      UPDATE DimLineCodeReview  
       SET AuthorisationStatus=@AuthorisationStatus  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  
     END  
  
     --UPDATE NP,MP  STATUS   
     IF @OperationFlag=2  
     BEGIN   
  
      UPDATE DimLineCodeReview_Mod  
       SET AuthorisationStatus='FM'  
       ,ModifiedBy=@Modifiedby  
       ,DateModified=@DateModified  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
        AND AuthorisationStatus IN('NP','MP','RM')  
     END  
  	     IF @OperationFlag=3
					BEGIN	
					
						IF NOT EXISTS(SELECT 1 FROM DimLineCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND  ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key )
							BEGIN
					           
							   UPDATE DimLineCodeReview_Mod
									SET EffectiveToTimeKey=@TimeKey-1
									,ModifiedBy=@Modifiedby
									,DateModified=@DateModified
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key 
										AND AuthorisationStatus IN('NP','MP','RM')

                                SET @Result=1
								COMMIT TRAN
					            RETURN @Result
							  END
							  
					BEGIN	

						UPDATE DimLineCodeReview_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key 
								AND AuthorisationStatus IN('NP','MP','RM')
						
					END

								 
                    
								
								
					END
     GOTO ReviewLineCode_Insert  
     ReviewLineCode_Insert_Edit_Delete:  
    END  
  
  ELSE IF @OperationFlag =3 AND @AuthMode ='N'  
  BEGIN  
  -- DELETE WITHOUT MAKER CHECKER  
             
      SET @Modifiedby   = @CrModApBy   
      SET @DateModified = GETDATE()   
  
      UPDATE DimLineCodeReview SET  
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
      
      UPDATE DimLineCodeReview_Mod SET  
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
      
  end  
  
  		ELSE IF @OperationFlag =3 AND @AuthMode ='Y'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

							UPDATE DimLineCodeReview_Mod
							SET AuthorisationStatus=@AuthorisationStatus
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key 
								--AND AuthorisationStatus IN('DP')

					  	UPDATE DimLineCodeReview
							SET AuthorisationStatus='DP'
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key 
								--AND AuthorisationStatus IN('DP')

						--UPDATE DimBranch SET
						--			ModifiedBy =@Modifiedby 
						--			,DateModified =@DateModified 
						--			,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						--		WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND BranchAlt_Key=@BranchAlt_Key
					GOTO ReviewLineCode_Insert
					

		end
  ----------------------------------NEW ADD FIRST LVL AUTH------------------  
  --ELSE IF @OperationFlag=21 AND @AuthMode ='Y'   
  --BEGIN  
  --  SET @ApprovedBy    = @CrModApBy   
  --  SET @DateApproved  = GETDATE()  
  
  --  UPDATE DimLineCodeReview_Mod  
  --   SET AuthorisationStatus='R'  
  --   ,ApprovedBy  =@ApprovedBy  
  --   ,DateApproved=@DateApproved  
  --   ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
  --  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  --    AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  --    AND AuthorisationStatus in('NP','MP','DP','RM','1A')   
  
  --IF EXISTS(SELECT 1 FROM DimLineCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)   
  --                                              AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key)  
  --  BEGIN  
  --   UPDATE DimLineCodeReview  
  --    SET AuthorisationStatus='A'  
  --   WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  --     AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  --     AND AuthorisationStatus IN('MP','DP','RM')    
  --  END  
  --END   
  
  
  -------------------------------------------------------------------------  
   
   
 ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE DimLineCodeReview_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
  
  
    IF EXISTS(SELECT 1 FROM DimLineCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
    BEGIN  
     UPDATE DimLineCodeReview  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
  
 ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CrModApBy  
  SET @DateApproved=GETDATE()  
  UPDATE DimLineCodeReview_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
  
 END  
  
 --------NEW ADD------------------  
 --ELSE IF @OperationFlag=16  
  
 -- BEGIN  
  
 -- SET @ApprovedBy    = @CrModApBy   
 -- SET @DateApproved  = GETDATE()  
  
 -- UPDATE DimLineCodeReview_Mod  
 --     SET AuthorisationStatus ='1A'  
 --      ,ApprovedBy=@ApprovedBy  
 --      ,DateApproved=@DateApproved  
 --      WHERE ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
 --      AND AuthorisationStatus in('NP','MP','DP','RM')  
  
 -- END  
  
 ------------------------------  
  
 ELSE IF @OperationFlag=16 OR @AuthMode='N'  
  BEGIN  
     
   Print 'Authorise'  
 -------set parameter for  maker checker disabled  
   IF @AuthMode='N'  
   BEGIN  
    IF @OperationFlag=1  
     BEGIN  
      SET @CreatedBy =@CrModApBy  
      SET @DateCreated =GETDATE()  
     END  
    ELSE  
     BEGIN  
      SET @ModifiedBy  =@CrModApBy  
      SET @DateModified =GETDATE()  
      SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated  
      FROM DimLineCodeReview   
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )  
       AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
     END  
   END   
     
 ---set parameters and UPDATE mod table in case maker checker enabled  
   IF @AuthMode='Y'  
    BEGIN  
        Print 'B'  
     --DECLARE @DelStatus CHAR(2)=''  
     --DECLARE @CurrRecordFromTimeKey smallint=0  
  
     --SET @DelStatus=''  
     --SET CurrRecordFromTimeKey=0  
  
     Print 'C'  
     SELECT @ExEntityKey= MAX(ReviewLineCodeAlt_Key) FROM DimLineCodeReview_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
  
     SELECT @DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated  
      ,@ModifiedBy=ModifiedBy, @DateModified=DateModified  
      FROM DimLineCodeReview_Mod  
      WHERE ReviewLineCodeAlt_Key=@ExEntityKey  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
      
       
     --DECLARE @CurEntityKey INT=0  
  
     SELECT @ExEntityKey= MIN(ReviewLineCodeAlt_Key) FROM DimLineCodeReview_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
      
     SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey   
       FROM DimLineCodeReview_Mod  
       WHERE ReviewLineCodeAlt_Key=@ExEntityKey  
  
     UPDATE DimLineCodeReview_Mod  
      SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
      AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
      AND AuthorisationStatus='A'   
  
  -------DELETE RECORD AUTHORISE  
     IF @DelStatus='DP'   
     BEGIN   
      UPDATE DimLineCodeReview_Mod  
      SET AuthorisationStatus ='A'  
       ,ApprovedBy=@ApprovedBy  
       ,DateApproved=@DateApproved  
       ,EffectiveToTimeKey =@EffectiveFromTimeKey -1  
      WHERE ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus in('NP','MP','DP','RM','1A')  
        
      IF EXISTS(SELECT 1 FROM DimLineCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
      BEGIN  
        UPDATE DimLineCodeReview  
         SET AuthorisationStatus ='A'  
          ,ModifiedBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
  
          
      END  
     END -- END OF DELETE BLOCK  
  
     ELSE  -- OTHER THAN DELETE STATUS  
     BEGIN  
       UPDATE DimLineCodeReview_Mod  
        SET AuthorisationStatus ='A'  
         ,ApprovedBy=@ApprovedBy  
         ,DateApproved=@DateApproved  
        WHERE ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key      
         AND AuthorisationStatus in('NP','MP','RM','1A')  
  
     
  
           
     END    
    END  
  
  
  
  IF @DelStatus <>'DP' OR @AuthMode ='N'  
    BEGIN  
      --DECLARE @IsAvailable CHAR(1)='N'  
      --,@IsSCD2 CHAR(1)='N'  
  
      SET @IsAvailable='N'  
      SET @IsSCD2='N'  
        SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020  
  
        -----------------------------new addby anuj /Jayadev 26052021 ----  
        -- SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(ReviewLineCodeAlt_Key),0)+1 from   
        --    (Select ReviewLineCodeAlt_Key from DimLineCodeReview  
        --     UNION   
        --     Select ReviewLineCodeAlt_Key from DimLineCodeReview_Mod  
        --    )A)  
  
        ----------------------------------------------  
  
  
      IF EXISTS(SELECT 1 FROM DimLineCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
       BEGIN  
        SET @IsAvailable='Y'  
        --SET @AuthorisationStatus='A'  
  
  
        IF EXISTS(SELECT 1 FROM DimLineCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
         BEGIN  
           PRINT 'BBBB'  
   UPDATE DimLineCodeReview SET  
      ReviewLineCodeAlt_Key   = @ReviewLineCodeAlt_Key  
     --,SeniorityChargeDescription=@SeniorityChargeDescription  
     ,ReviewLineCode =@ReviewLineCode  
                   ,ReviewLineCodeName= @ReviewLineCodeName  
                   ,ReviewLineCodeGroup= @Source  
       ,CodeType  =@CodeType  
     ,ModifiedBy    = @ModifiedBy  
     ,DateModified   = @DateModified  
     ,ApprovedBy    = CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END  
     ,DateApproved   = CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END  
     ,AuthorisationStatus = CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END  
       
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
         END   
  
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
        --select @IsAvailable,@IsSCD2  
  
        IF @IsAvailable='N' OR @IsSCD2='Y'  
         BEGIN  
           
   INSERT INTO DimLineCodeReview   
           (   
            ReviewLineCodeAlt_Key  
            --,SeniorityChargeDescription  
           ,ReviewLineCode   
            ,ReviewLineCodeName  
            ,ReviewLineCodeGroup  
            ,CodeType    
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
                          
           )  
  
           select   
                          --@SecurityMappingAlt_Key  
              @ReviewLineCodeAlt_Key   
            ,@ReviewLineCode  
             ,@ReviewLineCodeName  
             ,@Source  
             ,@CodeType    
              
            ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL  END  
            
              
            
         END  
  
  
         IF @IsSCD2='Y'   
        BEGIN  
        UPDATE DimLineCodeReview SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1  
          ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
         WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
           AND EffectiveFromTimekey<@EffectiveFromTimeKey  
        END  
       END  
  
  IF @AUTHMODE='N'  
   BEGIN  
     SET @AuthorisationStatus='A'  
     GOTO ReviewLineCode_Insert  
     HistoryRecordInUp:  
   END        
  
  
  
  END   
  
PRINT 6  
SET @ErrorHandle=1  
  
ReviewLineCode_Insert:  
IF @ErrorHandle=0  
 BEGIN  
  
   INSERT INTO DimLineCodeReview_Mod    
           (   
            ReviewLineCodeAlt_Key  
            --,SeniorityChargeDescription  
              ,ReviewLineCode  
             ,ReviewLineCodeName  
             ,ReviewLineCodeGroup  
             ,CodeType   
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
                          
           )  
  
           select   
                          --@SecurityMappingAlt_Key  
              @ReviewLineCodeAlt_Key   
            ,@ReviewLineCode  
             ,@ReviewLineCodeName  
             ,@Source  
             ,@CodeType     
              
            ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END  
  
           IF @OperationFlag =1 AND @AUTHMODE='Y'  
     BEGIN  
      PRINT 3  
      GOTO ReviewLineCode_Insert_Add  
     END  
    ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'  
     BEGIN  
      GOTO ReviewLineCode_Insert_Edit_Delete  
     END  
 END  
PRINT 7  
  COMMIT TRANSACTION  
  
  --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
  --               AND GLAlt_Key=@GLAlt_Key  
  
  IF @OperationFlag =3  
   BEGIN  
    SET @Result=0  
   END  
  ELSE  
   BEGIN  
    SET @Result=1  
   END  
END  
  
------------------------------Stock Statement Code-------------------------------  
IF ( @CodeType='Stock Statement Code')  
 BEGIN   
 PRINT 3   
  --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
 IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD  
  BEGIN  
         PRINT 'Add'  
      SET @CreatedBy =@CrModApBy   
      SET @DateCreated = GETDATE()  
      SET @AuthorisationStatus='NP'  
  
      ----SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(ReviewLineCodeAlt_Key),0)+1 from   
      ----      (Select ReviewLineCodeAlt_Key from DimLineCodeReview  
      ----       UNION   
      ----       Select ReviewLineCodeAlt_Key from DimLineCodeReview_Mod  
      ----      )A)  
        GOTO StockStatementCode_Insert  
     StockStatementCode_Insert_Add:  
   END  
  
  
   ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE  
   BEGIN  
    Print 4  
    SET @CreatedBy= @CrModApBy  
    SET @DateCreated = GETDATE()  
    Set @Modifiedby=@CrModApBy     
    Set @DateModified =GETDATE()   
  
     PRINT 5  
  
     IF @OperationFlag = 2  
      BEGIN  
       PRINT 'Edit'  
       SET @AuthorisationStatus ='MP'  
         
      END  
  
     ELSE  
      BEGIN  
       PRINT 'DELETE'  
       SET @AuthorisationStatus ='DP'  
         
      END  
  
      ---FIND CREATED BY FROM MAIN TABLE  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DimLinecodeStockStatement    
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  
    ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
    IF ISNULL(@CreatedBy,'')=''  
    BEGIN  
     PRINT 'NOT AVAILABLE IN MAIN'  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DimLinecodeStockStatement_Mod   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','A','RM')  
                 
    END  
    ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE  
     BEGIN  
            Print 'AVAILABLE IN MAIN'  
      ----UPDATE FLAG IN MAIN TABLES AS MP  
      UPDATE DimLinecodeStockStatement  
       SET AuthorisationStatus=@AuthorisationStatus  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  
     END  
  
     --UPDATE NP,MP  STATUS   
     IF @OperationFlag=2  
     BEGIN   
  
      UPDATE DimLinecodeStockStatement_Mod  
       SET AuthorisationStatus='FM'  
       ,ModifiedBy=@Modifiedby  
       ,DateModified=@DateModified  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
        AND AuthorisationStatus IN('NP','MP','RM')  
     END  
          	     IF @OperationFlag=3
					BEGIN	
					
						IF NOT EXISTS(SELECT 1 FROM DimLinecodeStockStatement WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
						 AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key   )
							BEGIN
					           
							   UPDATE DimLinecodeStockStatement_Mod
									SET EffectiveToTimeKey=@TimeKey-1
									,ModifiedBy=@Modifiedby
									,DateModified=@DateModified
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key 
										AND AuthorisationStatus IN('NP','MP','RM')

                                SET @Result=1
								COMMIT TRAN
					            RETURN @Result
							  END
							  
					BEGIN	

						UPDATE DimLinecodeStockStatement_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
								AND AuthorisationStatus IN('NP','MP','RM')
						
					END

								 
                    
								
								
					END
     GOTO StockStatementCode_Insert  
     StockStatementCode_Insert_Edit_Delete:  
    END 
  
   ELSE IF @OperationFlag =3 AND @AuthMode ='N'  
  BEGIN  
  -- DELETE WITHOUT MAKER CHECKER  
             
      SET @Modifiedby   = @CrModApBy   
      SET @DateModified = GETDATE()   
  
      UPDATE DimLinecodeStockStatement SET  
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key   
      
      UPDATE DimLinecodeStockStatement_Mod SET  
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
      
  end   
  
  ----------------------------------NEW ADD FIRST LVL AUTH------------------  
  --ELSE IF @OperationFlag=21 AND @AuthMode ='Y'   
  --BEGIN  
  --  SET @ApprovedBy    = @CrModApBy   
  --  SET @DateApproved  = GETDATE()  
  
  --  UPDATE DimLineCodeReview_Mod  
  --   SET AuthorisationStatus='R'  
  --   ,ApprovedBy  =@ApprovedBy  
  --   ,DateApproved=@DateApproved  
  --   ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
  --  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  --    AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  --    AND AuthorisationStatus in('NP','MP','DP','RM','1A')   
  
  --IF EXISTS(SELECT 1 FROM DimLineCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)   
  --                                              AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key)  
  --  BEGIN  
  --   UPDATE DimLineCodeReview  
  --    SET AuthorisationStatus='A'  
  --   WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  --     AND ReviewLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
  --     AND AuthorisationStatus IN('MP','DP','RM')    
  --  END  
  --END   
  
  
  -------------------------------------------------------------------------  
   ELSE IF @OperationFlag =3 AND @AuthMode ='Y'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

							UPDATE DimLinecodeStockStatement_Mod
							SET AuthorisationStatus=@AuthorisationStatus
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
								--AND AuthorisationStatus IN('DP')

					  	UPDATE DimLinecodeStockStatement
							SET AuthorisationStatus='DP'
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
								--AND AuthorisationStatus IN('DP')

						--UPDATE DimBranch SET
						--			ModifiedBy =@Modifiedby 
						--			,DateModified =@DateModified 
						--			,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						--		WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND BranchAlt_Key=@BranchAlt_Key
					GOTO StockStatementCode_Insert
					

		end
   
 ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE DimLinecodeStockStatement_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
  
  
    IF EXISTS(SELECT 1 FROM DimLinecodeStockStatement WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)   
    AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
    BEGIN  
     UPDATE DimLinecodeStockStatement  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND StockLineCodeAlt_Key =@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
  
 ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CrModApBy  
  SET @DateApproved=GETDATE()  
  UPDATE DimLinecodeStockStatement_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
  
 END  
  
   
  
 ELSE IF @OperationFlag=16 OR @AuthMode='N'  
  BEGIN  
     
   Print 'Authorise'  
 -------set parameter for  maker checker disabled  
   IF @AuthMode='N'  
   BEGIN  
    IF @OperationFlag=1  
     BEGIN  
      SET @CreatedBy =@CrModApBy  
      SET @DateCreated =GETDATE()  
     END  
    ELSE  
     BEGIN  
      SET @ModifiedBy  =@CrModApBy  
      SET @DateModified =GETDATE()  
      SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated  
      FROM DimLinecodeStockStatement   
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )  
       AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
     END  
   END   
     
 ---set parameters and UPDATE mod table in case maker checker enabled  
   IF @AuthMode='Y'  
    BEGIN  
        Print 'B'  
       
  
     SET  @DelStatus =''  
     SET @CurrRecordFromTimeKey =0  
  
     Print 'C'  
     SELECT @ExEntityKey= MAX(StockLineCodeAlt_Key) FROM DimLinecodeStockStatement_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
  
     SELECT @DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated  
      ,@ModifiedBy=ModifiedBy, @DateModified=DateModified  
      FROM DimLinecodeStockStatement_Mod  
      WHERE StockLineCodeAlt_Key=@ExEntityKey  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
      
       
       
  
     SET @CurEntityKey=0  
  
     SELECT @ExEntityKey= MIN(StockLineCodeAlt_Key) FROM DimLinecodeStockStatement_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
      
     SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey   
       FROM DimLinecodeStockStatement_Mod  
       WHERE StockLineCodeAlt_Key=@ExEntityKey  
  
     UPDATE DimLinecodeStockStatement_Mod  
      SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
      AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
      AND AuthorisationStatus='A'   
  
  -------DELETE RECORD AUTHORISE  
     IF @DelStatus='DP'   
     BEGIN   
      UPDATE DimLinecodeStockStatement_Mod  
      SET AuthorisationStatus ='A'  
       ,ApprovedBy=@ApprovedBy  
       ,DateApproved=@DateApproved  
       ,EffectiveToTimeKey =@EffectiveFromTimeKey -1  
      WHERE StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus in('NP','MP','DP','RM','1A')  
        
      IF EXISTS(SELECT 1 FROM DimLinecodeStockStatement WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
      BEGIN  
        UPDATE DimLinecodeStockStatement  
         SET AuthorisationStatus ='A'  
          ,ModifiedBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
  
          
      END  
     END -- END OF DELETE BLOCK  
  
     ELSE  -- OTHER THAN DELETE STATUS  
     BEGIN  
       UPDATE DimLinecodeStockStatement_Mod  
        SET AuthorisationStatus ='A'  
         ,ApprovedBy=@ApprovedBy  
         ,DateApproved=@DateApproved  
        WHERE StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key      
         AND AuthorisationStatus in('NP','MP','RM','1A')  
  
     
  
           
     END    
    END  
  
  
  
  IF @DelStatus <>'DP' OR @AuthMode ='N'  
    BEGIN  
      --DECLARE @IsAvailable CHAR(1)='N'  
      --,@IsSCD2 CHAR(1)='N'  
  
      SET @IsAvailable='N'  
      SET @IsSCD2='N'  
        SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020  
  
        -----------------------------new addby anuj /Jayadev 26052021 ----  
        -- SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(ReviewLineCodeAlt_Key),0)+1 from   
        --    (Select ReviewLineCodeAlt_Key from DimLineCodeReview  
        --     UNION   
        --     Select ReviewLineCodeAlt_Key from DimLineCodeReview_Mod  
        --    )A)  
  
        ----------------------------------------------  
  
  
      IF EXISTS(SELECT 1 FROM DimLinecodeStockStatement WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
       BEGIN  
        SET @IsAvailable='Y'  
        --SET @AuthorisationStatus='A'  
  
  
        IF EXISTS(SELECT 1 FROM DimLinecodeStockStatement WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey   
            AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key)  
         BEGIN  
           PRINT 'BBBB'  
  UPDATE DimLinecodeStockStatement SET  
     StockLineCodeAlt_Key   = @ReviewLineCodeAlt_Key  
    --,SeniorityChargeDescription=@SeniorityChargeDescription  
    ,StockLineCode =@ReviewLineCode  
                ,StockLineCodeName=@ReviewLineCodeName  
                ,StockLineCodeGroup=@Source  
                ,CodeType=@CodeType  
    ,ModifiedBy    = @ModifiedBy  
    ,DateModified   = @DateModified  
    ,ApprovedBy    = CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END  
    ,DateApproved   = CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END  
    ,AuthorisationStatus = CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END  
      
            WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey   
            AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
         END   
  
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
        --select @IsAvailable,@IsSCD2  
  
        IF @IsAvailable='N' OR @IsSCD2='Y'  
         BEGIN  
           
   INSERT INTO DimLinecodeStockStatement   
           (   
            StockLineCodeAlt_Key  
            --,SeniorityChargeDescription  
           ,StockLineCode   
           ,StockLineCodeName  
           ,StockLineCodeGroup  
           ,CodeType  
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
                          
           )  
  
           select   
                          --@SecurityMappingAlt_Key  
              @ReviewLineCodeAlt_Key   
            --,@SeniorityChargeDescription    
            ,@ReviewLineCode  
            ,@ReviewLineCodeName  
            ,@Source  
            ,@CodeType  
            ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL  END  
            
              
            
         END  
  
  
         IF @IsSCD2='Y'   
        BEGIN  
        UPDATE DimLinecodeStockStatement SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1  
          ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
         WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)  
                AND StockLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
           AND EffectiveFromTimekey<@EffectiveFromTimeKey  
        END  
       END  
  
  IF @AUTHMODE='N'  
   BEGIN  
     SET @AuthorisationStatus='A'  
     GOTO StockStatementCode_Insert  
     HistoryRecordInUp1:  
   END        
  
  
  
  END   
  
PRINT 6  
SET @ErrorHandle=1  
  
StockStatementCode_Insert:  
IF @ErrorHandle=0  
 BEGIN  
  
  
   INSERT INTO DimLinecodeStockStatement_Mod    
           (   
            StockLineCodeAlt_Key  
            --,SeniorityChargeDescription  
           ,StockLineCode   
            ,StockLineCodeName  
            ,StockLineCodeGroup  
            ,CodeType  
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
                          
           )  
  
           select   
                          --@SecurityMappingAlt_Key  
              @ReviewLineCodeAlt_Key   
            --,@SeniorityChargeDescription    
            ,@ReviewLineCode  
             ,@ReviewLineCodeName  
             ,@Source  
             ,@CodeType  
            ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END  
   
  
           IF @OperationFlag =1 AND @AUTHMODE='Y'  
     BEGIN  
      PRINT 3  
      GOTO StockStatementCode_Insert_Add  
     END  
    ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'  
     BEGIN  
      GOTO StockStatementCode_Insert_Edit_Delete  
     END  
      
 END  
 -------------------  
PRINT 7  
  COMMIT TRANSACTION  
  
  --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
  --               AND GLAlt_Key=@GLAlt_Key  
  
  IF @OperationFlag =3  
   BEGIN  
    SET @Result=0  
   END  
  ELSE  
   BEGIN  
    SET @Result=1  
   END  
END  
----------------------------------------------  
  
------------------------------Product Code-------------------------------  
IF ( @CodeType='Product Code')  
 BEGIN   
 PRINT 3   
  --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
 IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD  
  BEGIN  
         PRINT 'Add'  
      SET @CreatedBy =@CrModApBy   
      SET @DateCreated = GETDATE()  
      SET @AuthorisationStatus='NP'  
  
      ----SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(ReviewLineCodeAlt_Key),0)+1 from   
      ----      (Select ReviewLineCodeAlt_Key from DimLineCodeReview  
      ----       UNION   
      ----       Select ReviewLineCodeAlt_Key from DimLineCodeReview_Mod  
      ----      )A)  
  
      GOTO ProductCode_Insert  
     ProductCode_Insert_Add:  
   END  
  
  
   ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE  
   BEGIN  
    Print 4  
    SET @CreatedBy= @CrModApBy  
    SET @DateCreated = GETDATE()  
    Set @Modifiedby=@CrModApBy     
    Set @DateModified =GETDATE()   
  
     PRINT 5  
  
     IF @OperationFlag = 2  
      BEGIN  
       PRINT 'Edit'  
       SET @AuthorisationStatus ='MP'  
         
      END  
  
     ELSE  
      BEGIN  
       PRINT 'DELETE'  
       SET @AuthorisationStatus ='DP'  
         
      END  
  
      ---FIND CREATED BY FROM MAIN TABLE  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DimLineProductCodeReview    
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key  
  
    ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
    IF ISNULL(@CreatedBy,'')=''  
    BEGIN  
     PRINT 'NOT AVAILABLE IN MAIN'  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DimLineProductCodeReview_Mod   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','A','RM')  
                 
    END  
    ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE  
     BEGIN  
            Print 'AVAILABLE IN MAIN'  
      ----UPDATE FLAG IN MAIN TABLES AS MP  
      UPDATE DimLineProductCodeReview  
       SET AuthorisationStatus=@AuthorisationStatus  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key  
  
     END  
  
     --UPDATE NP,MP  STATUS   
     IF @OperationFlag=2  
     BEGIN   
  
      UPDATE DimLineProductCodeReview_Mod  
       SET AuthorisationStatus='FM'  
       ,ModifiedBy=@Modifiedby  
       ,DateModified=@DateModified  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key  
        AND AuthorisationStatus IN('NP','MP','RM')  
     END  
  IF @OperationFlag=3
					BEGIN	
					PRINT 'SacDelete'
					IF NOT EXISTS(SELECT 1 FROM DimLineProductCodeReview 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)  
					AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key   )
					BEGIN
					PRINT 'SacDelete111'

						UPDATE DimLineProductCodeReview_Mod
							SET EffectiveToTimeKey=@TimeKey-1
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							 AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key  
								AND AuthorisationStatus IN('NP','MP','RM')

								SET @Result=1
								COMMIT TRAN
					            RETURN @Result 
                      END
							
					 BEGIN	

						UPDATE DimLineProductCodeReview_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key 
								AND AuthorisationStatus IN('NP','MP','RM')
						
					END
								
					END
     GOTO ProductCode_Insert  
     ProductCode_Insert_Edit_Delete:  
    END  
  
  ELSE IF @OperationFlag =3 AND @AuthMode ='N'  
  BEGIN  
  -- DELETE WITHOUT MAKER CHECKER  
             
      SET @Modifiedby   = @CrModApBy   
      SET @DateModified = GETDATE()   
  
      UPDATE DimLineProductCodeReview SET  
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey   
        AND EffectiveToTimeKey>=@TimeKey)   
        AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  

		 UPDATE DimLineProductCodeReview_Mod SET  
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		 AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key   

      
  
  end  
  
 ELSE IF @OperationFlag =3 AND @AuthMode ='Y'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

							UPDATE DimLineProductCodeReview_Mod
							SET AuthorisationStatus=@AuthorisationStatus
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							 AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key 
								--AND AuthorisationStatus IN('DP')

					  	UPDATE DimLineProductCodeReview
							SET AuthorisationStatus='DP'
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key 
								--AND AuthorisationStatus IN('DP')

						--UPDATE DimBranch SET
						--			ModifiedBy =@Modifiedby 
						--			,DateModified =@DateModified 
						--			,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						--		WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND BranchAlt_Key=@BranchAlt_Key
					GOTO ProductCode_Insert 
					

		end   
   
 ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE DimLineProductCodeReview_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key  
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
  
  
    IF EXISTS(SELECT 1 FROM DimLineProductCodeReview   
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)   
    AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key)  
    BEGIN  
     UPDATE DimLineProductCodeReview  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND ReviewLineProductCodeAlt_Key =@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
  
 ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CrModApBy  
  SET @DateApproved=GETDATE()  
  UPDATE DimLineProductCodeReview_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
  
 END  
  
 --------NEW ADD------------------  
 --ELSE IF @OperationFlag=16  
  
 -- BEGIN  
  
 -- SET @ApprovedBy    = @CrModApBy   
 -- SET @DateApproved  = GETDATE()  
  
 -- UPDATE DimLineCodeReview_Mod  
 --     SET AuthorisationStatus ='1A'  
 --      ,ApprovedBy=@ApprovedBy  
 --      ,DateApproved=@DateApproved  
 --      WHERE ReviewLineCodeAlt_Key=@ReviewLineCodeAlt_Key  
 --      AND AuthorisationStatus in('NP','MP','DP','RM')  
  
 -- END  
  
 ------------------------------  
  
 ELSE IF @OperationFlag=16 OR @AuthMode='N'  
  BEGIN  
     
   Print 'Authorise'  
 -------set parameter for  maker checker disabled  
   IF @AuthMode='N'  
   BEGIN  
    IF @OperationFlag=1  
     BEGIN  
      SET @CreatedBy =@CrModApBy  
      SET @DateCreated =GETDATE()  
     END  
    ELSE  
     BEGIN  
      SET @ModifiedBy  =@CrModApBy  
      SET @DateModified =GETDATE()  
      SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated  
      FROM DimLineProductCodeReview   
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )  
       AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
     END  
   END   
     
 ---set parameters and UPDATE mod table in case maker checker enabled  
   IF @AuthMode='Y'  
    BEGIN  
        Print 'B'  
       
  
     SET  @DelStatus =''  
     SET @CurrRecordFromTimeKey =0  
  
     Print 'C'  
     SELECT @ExEntityKey= MAX(ReviewLineProductCodeAlt_Key) FROM DimLineProductCodeReview_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
  
     SELECT @DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated  
      ,@ModifiedBy=ModifiedBy, @DateModified=DateModified  
      FROM DimLineProductCodeReview_Mod  
      WHERE ReviewLineProductCodeAlt_Key=@ExEntityKey  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
      
       
       
  
     SET @CurEntityKey=0  
  
     SELECT @ExEntityKey= MIN(ReviewLineProductCodeAlt_Key) FROM DimLineProductCodeReview_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
      
     SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey   
       FROM DimLineProductCodeReview_Mod  
       WHERE ReviewLineProductCodeAlt_Key=@ExEntityKey  
  
     UPDATE DimLineProductCodeReview_Mod  
      SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
      AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
      AND AuthorisationStatus='A'   
  
  -------DELETE RECORD AUTHORISE  
     IF @DelStatus='DP'   
     BEGIN   
      UPDATE DimLineProductCodeReview_Mod  
      SET AuthorisationStatus ='A'  
       ,ApprovedBy=@ApprovedBy  
       ,DateApproved=@DateApproved  
       ,EffectiveToTimeKey =@EffectiveFromTimeKey -1  
      WHERE ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
       AND AuthorisationStatus in('NP','MP','DP','RM','1A')  
        
      IF EXISTS(SELECT 1 FROM DimLineProductCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key)  
      BEGIN  
        UPDATE DimLineProductCodeReview  
         SET AuthorisationStatus ='A'  
          ,ModifiedBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
  
          
      END  
     END -- END OF DELETE BLOCK  
  
     ELSE  -- OTHER THAN DELETE STATUS  
     BEGIN  
       UPDATE DimLineProductCodeReview_Mod  
        SET AuthorisationStatus ='A'  
         ,ApprovedBy=@ApprovedBy  
         ,DateApproved=@DateApproved  
        WHERE ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key      
         AND AuthorisationStatus in('NP','MP','RM','1A')  
  
     
  
           
     END    
    END  
  
  
  
  IF @DelStatus <>'DP' OR @AuthMode ='N'  
    BEGIN  
      --DECLARE @IsAvailable CHAR(1)='N'  
      --,@IsSCD2 CHAR(1)='N'  
  
      SET @IsAvailable='N'  
      SET @IsSCD2='N'  
        SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020  
  
        -----------------------------new addby anuj /Jayadev 26052021 ----  
        -- SET @ReviewLineCodeAlt_Key = (Select ISNULL(Max(ReviewLineCodeAlt_Key),0)+1 from   
        --    (Select ReviewLineCodeAlt_Key from DimLineCodeReview  
        --     UNION   
        --     Select ReviewLineCodeAlt_Key from DimLineCodeReview_Mod  
        --    )A)  
  
        ----------------------------------------------  
  
  
      IF EXISTS(SELECT 1 FROM DimLineProductCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key)  
       BEGIN  
        SET @IsAvailable='Y'  
        --SET @AuthorisationStatus='A'  
  
  
        IF EXISTS(SELECT 1 FROM DimLineProductCodeReview WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey   
            AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key)  
         BEGIN  
           PRINT 'BBBB'  
 UPDATE DimLineProductCodeReview SET  
    ReviewLineProductCodeAlt_Key   = @ReviewLineCodeAlt_Key  
   --,SeniorityChargeDescription=@SeniorityChargeDescription  
   ,ReviewLineProductCode =@ReviewLineCode  
   ,ReviewLineProductCodeName=@ReviewLineCodeName  
   ,ReviewLineProductCodeGroup=@Source  
   ,CodeType=@CodeType  
   ,ModifiedBy    = @ModifiedBy  
   ,DateModified   = @DateModified  
   ,ApprovedBy    = CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END  
   ,DateApproved   = CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END  
   ,AuthorisationStatus = CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END  
              
            WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey   
            AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
         END   
  
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
        --select @IsAvailable,@IsSCD2  
  
        IF @IsAvailable='N' OR @IsSCD2='Y'  
         BEGIN  
           
   INSERT INTO DimLineProductCodeReview   
           (   
            ReviewLineProductCodeAlt_Key  
            --,SeniorityChargeDescription  
           ,ReviewLineProductCode   
           ,ReviewLineProductCodeName  
           ,ReviewLineProductCodeGroup  
           ,CodeType  
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
                          
           )  
  
           select   
                          --@SecurityMappingAlt_Key  
              @ReviewLineCodeAlt_Key   
            --,@SeniorityChargeDescription    
            ,@ReviewLineCode  
            ,@ReviewLineCodeName  
            ,@Source  
            ,@CodeType  
            ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL  END  
            
              
            
         END  
  
  
         IF @IsSCD2='Y'   
        BEGIN  
        UPDATE DimLineProductCodeReview SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1  
          ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
         WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey   
         AND EffectiveToTimeKey>=@TimeKey)   
         AND ReviewLineProductCodeAlt_Key=@ReviewLineCodeAlt_Key  
           AND EffectiveFromTimekey<@EffectiveFromTimeKey  
        END  
       END  
  
  IF @AUTHMODE='N'  
   BEGIN  
     SET @AuthorisationStatus='A'  
     GOTO ProductCode_Insert  
     HistoryRecordInUp2:  
   END        
  
  
  
  END   
  
PRINT 6  
SET @ErrorHandle=1  
  
ProductCode_Insert:  
IF @ErrorHandle=0  
 BEGIN  
  
   INSERT INTO DimLineProductCodeReview_Mod    
           (   
            ReviewLineProductCodeAlt_Key  
            --,SeniorityChargeDescription  
           ,ReviewLineProductCode  
           ,ReviewLineProductCodeName  
           ,ReviewLineProductCodeGroup  
           ,CodeType  
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
                          
           )  
  
           select   
                          --@SecurityMappingAlt_Key  
              @ReviewLineCodeAlt_Key   
            --,@SeniorityChargeDescription    
            ,@ReviewLineCode  
            ,@ReviewLineCodeName  
            ,@Source  
            ,@CodeType  
            ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END  
   
  
           IF @OperationFlag =1 AND @AUTHMODE='Y'  
     BEGIN  
      PRINT 3  
      GOTO ProductCode_Insert_Add  
     END  
    ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'  
     BEGIN  
      GOTO ProductCode_Insert_Edit_Delete  
     END  
   
  
      
 END  
 -------------------  
PRINT 7  
  COMMIT TRANSACTION  
  
  --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
  --               AND GLAlt_Key=@GLAlt_Key  
  
  IF @OperationFlag =3  
   BEGIN  
    SET @Result=0  
   END  
  ELSE  
   BEGIN  
    SET @Result=1  
   END  
END  
-----------------------------------------------------  
END TRY  
BEGIN CATCH  
 ROLLBACK TRAN  
  
 INSERT INTO dbo.Error_Log  
    SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber  
    ,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState  
    ,GETDATE()  
  
 SELECT ERROR_MESSAGE()  
 RETURN -1  
     
END CATCH  
---------  
END  
  
  
  
GO