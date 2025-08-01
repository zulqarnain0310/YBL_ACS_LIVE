﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROC [dbo].[CollateralDetailInUp]  
  
--Declare  
         
       @UCICID      varchar(12)=''   
       ,@CustomerID     varchar(100)=''  
       ,@CustomerName     varchar(200)=''  
       ,@TaggingAlt_Key    Int=4  
       ,@LiabID                        varchar(100)=''  
       ,@AssetID                       Varchar(25)=''   
       ,@Segment                       varchar(20)=''  
       ,@CRE                           varchar(5)=''  
       ,@CollateralSubTypeAlt_Key  int=0  
       ,@SeniorityofCharge             varchar(50)=''  
       ,@SecurityStatus                varchar(25)=''  
       ,@FDNo                          Varchar(20)=''
       ,@ISINNo                        varchar(25)=''  
       ,@FolioNo                       varchar(25)=''  
       ,@QtyShares_MutualFunds_Bonds   bigint=0  
       ,@Line_No                       varchar(300)=''  
       ,@CrossCollateral_LiabID        varchar(100)=''  
       ,@NameSecuPvd                    varchar(500)=''  
       ,@PropertyAdd                    varchar(2500)=''  
       ,@PIN                           Int=0  
       ,@DtStockAudit                  Varchar(20)=NULL  
       ,@SBLCIssuingBank               Varchar(100)  
       ,@SBLCNumber                   Varchar(25)  
       ,@CurSBLCissued                Varchar(15)  
       ,@SBLCFCY                      Decimal(16,2)  
       ,@DtexpirySBLC                 Varchar(20)=NULL  
       ,@DtexpiryLIC                  Varchar(20)=NULL  
       ,@ModeOperation                 Varchar(15)  
       ,@ExceApproval                  Varchar(15)  
       ,@CollateralID     Varchar(30)='123'  
       ,@ChangeField                   Varchar(Max)=''  
         
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
      ,@SecurityEntityID          INT =NULL  
      ,@OldCollateralID           VARCHAR(20) =''  
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
      ,@ApprovedByFirstLevel  VARCHAR(20)  = NULL  
      ,@DateApprovedFirstLevel SMALLDATETIME = NULL  
      ,@ErrorHandle    int    = 0  
      ,@ExEntityKey    int    = 0    
      ,@AccountEntityId            int    = 0    
      ,@CustomerEntityId            int    = 0   
------------Added for Rejection Screen  29/06/2020   ----------  
  
  DECLARE   @Uniq_EntryID   int = 0  
      ,@RejectedBY   Varchar(50) = NULL  
      ,@RemarkBy    Varchar(50) = NULL  
      ,@RejectRemark   Varchar(200) = NULL  
      ,@ScreenName   Varchar(200) = NULL  
      ,@CollIDAutoGenerated   Int  
      --,@SecurityEntityID      smallint  
  
    SET @ScreenName = 'Collateral Detail'  
  
  
 -------------------------------------------------------------  
  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')   
  
 SET @EffectiveFromTimeKey = @TimeKey  
  
 SET @EffectiveToTimeKey = 49999  
  
 --SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)  
  Declare @Year INT
Declare @FromDate Varchar(10)
Declare @ToDate Varchar(10)
SET @Year=DATEPART(YEAR,Getdate())

