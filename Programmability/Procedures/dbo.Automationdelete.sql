SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[Automationdelete]
		
		@CustomerID VARCHAR(12)='',
	
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

						UPDATE RP_Portfolio_Details SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									from RP_Portfolio_Details 
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerID=@CustomerID
									

									UPDATE RP_Lender_Details SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									from RP_Lender_Details 
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerID=@CustomerID
									

								 

		END


END




--EXEC Automationdelete @PAN_NO='BCDEF9876A'
GO