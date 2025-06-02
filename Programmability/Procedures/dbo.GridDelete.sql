SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[GridDelete]
		
		@CustomerID VARCHAR(12)='',
		@Lendername VARCHAR(100)='',
		

		---------D2k System Common Columns-----------
		@OperationFlag	TINYINT	= 3,
		@AuthMode CHAR(1) = 'N',
		@EffectiveFromTimeKey INT = 0,
		@EffectiveToTimeKey	INT = 0,
		@TimeKey INT = 0,
		@CrModApBy VARCHAR(20) = NULL


AS
	BEGIN

	DECLARE

		@ModifiedBy	VARCHAR(20)	= NULL,
		@DateModified SMALLDATETIME	= NULL
				
			
			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
			SET @EffectiveFromTimeKey  = @TimeKey
			SET @EffectiveToTimeKey = 49999

		
IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE RP_Lender_Details SET
									 ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									from RP_Lender_Details  A
									INNER Join DimBankRP B ON A.ReportingLenderAlt_Key=B.BankRPAlt_Key
									AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 
									WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
									AND CustomerID=@CustomerID AND BankName=@Lendername

		END


	END
GO