SET @FromDate=Convert(Varchar(4),(@Year-1))+'-04-01' 
SET @ToDate=Convert(Varchar(4),(@Year))+'-03-31' 
  
 IF @DtexpirySBLC=''  
     SET @DtexpirySBLC=NULL  
  
   
 IF @DtexpiryLIC=''  
     SET @DtexpiryLIC=NULL  
  
 IF @DtStockAudit=''  
     SET @DtStockAudit=NULL  
              
 PRINT 'A'  
   
  
   DECLARE @AppAvail CHAR  
     SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)  
    IF(@AppAvail='N')              
     BEGIN  
      SET @Result=-11  
      RETURN @Result  
     END  
  
    --IF @AccountID<>''  
    --    Select @AccountEntityId=AccountEntityId from advacbasicdetail  
    -- Where CustomerACId=@AccountID  
  
  
    --IF @CustomerID<>''  
    -- Select @CustomerEntityId=CustomerEntityId from CustomerBasicdetail  
    -- Where CustoSEECURITmerId=@CustomerID  
      
  IF (@CollateralID='' or @CollateralID='0')
       BEGIN
	          SET @CollateralID='123'
	   END
  
  
 IF @OperationFlag=1  --- add  
 BEGIN  
 PRINT 1  
  -----CHECK DUPLICATE  
  IF EXISTS(                      
     SELECT  1 FROM Curdat.AdvSecurityDetail WHERE  CollateralID=@CollateralID AND ISNULL(AuthorisationStatus,'A')='A'   
     and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey  
     UNION  
     SELECT  1 FROM DBO.AdvSecurityDetail_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
                AND CollateralID=@CollateralID  
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
     PRINT 'SacMainTabbleTest'
      Select @SecurityEntityID=  MAX(ISNULL(SecurityEntityID,0))+1  
      from(  
      select max(SecurityEntityID) SecurityEntityID from DBO.AdvSecurityDetail_Mod  
        UNION  
        select max(SecurityEntityID) SecurityEntityID from Curdat.AdvSecurityDetail  
        )A  
  
         IF (@SecurityEntityID IS NULL)  
  
        SET   @SecurityEntityID=1  
  
   END  
  
  
  
        
  
  ---------------------Added on 29/05/2020 for user allocation rights  
  /*  
  IF @AccessScopeAlt_Key in (1,2)  
  BEGIN  
  PRINT 'Sunil'  
  
  IF EXISTS(                      
     SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey  
     And IsChecker='N'  
    )   
    BEGIN  
       PRINT 2  
     SET @Result=-6  
     RETURN @Result -- USER SHOULD HAVE CHECKER RIGHTS   
    END  
  END  
  
    
  IF @AccessScopeAlt_Key in (3)  
  BEGIN  
  PRINT 'Sunil1'  
  
  IF EXISTS(                      
     SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey  
     And IsChecker='Y'  
    )   
    BEGIN  
       PRINT 2  
     SET @Result=-8  
     RETURN @Result -- USER SHOULD NOT HAVE CHECKER RIGHTS   
    END  
  END  
  */  
----------------------------------------  
 END  
  
   
 BEGIN TRY  
 BEGIN TRANSACTION   
 -----  
   
 PRINT 3   
  --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
 IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD  
  BEGIN  
         PRINT 'Add'  
     SET @CollIDAutoGenerated=0  
     --SET @SecurityEntityID=0  
                   -- Select @CollIDAutoGenerated=  MAX(Convert(Int,ISNULL(CollateralID,0))) from DBO.AdvSecurityDetail_Mod  
       Select @CollIDAutoGenerated= MAX(Convert(Int,ISNULL(CollateralID,0))) From(  
     Select MAX(Convert(Int,ISNULL(CollateralID,0))) as CollateralID from Curdat.AdvSecurityDetail  
     UNION ALL  
     Select MAX(Convert(Int,ISNULL(CollateralID,0))) as CollateralID from DBO.AdvSecurityDetail_Mod  
     UNION ALL  
     Select MAX(Convert(Int,ISNULL(CollateralID,0))) as CollateralID from Curdat.AdvSecurityValueDetail  
     UNION ALL  
      Select MAX(Convert(Int,ISNULL(CollateralID,0))) as CollateralID from DBO.AdvSecurityValueDetail_Mod  
      UNION ALL  
      Select MAX(Convert(Int,ISNULL(CollateralID,0))) as CollateralID from DBO.CollateralDetailUpload_Mod  
      )X  
  
     IF (@CollIDAutoGenerated IS NULL)  
  
      SET   @CollIDAutoGenerated=1000001  
  
     ELSE   
         SET    @CollIDAutoGenerated=Convert(Int,@CollIDAutoGenerated)+1  
  
      --Print '@CollIDAutoGenerated'  
      --Print @CollIDAutoGenerated  
        
      SET @CollateralID=Convert(Varchar(30),@CollIDAutoGenerated)  
      SET @CreatedBy =@CrModApBy   
      SET @DateCreated = GETDATE()  
      SET @AuthorisationStatus='NP'  
      --SET @GLAlt_Key = (Select ISNULL(Max(GLAlt_Key),0)+1 from   
      --      (Select GLAlt_Key from DimGL  
      --       UNION   
      --       Select GLAlt_Key from DimGL_Mod  
      --      )A)  
      PRINT '@SecurityEntityID'  
      PRINT @SecurityEntityID  
  
      PRINT '@@CollateralID'  
      PRINT @CollateralID  
  
      GOTO Collateral_Insert  
     Collateral_Insert_Add:  
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
       SELECT  @SecurityEntityID=SecurityEntityID  
         
     FROM DBO.AdvSecurityDetail_Mod   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CollateralID =@CollateralID  
       AND AuthorisationStatus IN('NP','MP','A','RM')  
         
      END  
  
     ELSE  
      BEGIN  
       PRINT 'DELETE'  
       SET @AuthorisationStatus ='DP'  
         
      END  
  
      ---FIND CREATED BY FROM MAIN TABLE  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM Curdat.AdvSecurityDetail    
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CollateralID =@CollateralID  
  
    ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
    IF ISNULL(@CreatedBy,'')=''  
    BEGIN  
     PRINT 'NOT AVAILABLE IN MAIN'  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM DBO.AdvSecurityDetail_Mod   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CollateralID =@CollateralID  
       AND AuthorisationStatus IN('NP','MP','A','RM')  
                 
    END  
    ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE  
     BEGIN  
            Print 'AVAILABLE IN MAIN'  
      ----UPDATE FLAG IN MAIN TABLES AS MP  
      UPDATE Curdat.AdvSecurityDetail  
       SET AuthorisationStatus=@AuthorisationStatus  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND CollateralID =@CollateralID  
  
     END  
  
     --UPDATE NP,MP  STATUS   
     IF @OperationFlag=2  
     BEGIN   
  
      UPDATE DBO.AdvSecurityDetail_Mod  
       SET AuthorisationStatus='FM'  
       ,ModifiedBy=@Modifiedby  
       ,DateModified=@DateModified  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND CollateralID =@CollateralID  
        AND AuthorisationStatus IN('NP','MP','RM')  
     END  
  
     GOTO Collateral_Insert  
     Collateral_Insert_Edit_Delete:  
    END  
  
  ELSE IF @OperationFlag =3 AND @AuthMode ='N'  
  BEGIN  
  -- DELETE WITHOUT MAKER CHECKER  
             
      SET @Modifiedby   = @CrModApBy   
      SET @DateModified = GETDATE()   
  
     UPDATE Curdat.AdvSecurityDetail SET  
         ModifiedBy =@Modifiedby  
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CollateralID=@CollateralID  
    
  
  end  
  
----------------------------------------------------------------------------------  
 ELSE IF @OperationFlag=21 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE DBO.AdvSecurityDetail_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND CollateralID =@CollateralID  
      AND AuthorisationStatus in('NP','MP','DP','RM','1A')   
  
  
    IF EXISTS(SELECT 1 FROM Curdat.AdvSecurityDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CollateralID=@CollateralID)  
    BEGIN  
     UPDATE Curdat.AdvSecurityDetail  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CollateralID =@CollateralID  
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
---------------------------------------------------------------------------------------------   
 ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE DBO.AdvSecurityDetail_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND CollateralID =@CollateralID  
      AND AuthorisationStatus in('NP','MP','DP','RM')   

	  UPDATE DBO.AdvSecurityValueDetail_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND CollateralID =@CollateralID  
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
---------------Added for Rejection Pop Up Screen  29/06/2020   ----------  
  
  Print 'Sunil'  
  
--  DECLARE @EntityKey as Int   
  --SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey  
  --      FROM DimGL_Mod   
  --      WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )  
  --       AND GLAlt_Key=@GLAlt_Key And ISNULL(AuthorisationStatus,'A')='R'  
    
-- EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy  
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName  
    
  
--------------------------------  
  
    IF EXISTS(SELECT 1 FROM Curdat.AdvSecurityDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CollateralID=@CollateralID)  
    BEGIN  
     UPDATE Curdat.AdvSecurityDetail  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CollateralID =@CollateralID  
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  

	IF EXISTS(SELECT 1 FROM Curdat.AdvSecurityValueDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CollateralID=@CollateralID)  
    BEGIN  
     UPDATE Curdat.AdvSecurityValueDetail  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CollateralID =@CollateralID  
       AND AuthorisationStatus IN('MP','DP','RM')    
END  
  END   
  
 ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CrModApBy  
  SET @DateApproved=GETDATE()  
  UPDATE DBO.AdvSecurityDetail_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  AND CollateralID=@CollateralID  
  
 END  
  
  --    ELSE IF @OperationFlag=16  
  
  --BEGIN  
  
  --SET @ApprovedBy    = @CrModApBy   
  --SET @DateApproved  = GETDATE()  
  --SET @ApprovedByFirstLevel    = @CrModApBy   
  --SET @DateApprovedFirstLevel  = GETDATE()  
  
  --UPDATE DBO.AdvSecurityDetail_Mod  
  --    SET AuthorisationStatus ='1A'  
  --     ,ApprovedByFirstLevel=@ApprovedBy  
  --     ,DateApprovedFirstLevel=@DateApproved  
  --     WHERE CollateralID=@CollateralID  
  --     AND AuthorisationStatus in('NP','MP','DP','RM')  
  
  
  
  --END  
  
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
      FROM Curdat.AdvSecurityDetail   
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )  
       AND CollateralID=@CollateralID  
       
     SET @ApprovedBy = @CrModApBy     
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
     SELECT @ExEntityKey= MAX(EntityKey) FROM DBO.AdvSecurityDetail_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND CollateralID=@CollateralID  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
  
     SELECT @DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated  
      ,@ModifiedBy=ModifiedBy, @DateModified=DateModified,@SecurityEntityID=SecurityEntityID,  
      @ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel  
      FROM DBO.AdvSecurityDetail_Mod  
      WHERE EntityKey=@ExEntityKey  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
      
       
     DECLARE @CurEntityKey INT=0  
  
     SELECT @ExEntityKey= MIN(EntityKey) FROM DBO.AdvSecurityDetail_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND CollateralID=@CollateralID  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
      
     SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey   
       FROM DBO.AdvSecurityDetail_Mod  
       WHERE EntityKey=@ExEntityKey  
  
     UPDATE DBO.AdvSecurityDetail_Mod  
      SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
      AND CollateralID=@CollateralID  
      AND AuthorisationStatus='A'   
  
  -------DELETE RECORD AUTHORISE  
     IF @DelStatus='DP'   
     BEGIN   
      UPDATE DBO.AdvSecurityDetail_Mod  
      SET AuthorisationStatus ='A'  
       ,ApprovedBy=@ApprovedBy  
       ,DateApproved=@DateApproved  
       ,EffectiveToTimeKey =@EffectiveFromTimeKey -1  
      WHERE CollateralID=@CollateralID  
       AND AuthorisationStatus in('NP','MP','DP','RM','1A')  
        
      IF EXISTS(SELECT 1 FROM Curdat.AdvSecurityDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND CollateralID=@CollateralID)  
      BEGIN  
        UPDATE Curdat.AdvSecurityDetail  
         SET AuthorisationStatus ='A'  
          ,ModifiedBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND CollateralID=@CollateralID  
  
          
      END  
     END -- END OF DELETE BLOCK  
  
     ELSE  -- OTHER THAN DELETE STATUS  
     BEGIN  
           Print '@DelStatus'  
        Print  @DelStatus  
         Print '@AuthMode'  
        Print  @AuthMode  
  
       UPDATE DBO.AdvSecurityDetail_Mod  
        SET AuthorisationStatus ='A'  
         ,ApprovedBy=@ApprovedBy  
         ,DateApproved=@DateApproved  
        WHERE CollateralID=@CollateralID      
         AND AuthorisationStatus in('NP','MP','RM','1A')  
           
  
     
  
           
     END    
    END  
  
  
  
  IF @DelStatus <>'DP' OR @AuthMode ='N'  
    BEGIN  
         PRINT 'Check'  
      DECLARE @IsAvailable CHAR(1)='N'  
      ,@IsSCD2 CHAR(1)='N'  
        SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020  
  
      IF EXISTS(SELECT 1 FROM Curdat.AdvSecurityDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND CollateralID=@CollateralID)  
       BEGIN  
        SET @IsAvailable='Y'  
        --SET @AuthorisationStatus='A'  
  
   PRINT 'MainStart'
        IF EXISTS(SELECT 1 FROM Curdat.AdvSecurityDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@TimeKey AND CollateralID=@CollateralID)  
         BEGIN  
         PRINT 'MainStart1'  
          UPDATE Curdat.AdvSecurityDetail SET  
                         
             UCICID       = @UCICID        
             ,RefCustomerId      = @CustomerID       
             ,CustomerName      = @CustomerName       
             ,TaggingAlt_Key     = @TaggingAlt_Key   
             ,LiabID                             =@LiabID   
             ,AssetID         =@AssetID  
             ,Segment                            =@Segment   
             ,CRE                                =@CRE  
             ,CollateralSubTypeAlt_Key   = @CollateralSubTypeAlt_Key   
             ,SeniorityofCharge      =@SeniorityofCharge  
             ,SecurityStatus                     =@SecurityStatus   
             ,FDNo                               =@FDNo   
             ,ISINNo                             =@ISINNo   
             ,FolioNo                            =@FolioNo   
             ,QtyShares_MutualFunds_Bonds        =@QtyShares_MutualFunds_Bonds  
             ,Line_No                            =@Line_No  
             ,CrossCollateral_LiabID             =@CrossCollateral_LiabID   
             ,NameSecuPvd                        =@NameSecuPvd    
             ,PropertyAdd                        =@PropertyAdd   
             ,PIN                                =@PIN   
             ,DtStockAudit                       =Convert(date,@DtStockAudit)   
             ,SBLCIssuingBank                    =@SBLCIssuingBank   
             ,SBLCNumber                         =@SBLCNumber   
             ,CurSBLCissued                      =@CurSBLCissued   
             ,SBLCFCY                             =@SBLCFCY   
             ,DtexpirySBLC                         =Convert(date,@DtexpirySBLC )   
             ,DtexpiryLIC                          =Convert(date,@DtexpiryLIC)  
             ,ModeOperation                     =@ModeOperation   
             ,ExceApproval                      =@ExceApproval  
             ,CollateralID      = @CollateralID     
                   
              
            ,ApprovedByFirstLevel=@ApprovedByFirstLevel  
            ,DateApprovedFirstLevel=@DateApprovedFirstLevel  
            ,ModifiedBy     = @ModifiedBy  
            ,DateModified    = @DateModified  
            ,ApprovedBy     = CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END  
            ,DateApproved    = CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END  
            ,AuthorisationStatus  = CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END  
      
          WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND CollateralID=@CollateralID  
         END   
  
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
  
        IF @IsAvailable='N' OR @IsSCD2='Y'  
         BEGIN  
         PRINT 'Insert into Main Table'  
         PRINT '@ExEntityKey'  
         PRINT @ExEntityKey  
		 
