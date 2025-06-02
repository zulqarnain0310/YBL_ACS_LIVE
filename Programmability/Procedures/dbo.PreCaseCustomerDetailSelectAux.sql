SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[PreCaseCustomerDetailSelectAux]
--DECLARE
	@CustomerID			varchar(30)='170007152', 
	@CustomerName		varchar(80)='',
	@BranchCode			varchar(10)='',
	@BranchName			varchar(50)='',
	@CustomerAcID		varchar(30)='',
	@DefendentName		varchar(80)='',
	@CaseNo				varchar(30)='',
	@UCICID				varchar(30)='',
	@SourceSystem		varchar(30)='',
	----
	@TimeKey			int=25703,
	@UserLoginID		varchar(10)='tf572',
	@Mode				TINYINT=0 ,
	@CustType			VARCHAR(20)='BORROWER',
	@PAN				VARCHAR(12)='',
	@Result				SMALLINT=0 --OUTPUT

AS

DECLARE @LocatationCode VARCHAR(10)='', @Location char(2)='HO', @CustomerEntityID INT=0

IF OBJECT_ID('TEMPDB..#CustomerEntityId')IS NOT NULL
	DROP TABLE #CustomerEntityId

	 CREATE TABLE #CustomerEntityId	
	 (
		CustomerEntityId	INT
		,ID					TINYINT DEFAULT 0
	 )

	IF ISNULL(@CustomerID,'')<>'' 
		BEGIN
				--SELECT 'TRI'
				INSERT  INTO #CustomerEntityId (CustomerEntityId)

				SELECT CustomerEntityID FROM PRO.CustomerCal
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND RefCustomerID=@CustomerID
				
				
				
				IF NOT EXISTS (SELECT 1 FROM #CustomerEntityId WHERE 1=1)
					BEGIN
							SET @Result=-1      /* If customer Id does not exists*/
							--RETURN @Result
					END
		END

	IF ISNULL(@CustomerName,'')<>''
		BEGIN
				INSERT  INTO #CustomerEntityId (CustomerEntityId)
				SELECT CustomerEntityID FROM PRO.CustomerCal
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND CustomerName LIKE '%'+@CustomerName+'%' 

				--IF (SELECT COUNT(CustomerEntityId) FROM #CustomerEntityId)>100
				--	BEGIN
				--			SET @Result=-3  /* If customer DATA IS MORE THAN 100*/
				--			RETURN @Result
				--	END
		
		END
		
	DECLARE
	@CntCust INT=(SELECT COUNT(*)FROM #CustomerEntityId )
		
	IF OBJECT_ID('Tempdb..#CustAcData') IS NOT NULL
			DROP TABLE #CustAcData

		CREATE TABLE #CustAcData
			(
				 CustomerEntityID	INT
				,AuthorisationStatus VARCHAR(20)
			)		

	IF ISNULL(@CustomerAcID,'')<>''
			BEGIN

					INSERT INTO #CustAcData

					SELECT CustomerEntityID FROM PRO.AccountCal	ABD	
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND ABD.CustomerEntityId=CASE WHEN @CustomerEntityID>0 THEN @CustomerEntityID ELSE ABD.CustomerEntityId END
					AND CustomerAcID=@CustomerAcID --AND ISNULL(AuthorisationStatus,'A')='A'		
					GROUP BY CustomerEntityID--,AuthorisationStatus

					

					IF NOT EXISTS (SELECT 1 FROM #CustAcData WHERE 1=1)
						BEGIN
								SET @Result=-2 /* aCCOUNT ID DOES NOT EXISTS*/
								--RETURN @Result
						
						END			

			END
GO