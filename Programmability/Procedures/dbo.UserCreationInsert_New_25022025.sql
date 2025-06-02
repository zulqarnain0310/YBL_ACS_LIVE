SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
  
  
Create PROCEDURE [dbo].[UserCreationInsert_New_25022025]  
--Declare  
   
  @UserLoginID varchar(20),   
  @EmployeeID varchar(20),     
  @IsEmployee char(1),      
  @UserName varchar(50),  
  @LoginPassword varchar(max),  
  @D2K_PSlt VARCHAR(100)='ddd222kkk',  
  @UserLocation varchar (10),  
  @UserLocationCode varchar (10),  
  @UserRoleAlt_Key smallint,  
  @DeptGroupCode varchar(10),  
  @DateCreatedmodified smalldatetime,  
  @CreatedModifiedBy varchar (20),  
  @Activate char(1),  
  @IsChecker char(1),  
  @IsChecker2 char(1)='',   -- Commented by shubham on 2024-01-25 Because Checker 2 not available on Production  
  @WorkFlowUserRoleAlt_Key smallint,  
  @DesignationAlt_Key int,  
  @IsCma char(1),  
  @MobileNo varchar(50),  
  @Email_ID VARCHAR(200),    
  @SecuritQsnAlt_Key SMALLINT,  
  @SecurityAns VARCHAR(100),  
  @MenuId VARCHAR(1000),  
  @EffectiveFromTimeKey INT,                         
  @EffectiveToTimeKey INT  ,                
  @OperationFlag  INT,  
  @TimeKey SMALLINT,  
  @SourceAlt_Key VARCHAR(30),  
  @AuthMode  CHAR(1),  
  @D2Ktimestamp TIMESTAMP OUTPUT,  
  @Result INT=0 OUTPUT  
   