Select @SecurityEntityID=  MAX(ISNULL(SecurityEntityID,0))+1  
      from(  
      select max(SecurityEntityID) SecurityEntityID from DBO.AdvSecurityDetail_Mod  
        UNION  
        select max(SecurityEntityID) SecurityEntityID from Curdat.AdvSecurityDetail  
        )A  
  
         IF (@SecurityEntityID IS NULL)  
  
        SET   @SecurityEntityID=1

          INSERT INTO Curdat.AdvSecurityDetail  
            (  
                 EntityKey,  
               UCICID  
               ,SecurityEntityID  
             ,RefCustomerId       
             ,CustomerName      
             ,TaggingAlt_Key   
             ,LiabID   
             ,AssetID   
             ,Segment  
             ,CRE   
   ,CollateralSubTypeAlt_Key   
             ,SeniorityofCharge  
             ,SecurityStatus   
             ,FDNo   
             ,ISINNo   
             ,FolioNo     
             ,QtyShares_MutualFunds_Bonds  
             ,Line_No     
             ,CrossCollateral_LiabID         
             ,NameSecuPvd      
             ,PropertyAdd    
             ,PIN      
             ,DtStockAudit        
             ,SBLCIssuingBank     
             ,SBLCNumber      
             ,CurSBLCissued   
             ,SBLCFCY           
             ,DtexpirySBLC      
             ,DtexpiryLIC      
             ,ModeOperation   
             ,ExceApproval       
             ,CollateralID   
            ,AuthorisationStatus  
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy   
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
             ,EntryType
			,SecurityType  
            )  
  
          SELECT        @ExEntityKey  
                     
              ,@UCICID   
              ,@SecurityEntityID  
                                                   ,@CustomerID       
             ,@CustomerName      
             ,@TaggingAlt_Key   
             ,@LiabID   
             ,@AssetID   
             ,@Segment  
             ,@CRE   
             ,@CollateralSubTypeAlt_Key   
             ,@SeniorityofCharge  
             ,@SecurityStatus   
             ,@FDNo   
             ,@ISINNo   
             ,@FolioNo     
             ,@QtyShares_MutualFunds_Bonds  
             ,@Line_No     
             ,@CrossCollateral_LiabID         
             ,@NameSecuPvd      
             ,@PropertyAdd    
             ,@PIN      
             ,@DtStockAudit        
             ,@SBLCIssuingBank     
             ,@SBLCNumber      
             ,@CurSBLCissued   
             ,@SBLCFCY           
             ,@DtexpirySBLC      
             ,@DtexpiryLIC      
             ,@ModeOperation   
             ,@ExceApproval       
             ,@CollateralID   
            ,CASE WHEN @AUTHMODE= 'Y' THEN   (@AuthorisationStatus) ELSE NULL END  
            ,@EffectiveFromTimeKey  
            ,@EffectiveToTimeKey  
            ,@CreatedBy   
            ,@DateCreated  
            ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END  
            ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END  
            ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END  
            ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END  
            ,'Corporate'
		    ,'C'   
  
  
              
   
            
         END  
  	--Update A	
			--SET A.CustomerEntityId=B.CustomerEntityID
			--FROM Curdat.AdvSecurityDetail A
			--INNER JOIN PRO.CustomerCal_Hist B ON A.UCICID=B.UCIF_ID 
			--WHERE A.UCICID=@UCICID

			Declare @SecurityEntityID1          bigINT =NULL 

