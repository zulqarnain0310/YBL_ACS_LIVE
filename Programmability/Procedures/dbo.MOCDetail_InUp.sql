SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MOCDetail_InUp]
@MocCustomerDataEntityId	INT = 0
,@CustomerEntityId		INT
,@SysAssetClassAlt_Key  VARCHAR(20)
,@SysNPA_Dt				VARCHAR(10)
,@CurntQtrRv			Decimal(18,2)
,@AddlProvisionPer		Decimal(5,2)
,@MOCReason				VARCHAR(500)
,@MOCTYPE				VARCHAR(15)	='AUTO'	
,@XMLDocument          XML=''    
,@EffectiveFromTimeKey INT=0
,@EffectiveToTimeKey   INT=0
,@OperationFlag		   INT=0
,@AuthMode			   CHAR(1)='N'
,@CrModApBy			   VARCHAR(50)=''
,@TimeKey			   INT=0
,@Result			   INT=0 output
,@D2KTimeStamp		   INT=0 output
,@Remark			   VARCHAR(200)=''
,@MenuId				INT = 6100
,@ErrorMsg				VARCHAR(MAX)='' output
As
BEGIN
		ExEC [dbo].[MOC_CustomerDetail_InUp]
		  @MocCustomerDataEntityId = @MocCustomerDataEntityId,
                @CustomerEntityId = @CustomerEntityId,
                --@CustomerID = NULL,
                --@SourceSystemCustomerID = NULL,
                --@CustomerName = NULL,
                @AssetClassification =@SysAssetClassAlt_Key,
                @NPADate = @SysNPA_Dt,
                @SecurityValue = @CurntQtrRv,
                @AdditionalProvision = @AddlProvisionPer,
                @MOCReason = @MOCReason,
                @Remark = @Remark,
                @MenuID = @MenuId,
                @OperationFlag = @OperationFlag,
                @AuthMode = @AuthMode,
                @EffectiveFromTimeKey = @EffectiveFromTimeKey,
                @EffectiveToTimeKey = @EffectiveToTimeKey,
                @TimeKey = @TimeKey,
                @CrModApBy = @CrModApBy,
				@MOCTYPE = @MOCTYPE,
                @D2Ktimestamp = @D2Ktimestamp OUTPUT,
                @Result = @Result OUTPUT

		

		EXEC [dbo].[MOC_AccountDetail_InUp]

				@CustomerEntityId = @CustomerEntityId,
                --@CustomerID = NULL,
                --@CustomerName = NULL,
                --@SourceSystemCustomerID = NULL,
                @MOCReason = @MOCReason,
                @XMLDocument =@XMLDocument,
                @EffectiveFromTimeKey = @EffectiveFromTimeKey,
                @EffectiveToTimeKey = @EffectiveToTimeKey,
                @OperationFlag = @OperationFlag,
                @AuthMode = @AuthMode,
                @CrModApBy = @CrModApBy,
                @TimeKey = @TimeKey,
                @Result = @Result OUTPUT,
                @D2KTimeStamp = @D2KTimeStamp OUTPUT,
                @Remark = NULL,
                @MenuId = 1,
                @ErrorMsg = @ErrorMsg OUTPUT


END						            


GO