AS  
BEGIN  
 SET NOCOUNT ON;  
  PRINT 1  
   
  SET DATEFORMAT DMY  
   
  DECLARE   
      --@AuthorisationStatus  CHAR(2)   = NULL --comment ont 10072023 by shashi bhushan singh We have that latest user information is inserted with  authorizationstatus column having  values as  A   (A with space) data .  
      @AuthorisationStatus  VARCHAR(2)  = NULL   
      ,@CreatedBy     VARCHAR(20)  = NULL  
      ,@DateCreated    SMALLDATETIME = NULL  
      ,@ModifiedBy    VARCHAR(20)  = NULL  
      ,@DateModified    SMALLDATETIME = NULL  
      ,@ApprovedBy    VARCHAR(20)  = NULL  
      ,@DateApproved    SMALLDATETIME = NULL  
      ,@ExCustomer_Key   INT    = 0  
         ,@ErrorHandle    int    = 0  
      ,@ExEntityKey    int    = 0    
        
  
   
 IF @OperationFlag=1  --- add  
 BEGIN  
 PRINT 1  
  -----CHECK DUPLICATE BILL NO AT BRANCH LEVEL  
  IF EXISTS(                      
     SELECT  1 FROM DimUserInfo WHERE UserLoginID=@UserLoginID AND ISNULL(AuthorisationStatus,'A')='A' AND (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey) --Added by shubham on 2024-01-22 For Error Again Creating Deleted Record  
     UNION  
     SELECT  1 FROM DimUserInfo_MOD  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
               AND UserLoginID=@UserLoginID  
               AND  AuthorisationStatus in('NP','MP','DP','A','RM')   
    )   
    BEGIN  
       PRINT 2  
     SET @Result=-6  
     RETURN @Result -- CUSTOMERID ALEADY EXISTS  
    END  
  ELSE  
   BEGIN  
      PRINT 3  
    SET @Result=0  
   END  
 END  
  
   
 BEGIN TRY  
 BEGIN TRANSACTION   
 -----  
   
 PRINT 3   
  --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
 IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD  
  BEGIN  
         PRINT 'Add'  
      SET @CreatedBy =@CreatedModifiedBy   
      SET @DateCreated = GETDATE()  
      SET @AuthorisationStatus='NP'  
      GOTO DimUserInfo_Insert  
     DimUserInfo_Insert_Add:  
   END  
  
  
   ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE  
   BEGIN  
    Print 4  
    SET @CreatedBy= @CreatedModifiedBy  
    SET @DateCreated = GETDATE()  
    Set @Modifiedby=@CreatedModifiedBy     
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
     FROM DimUserInfo    
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND UserLoginID=@UserLoginID  
  
    ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
    IF ISNULL(@CreatedBy,'')=''  
    BEGIN  
     PRINT 'NOT AVAILABLE IN MAIN'  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DimUserInfo_Mod   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND UserLoginID=@UserLoginID       
       AND AuthorisationStatus IN('NP','MP','A','RM')  
                 
    END  
    ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE  
     BEGIN  
            Print 'AVAILABLE IN MAIN'  
      ----UPDATE FLAG IN MAIN TABLES AS MP  
      UPDATE DimUserInfo  
       SET AuthorisationStatus=@AuthorisationStatus  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND UserLoginID=@UserLoginID  
  
     END  
  
     --UPDATE NP,MP  STATUS   
     IF @OperationFlag=2  
     BEGIN   
  
      UPDATE DimUserInfo_Mod  
       SET AuthorisationStatus='FM'  
       ,ModifyBy=@Modifiedby  
       ,DateModified=@DateModified  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND UserLoginID=@UserLoginID  
        AND AuthorisationStatus IN('NP','MP','RM')  
     END  
  
     GOTO DimUserInfo_Insert  
     DimUserInfo_Insert_Edit_Delete:  
    END  
  
  ELSE IF @OperationFlag =3 AND @AuthMode ='N'  
  BEGIN  
  -- DELETE WITHOUT MAKER CHECKER  
             
      SET @Modifiedby   = @CreatedModifiedBy   
      SET @DateModified = GETDATE()   
  
      UPDATE DimUserInfo SET  
         ModifyBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND UserLoginID=@UserLoginID  
      
  
  end  
   
   
 ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CreatedModifiedBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE DimUserInfo_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND UserLoginID=@UserLoginID  
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
    IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND UserLoginID=@UserLoginID)  
    BEGIN  
     UPDATE DimUserInfo  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND UserLoginID=@UserLoginID  
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
  
 ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CreatedModifiedBy  
  SET @DateApproved=GETDATE()  
  UPDATE DimUserInfo_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  AND UserLoginID=@UserLoginID  
  
 END  
  
 ELSE IF @OperationFlag=16 OR @AuthMode='N'  
  BEGIN  
     
   Print 'Authorise'  
 -------set parameter for  maker checker disabled  
   IF @AuthMode='N'  
   BEGIN  
    IF @OperationFlag=1  
     BEGIN  
      SET @CreatedBy =@CreatedModifiedBy  
      SET @DateCreated =GETDATE()  
     END  
    ELSE  
     BEGIN  
      SET @ModifiedBy  =@CreatedModifiedBy  
      SET @DateModified =GETDATE()  
      SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated  
      FROM DimUserInfo   
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )  
       AND UserLoginID=@UserLoginID  
       
     SET @ApprovedBy = @CreatedModifiedBy     
     SET @DateApproved=GETDATE()  
     END  
   END   
     
 ---set parameters and UPDATE mod table in case maker checker enabled  
   IF @AuthMode='Y'  
    BEGIN  
        Print 'B'  
     DECLARE @DelStatus CHAR(2)  
     DECLARE @CurrRecordFromTimeKey smallint=0  
  
     Print 'C'  
     SELECT @ExEntityKey= MAX(EntityKey) FROM DimUserInfo_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND UserLoginID=@UserLoginID  
       AND AuthorisationStatus IN('NP','MP','DP','RM')   
  
     SELECT @DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated  
      ,@ModifiedBy=ModifyBy, @DateModified=DateModified  
      FROM DimUserInfo_Mod  
      WHERE EntityKey=@ExEntityKey  
       
     SET @ApprovedBy = @CreatedModifiedBy     
     SET @DateApproved=GETDATE()  
      
       
     DECLARE @CurEntityKey INT=0  
  
     SELECT @ExEntityKey= MIN(EntityKey) FROM DimUserInfo_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND UserLoginID=@UserLoginID  
       AND AuthorisationStatus IN('NP','MP','DP','RM')   
      
     SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey   
       FROM DimUserInfo_Mod  
       WHERE EntityKey=@ExEntityKey  
  
     UPDATE DimUserInfo_Mod  
      SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
      AND UserLoginID=@UserLoginID  
      AND AuthorisationStatus='A'   
  
  -------DELETE RECORD AUTHORISE  
     IF @DelStatus='DP'   
     BEGIN   
      UPDATE DimUserInfo_Mod  
      SET AuthorisationStatus ='A'  
       ,ApprovedBy=@ApprovedBy  
       ,DateApproved=@DateApproved  
       ,EffectiveToTimeKey =@EffectiveFromTimeKey -1  
      WHERE UserLoginID=@UserLoginID  
       AND AuthorisationStatus in('NP','MP','DP','RM')  
        
      IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND UserLoginID=@UserLoginID)  
      BEGIN  
        UPDATE DimUserInfo  
         SET AuthorisationStatus ='A'  
          ,ModifyBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,DateDeleted=@DateApproved --Added to Captured Delete Timestamp by shubham on 2024-04-05 --Changes Deployed on UAT 2024-04-10  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND UserLoginID=@UserLoginID  
      END  
     END -- END OF DELETE BLOCK  
  
     ELSE  -- OTHER THAN DELETE STATUS  
     BEGIN  
       UPDATE DimUserInfo_Mod  
        SET AuthorisationStatus ='A'  
         ,ApprovedBy=@ApprovedBy  
         ,DateApproved=@DateApproved  
        WHERE  UserLoginID=@UserLoginID  
         AND AuthorisationStatus in('NP','MP','RM')  
     END    
    END  
  
  
  
  IF @DelStatus <>'DP' OR @AuthMode ='N'  
    BEGIN  
      DECLARE @IsAvailable CHAR(1)='N'  
      ,@IsSCD2 CHAR(1)='N'  
  
      IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
         AND UserLoginID=@UserLoginID)  
       BEGIN  
        SET @IsAvailable='Y'  
        SET @AuthorisationStatus='A'  
  
  
        IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@TimeKey AND UserLoginID=@UserLoginID)  
         BEGIN  
           PRINT 'BBBB'  
          UPDATE DimUserInfo SET  
              
            UserName      =@UserName,  
            UserLocation     =@UserLocation,  
            UserLocationCode    =@UserLocationCode,  
            UserRoleAlt_Key     =@UserRoleAlt_Key ,  
                 IsChecker      =@IsChecker,  
                 --IsChecker2      =@IsChecker2,   -- Commented by shubham on 2024-01-25 Because Checker 2 not available on Production  
                 Activate      =@Activate,  
            DeptGroupCode     =@DeptGroupCode,  
            WorkFlowUserRoleAlt_Key   =@WorkFlowUserRoleAlt_Key,  
            Email_ID      =@Email_ID, --ad4  
            MobileNo      =@MobileNo,  
            DesignationAlt_Key    =@DesignationAlt_Key,  
            IsCma       = @isCma,  
            D2K_PSlt      = @D2K_PSlt,  
            SourceAlt_Key     =@SourceAlt_Key  
            ,ModifyBy      = @ModifiedBy  
            ,DateModified     = @DateModified  
            ,ApprovedBy      = CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END  
            ,DateApproved     = CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END  
            ,AuthorisationStatus   = CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END              
            WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey   
            AND UserLoginID=@UserLoginID  
									UPDATE DimUserInfo_Mod SET EffectiveToTimeKey=EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND UserLoginID=@UserLoginID
         END   
  
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
  
        IF @IsAvailable='N' OR @IsSCD2='Y'  
         BEGIN  
          INSERT INTO DimUserInfo           
          (  
           UserLoginID  
           ,EmployeeID   
           ,IsEmployee   
           ,UserName  
           ,LoginPassword   
           ,UserLocation   
           ,DeptGroupCode   
           ,Activate    
           ,IsChecker   
           --,IsChecker2     -- Commented by shubham on 2024-01-25 Because Checker 2 not available on Production  
           ,AuthorisationStatus  
           ,EffectiveFromTimeKey                            
           ,EffectiveToTimeKey                 
           ----,EntityKey   
           ,PasswordChanged  
           --------  
           ,PasswordChangeDate  
           ,ChangePwdCnt  
           ,UserLocationCode  
           ,UserRoleAlt_Key  
           ,SuspendedUser  
           ,CurrentLoginDate  
           ,ResetDate  
           ,UserLogged  
           ,UserDeletionReasonAlt_Key  
           ,SystemLogOut  
           ,RBIFLAG  
  
           ,Email_ID --ad4  
           ,MobileNo  
           ,DesignationAlt_Key  
           ,IsCma  
  
           ,SecuritQsnAlt_Key  
           ,SecurityAns  
           ,MenuId  
           ,CreatedBy  
           ,DateCreated  
           ,ModifyBy  
           ,DateModified  
           ,ApprovedBy  
           ,DateApproved  
           ,MIS_APP_USR_ID  
           ,MIS_APP_USR_PASS  
           ,UserLocationExcel  
           ,WorkFlowUserRoleAlt_Key  
           ,D2K_PSlt  
           ,SourceAlt_Key  
           ,UserType  
          )          
         SELECT    
           @UserLoginID  
        ,@EmployeeID   
        ,@IsEmployee   
        ,@UserName  
        ,@LoginPassword   
        ,@UserLocation  
        ,@DeptGroupCode   
        ,@Activate    
        ,@IsChecker   
        --,@IsChecker2     -- Commented by shubham on 2024-01-25 Because Checker 2 not available on Production  
        --,CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END  
        ,@AuthorisationStatus  
        ,@EffectiveFromTimeKey                         
        ,@EffectiveToTimeKey                  
        ------,@Entity_Key   
        ,'N'   
        ,NULL  
        ,0  
        ,@UserLocationCode  
        ,@UserRoleAlt_Key  
        ,'N'  
        ,NULL--CurrentLoginDate  
        ,NULL--ResetDate  
        ,0  
        ,NULL  
        ,NULL  
        ,NULL  
        ,NULLIF(@Email_ID,'') --ad4  
        ,@MobileNo  
        ,@DesignationAlt_Key  
        ,@isCma  
        ,@SecuritQsnAlt_Key  
        ,@SecurityAns  
        ,@MenuId  
        ,@CreatedBy   
        ,@DateCreated  
        ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END  
        ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END  
        ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END  
        ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END  
        ,NULL  
        ,NULL  
        ,NULL  
        ,@WorkFlowUserRoleAlt_Key  
        ,@D2K_PSlt  
        ,@SourceAlt_Key  
        ,'Employee'    
           END  
  
  
      IF @IsSCD2='Y'   
       BEGIN  
        UPDATE DimUserInfo  
         SET EffectiveToTimeKey=@EffectiveFromTimeKey -1  
         WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND EffectiveFromTimeKey<@EffectiveFromTimeKey   
          AND UserLoginID=@UserLoginID  
        END  
    END  
  
  IF @AUTHMODE='N'  
   BEGIN  
     SET @AuthorisationStatus='A'  
     GOTO DimUserInfo_Insert  
     HistoryRecordInUp:  
   END        
  
  
  
  END   
  
 ----***********maintain log table  
  
 --IF @OperationFlag IN(1,2,3,16,17,18) AND @AuthMode ='Y'  
 --  BEGIN  
 -- PRINT 5  
 --   IF @OperationFlag=2   
 --    BEGIN   
  
 --     SET @CreatedBy=@ModifiedBy  
 --    --end  
  
 --   END  
 --    IF @OperationFlag IN(16,17)   
 --     BEGIN   
 --      SET @DateCreated= GETDATE()  
       
 --       EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE  
 --        @BranchCode ,  
 --        @MenuID,  
 --        @AccountEntityId,-- ReferenceID ,  
 --        @CreatedBy,  
 --        @ApprovedBy,-- @ApproveBy   
 --        @DateCreated,  
 --        @Remark,  
 --        @ScreenEntityId, -- for FXT060 screen  
 --        @OperationFlag,  
 --        @AuthMode  
 --     END  
 --    ELSE  
 --     BEGIN  
 --      EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE  
 --       @BranchCode ,  
 --       @MenuID,  
 --       @AccountEntityId ,-- ReferenceID ,  
 --       @CreatedBy,  
 --       NULL,-- @ApproveBy   
 --       @DateCreated,  
 --       @Remark,  
 --       @ScreenEntityId, -- for FXT060 screen  
 --       @OperationFlag,  
 --       @AuthMode  
 --     END  
 --  END   
  
  --****************************  