Select @SecurityEntityID1=  MAX(ISNULL(SecurityEntityID,0))+1  
      from(  
      select max(SecurityEntityID) SecurityEntityID from DBO.AdvSecurityValueDetail_Mod  
        UNION  
        select max(SecurityEntityID) SecurityEntityID from Curdat.AdvSecurityValueDetail  
        )A  
  
         IF (@SecurityEntityID1 IS NULL)  
  
        SET   @SecurityEntityID1=1  

 ---Adding SecurityValueDetail
   DECLARE @IsAvailableValue CHAR(1)='N' 
 IF EXISTS(SELECT 1 FROM Curdat.AdvSecurityValueDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND CollateralID=@CollateralID)  
       BEGIN  
        SET @IsAvailableValue='Y'  
        --SET @AuthorisationStatus='A'  
  
  PRINT 'ValueStart'
 IF EXISTS(SELECT 1 FROM DBO.AdvSecurityValueDetail_MOD WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@TimeKey AND CollateralID=@CollateralID And AuthorisationStatus in ('MP') )  
         BEGIN  
 PRINT 'ValueStart1'            
          	UPDATE A SET  
                         
             A.ValuationDate       =  B.ValuationDate        
             ,A.CurrentValue      = B.CurrentValue       
             ,A.ValuationExpiryDate      = B.ValuationExpiryDate 
			 ,A.ModifiedBy     = @ModifiedBy  
            ,A.DateModified    = @DateModified
	FROM  Curdat.AdvSecurityValueDetail A  INNER JOIN
	(
	Select ValuationDate,CurrentValue,ValuationExpiryDate,CollateralID
	FROM DBO.AdvSecurityValueDetail_MOD 
	 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
	 AND CollateralID=@CollateralID
	 
	 ) B  On A.CollateralID=B.CollateralID
Where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
 AND A.CollateralID=@CollateralID

 Update  Curdat.AdvSecurityValueDetail
 SET AuthorisationStatus='A'
 Where CollateralID=@CollateralID AND AuthorisationStatus in ('MP','NP')

  Update  DBO.AdvSecurityValueDetail_MOD 
 SET AuthorisationStatus='A'
 Where CollateralID=@CollateralID AND AuthorisationStatus in ('MP','NP')
		
 END   
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
  
        IF @IsAvailableValue='N' OR @IsSCD2='Y'  
         BEGIN  
         PRINT 'Insert into Valuedetail Table'  
         PRINT '@ExEntityKey'  
         PRINT @ExEntityKey  
		 
		

		  
          insert into Curdat.AdvSecurityValueDetail   
     (    ENTITYKEY
     ,CollateralID    
     ,SecurityEntityID    
     ,ValuationDate    
     ,CurrentValue    
     ,ValuationExpiryDate    
     ,ExpiryBusinessRule    
     ,Periodinmonth    
         
     ,EffectiveFromTimeKey    
     ,EffectiveToTimeKey    
      ,AuthorisationStatus 
	  ,CreatedBy      
     ,DateCreated
	 ,ModifiedBy
	 ,DateModified
     ,ApprovedBy    
     ,DateApproved)    
    
   Select  ENTITYKEY 
   
      ,CollateralID    
             
      ,@SecurityEntityID1+Row_Number()Over(order by (Select 1)) 
            ,ValuationDate     
           ,CurrentValue     
     ,ValuationExpiryDate       
     ,ExpiryBusinessRule          
     ,Periodinmonth     
               
     ,EffectiveFromTimeKey     
     ,EffectiveToTimeKey     
       ,'A'  
	   ,CreatedBy      
     ,DateCreated
	 ,ModifiedBy
	 ,DateModified
      ,@ApprovedBy       
      ,GETDATE()    
  from DBO.AdvSecurityValueDetail_MOD 
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
           -- AND EffectiveFromTimeKey=@TimeKey Issued Authorised on 12-11-2021
			 AND CollateralID=@CollateralID
			AND AuthorisationStatus in('NP','MP')      
  
  Update  Curdat.AdvSecurityValueDetail
 SET AuthorisationStatus='A'
 Where CollateralID=@CollateralID AND AuthorisationStatus in ('MP','NP')

  Update  DBO.AdvSecurityValueDetail_MOD 
 SET AuthorisationStatus='A'
 Where CollateralID=@CollateralID AND AuthorisationStatus in ('MP','NP') 
              
    Declare @collateralCount Int

		 SELECT @collateralCount=Count(*) FROM Curdat.AdvSecurityValueDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@TimeKey AND CollateralID=@CollateralID

			IF @collateralCount>2
			   BEGIN
			       
				 Update Curdat.AdvSecurityValueDetail     
				 SET EffectiveFromTimeKey=@Timekey-1,      
				 EffectiveToTimeKey=@Timekey-1
				 Where CollateralID=@CollateralID  
			      AND  SecurityEntityID IN(Select MIN(SecurityEntityID)
			      FROM Curdat.AdvSecurityValueDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
				  AND EffectiveFromTimeKey=@TimeKey AND CollateralID=@CollateralID)

			   END
            
         END  