PRINT 6  
SET @ErrorHandle=1  
  
DimUserInfo_Insert:  
IF @ErrorHandle=0  
 BEGIN  
   INSERT INTO DimUserInfo_Mod          
       (  
        UserLoginID  
        ,EmployeeID   
        ,IsEmployee   
        ,UserName  
        ,LoginPassword   
        ,UserLocation   
        ,DeptGroupCode   
        ,Activate    
        ,IsChecker  
        --,IsChecker2    -- Commented by shubham on 2024-01-25 Because Checker 2 not available on Production  
        ,AuthorisationStatus   
        ,EffectiveFromTimeKey                            
        ,EffectiveToTimeKey                 
        ----,EntityKey   
        ,PasswordChanged  
        ,PasswordChangeDate  
        ,ChangePwdCnt  
        ,UserLocationCode  
        ,UserRoleAlt_Key  
        ,SuspendedUser  
        ,CurrentLoginDate  
        ,ResetDate  
        ,UserLogged  
        ,UserDeletionReasonAlt_Key  
        ,SystemLogOut  
        ,RBIFLAG  
        ,Email_ID --ad4  
        ,MobileNo  
        ,DesignationAlt_Key  
        ,isCma  
        ,SecuritQsnAlt_Key  
        ,SecurityAns  
        ,MenuId  
        ,CreatedBy  
        ,DateCreated  
        ,ModifyBy  
        ,DateModified  
        ,ApprovedBy  
        ,DateApproved  
        ,MIS_APP_USR_ID  
        ,MIS_APP_USR_PASS  
        ,UserLocationExcel  
        ,WorkFlowUserRoleAlt_Key  
        ,D2K_PSlt  
        ,SourceAlt_Key  
        ,UserType  
       )          
      VALUES(    
        @UserLoginID  
        ,@EmployeeID   
        ,@IsEmployee   
        ,@UserName  
        ,@LoginPassword   
        ,@UserLocation  
        ,@DeptGroupCode   
        ,@Activate    
        ,@IsChecker   
        --,@IsChecker2     -- Commented by shubham on 2024-01-25 Because Checker 2 not available on Production  
        ,@AuthorisationStatus  
        ,@EffectiveFromTimeKey                         
        ,@EffectiveToTimeKey                  
        ------,@Entity_Key   
        ,'N'   
        ,NULL  
        ,0  
        ,@UserLocationCode  
        ,@UserRoleAlt_Key  
        ,'N'  
        ,NULL--CurrentLoginDate  
        ,NULL--ResetDate  
        ,0  
        ,NULL  
        ,NULL  
        ,NULL  
        ,NULLIF(@Email_ID,'') --ad4  
        ,@MobileNo  
        ,@DesignationAlt_Key  
        ,@isCma  
        ,@SecuritQsnAlt_Key  
        ,@SecurityAns  
        ,@MenuId  
        ,@CreatedBy  
        ,@DateCreated  
        ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
        ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
        ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
        ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END  
        ,NULL  
        ,NULL  
        ,NULL  
        ,@WorkFlowUserRoleAlt_Key  
        ,@D2K_PSlt  
        ,@SourceAlt_Key  
        ,'Employee'  
        )  
  
  
               
  
  
           IF @OperationFlag =1 AND @AUTHMODE='Y'  
     BEGIN  
      PRINT 3  
      GOTO DimUserInfo_Insert_Add  
     END  
    ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'  
     BEGIN  
      GOTO DimUserInfo_Insert_Edit_Delete  
     END  
       
  
      
 END  
  
  