---------------------New Logic----------------

--	 IF OBJECT_ID('TempDB..#temp') IS NOT NULL DROP TABLE  #temp;

--Select CollateralID,Sum(CurrentValue) SecurityValue into #tmp from  Curdat.AdvsecurityValueDetail
--Where Convert(date,ValuationDate)>=Convert(Date,@FromDate) AND Convert(date,ValuationDate)<=Convert(Date,@ToDate)

--Group By CollateralID

--Update A
--SET A.TotalSecurityMarOfPreviousFY=B.SecurityValue
--From Curdat.AdvsecurityValueDetail A
--INNER JOIN #tmp B
--ON A.CollateralID=B.CollateralID

---------------------------
            
  
-----------------Added on 13-03-2021  
 ------------------------------------------------------  
        
    
  
  
  
  
----------------------------------------------------------------------------------------------------  
PRINT 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'  
         IF @IsSCD2='Y'   
         --SELECT * FROM  
         --Curdat.AdvSecurityDetail  
         --WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CollateralID=@CollateralID  
         --  AND EffectiveFromTimekey<@EffectiveFromTimeKey  
        BEGIN  
        UPDATE Curdat.AdvSecurityDetail SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1  
          ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
         WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CollateralID=@CollateralID  
           AND EffectiveFromTimekey<@EffectiveFromTimeKey  
        END  
        PRINT 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'  
       END  
  
  IF @AUTHMODE='N'  
   BEGIN  
     SET @AuthorisationStatus='A'  
     GOTO Collateral_Insert  
     HistoryRecordInUp:  
   END        
  
  
  
  END   
  
    
  
PRINT 6  
SET @ErrorHandle=1  
  
Collateral_Insert:  
         
IF @ErrorHandle=0  
 BEGIN  
  
             PRINT '@SecurityEntityIDSac'  
      PRINT @SecurityEntityID  
   INSERT INTO DBO.AdvSecurityDetail_Mod    
           (   
                 UCICID  
              ,SecurityEntityID  
             ,RefCustomerId     
             ,CustomerName      
             ,TaggingAlt_Key   
             ,LiabID   
             ,AssetID   
             ,Segment  
             ,CRE   
             ,CollateralSubTypeAlt_Key   
             ,SeniorityofCharge  
             ,SecurityStatus   
             ,FDNo   
             ,ISINNo   
             ,FolioNo     
             ,QtyShares_MutualFunds_Bonds  
             ,Line_No     
             ,CrossCollateral_LiabID         
             ,NameSecuPvd      
             ,PropertyAdd    
             ,PIN      
             ,DtStockAudit        
             ,SBLCIssuingBank     
             ,SBLCNumber      
             ,CurSBLCissued   
             ,SBLCFCY           
             ,DtexpirySBLC      
             ,DtexpiryLIC      
             ,ModeOperation   
             ,ExceApproval       
             ,CollateralID   
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
        VALUES  
           (        @UCICID  
           ,@SecurityEntityID  
                                                   ,@CustomerID       
             ,@CustomerName      
        ,@TaggingAlt_Key   
             ,@LiabID   
             ,@AssetID   
             ,@Segment  
             ,@CRE   
             ,@CollateralSubTypeAlt_Key   
             ,@SeniorityofCharge  
             ,@SecurityStatus   
             ,@FDNo   
             ,@ISINNo   
             ,@FolioNo     
             ,@QtyShares_MutualFunds_Bonds  
             ,@Line_No     
             ,@CrossCollateral_LiabID         
             ,@NameSecuPvd      
             ,@PropertyAdd    
             ,@PIN      
             ,@DtStockAudit        
             ,@SBLCIssuingBank     
             ,@SBLCNumber      
             ,@CurSBLCissued   
             ,@SBLCFCY           
             ,@DtexpirySBLC      
             ,@DtexpiryLIC      
             ,@ModeOperation   
             ,@ExceApproval       
             ,@CollateralID   
             ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END  
               
             )  
   
   
  
           IF @OperationFlag =1 AND @AUTHMODE='Y'  
     BEGIN  
      PRINT 3  
      GOTO Collateral_Insert_Add  
     END  
    ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'  
     BEGIN  
      GOTO Collateral_Insert_Edit_Delete  
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