IF @OperationFlag=16
BEGIN
/*ROLE UPDATE IN USERROLEWISEMATRIX ADDED BY ZAIN ON 2024-11-29*/
								UPDATE A
									SET A.UserRole =(CASE WHEN @UserRoleAlt_Key=1 THEN 'SUPER ADMIN'
														WHEN  @UserRoleAlt_Key=2 THEN 'ADMIN'
														WHEN  @UserRoleAlt_Key=3 THEN 'OPERATOR'
														ELSE
														 'VIEWER'END)
										,A.ModifyBy=@CreatedModifiedBy
										,A.DateModified=GETDATE()
									FROM UserRoleWiseMatrix A
									WHERE A.ADID=@UserLoginID
										AND (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey >=@Timekey)

/*ROLE UPDATE IN USERROLEWISEMATRIX ADDED BY ZAIN ON 2024-11-29 END*/
END
  
 -------------------  
PRINT 7  
  COMMIT TRANSACTION  
  
  SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimUserInfo WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
                 AND UserLoginID=@UserLoginID  
  
  IF @OperationFlag =3  
   BEGIN  
    SET @Result=0  
   END  
  ELSE  
   BEGIN  
    SET @Result=1  
   END  
END TRY  
BEGIN CATCH  
 ROLLBACK TRAN  
 SELECT ERROR_MESSAGE()  
 RETURN -1  
  
END CATCH  
---------  
END  
GO