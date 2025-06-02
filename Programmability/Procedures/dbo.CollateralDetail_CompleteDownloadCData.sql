SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--QtyShares_MutualFunds_Bonds
--0


CREATE PROCEDURE [dbo].[CollateralDetail_CompleteDownloadCData]

	
	--,@Page SMALLINT =1     
 --   ,@perPage INT = 30000   
AS

----DECLARE @Timekey INT=49999
----	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
----	,@ExcelUploadId INT=4
----	,@UploadType VARCHAR(50)='Interest reversal'

BEGIN
		SET NOCOUNT ON;
		DEclare @Timekey INT

		Set @Timekey=(
			select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C'
			 )

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

		 IF OBJECT_ID('TempDB..#TEMP11') IS NOT NULL DROP TABLE  #TEMP11;
			 IF OBJECT_ID('TempDB..#TEMP12') IS NOT NULL DROP TABLE  #TEMP12;
             IF OBJECT_ID('TempDB..#TEMP') IS NOT NULL DROP TABLE  #TEMP;   
			 IF OBJECT_ID('TempDB..#TEMP1') IS NOT NULL DROP TABLE  #TEMP1;  
			 IF OBJECT_ID('TempDB..#temp13') IS NOT NULL DROP TABLE  #temp13; 
			 IF OBJECT_ID('TempDB..#temp1061') IS NOT NULL DROP TABLE #temp1061;
	  --IF OBJECT_ID('#temp13') IS NOT NULL  
	  --BEGIN  
	  -- DROP TABLE #temp13  
	   
	  --END

		CREATE TABLE [dbo].[#temp13](
	[RowNumber] [bigint] NULL,
	[CollateralID] [varchar](30) NULL,
	[1stValDoc] [varchar](100) NULL,
	[1stValuationDate] [date] NULL,
	[1stValuationAmount] [decimal](16, 2) NULL,
	[1stValuationExpiryDate] [date] NULL,
	[2ndValDoc] [varchar](100) NULL,
	[2ndValuationDate] [date] NULL,
	[2ndValuationAmount] [decimal](16, 2) NULL,
	[FinalAmountConsidered] [decimal](16, 2) NULL,
	[2ndValuationExpiryDate] [date] NULL
	
	
) 

--DROP TABLE IF EXISTS #TEMP11

--DROP TABLE if Exists #TEMP12



BEGIN
		
		--DROP TABLE IF EXISTS #TEMP11
		Select CollateralID,Rownumber,LiabID,UCICID,CustomerName,AssetID,Segment,CRE,CollateralSubTypeDescription,
		NameSecuPvd,SeniorityofCharge,SecurityStatus,FDNo,ISINNo
		,CAse when QtyShares_MutualFunds_Bonds='0' then '' else QtyShares_MutualFunds_Bonds END QtyShares_MutualFunds_Bonds ,Line_No,CrossCollateral_LiabID,
		PropertyAdd,PIN,DtStockAudit,SBLCIssuingBank,SBLCNumber,CurSBLCissued,SBLCFCY,DtexpirySBLC,DtexpiryLIC,ModeOperation,ExceApproval 
		,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy,DateApproved
		INTO #TEMP11	FROM(
		SELECT  CollateralID,
		ROW_NUMBER() OVER(PARTITION BY A.CollateralID  ORDER BY  A.CollateralID) as Rownumber,
		
		A.LiabID,
		A.UCICID,
		CustomerName,
		A.AssetID,
		C.SegmentName as Segment,
		H.ParameterName as CRE,
		B.CollateralSubTypeDescription,
		NameSecuPvd,
		I.ParameterName as SeniorityofCharge,
		K.ParameterName as SecurityStatus,
		A.FDNo,
		ISINNo,
		A.QtyShares_MutualFunds_Bonds,
		A.Line_No,
		A.CrossCollateral_LiabID,
		A.PropertyAdd,
		A.PIN,
		CONVERT(Varchar(10),A.DtStockAudit,103) DtStockAudit,
		O.BankName as SBLCIssuingBank,
		A.SBLCNumber,
		Z.CurrencyName CurSBLCissued,
		A.SBLCFCY,
		CONVERT(Varchar(10),A.DtexpirySBLC,103) DtexpirySBLC,
		CONVERT(Varchar(10),A.DtexpiryLIC,103) DtexpiryLIC,
		L.ParameterName as ModeOperation,
		M.ParameterName as ExceApproval,
		A.CreatedBy,
		CONVERT(Varchar(20),A.DateCreated,103)+ '  '+Convert(Varchar(10),Convert(time,A.DateCreated)) DateCreated,
		A.ModifiedBy,
		CONVERT(Varchar(10),A.DateModified,103)+ '  '+Convert(Varchar(10),Convert(time,A.DateCreated)) DateModified,
		A.ApprovedBy,
	     CONVERT(Varchar(20),A.DateApproved,103)+ '  '+Convert(Varchar(10),Convert(time,A.DateApproved)) DateApproved
		
		FROM Curdat.AdvSecurityDetail A
		Left JOIN DimCollateralSubType B ON A.CollateralSubTypeAlt_Key=B.CollateralSubTypeAltKey
		LEFT JOIN DimSegment  C ON A.Segment=C.SegmentAlt_Key
		LEFT JOIN DimCurrency  Z ON A.CurSBLCissued=Z.CurrencyAlt_Key
		LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'CREMaster' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						ON H.ParameterAlt_Key=A.CRE
		LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'SeniorityOfChargeMaster' as Tablename 
						from DimParameter where DimParameterName='DimSeniorityOfCharge'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
						ON I.ParameterAlt_Key=A.SeniorityofCharge
		LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'SecurityStatusMaster' as Tablename 
						from DimParameter where DimParameterName='DimSecuritySt'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)K
						ON K.ParameterAlt_Key=A.SecurityStatus
		LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimModOperation'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=A.ModeOperation
		LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ExceptionalApprovalMaster' as Tablename 
						from DimParameter where DimParameterName='DimExceptionalAppr'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)M
						ON M.ParameterAlt_Key=A.ExceApproval
      		left joIN ( Select  BankAlt_Key,BankName
						from DimBank A 	 where	 A.EffectiveFromTimeKey<=@TimeKey		
						AND A.EffectiveToTimeKey >=@TimeKey)O		
						ON A.SBLCIssuingBank = O.BankAlt_Key	
		WHERE
		 A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
		 --AND CollateralID IN('1001781','1001814')

)  X Where X.Rownumber=1
		 Select Distinct CollateralID into #TEMP12 from #TEMP11

		 --Select '#TEMP11',* from #TEMP11

SELECT * INTO #TEMP FROM(		
Select  ROW_NUMBER() OVER(Partition BY CollateralID ORDER BY CollateralID,ValuationExpiryDate) 
AS RowNumber,ExpiryBusinessRule, ValuationDate,	CurrentValue as ValuationAmount,
ValuationExpiryDate,CollateralID  from [Curdat].[AdvSecurityValueDetail]
Where  CollateralID  in (Select Distinct CollateralID from #TEMP12 )
--CollateralID IN('1001781','1001814')

--in('1001781')
AND ISNULL(AuthorisationStatus,'A')='A'
Group By CollateralID,ValuationExpiryDate,ValuationDate,CurrentValue,ExpiryBusinessRule
)X

--Select '#TEMP',* from #TEMP

Declare @CollateralID Varchar(30)
Declare @ValuationDate datetime	
Declare @ValuationAmount decimal(16, 2)	
Declare @FinalAmountConsidered decimal(16, 2)	
Declare @ValuationExpiryDate datetime
DEclare @ExpiryBusinessRule Varchar(100)
Declare @Count INT,@I INT,@MaxRowNumber INT,@SecondMaxRowNumber INT

Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,CollateralID INTO #TEMP1 from(
Select   Distinct CollateralID  from #TEMP
)Y

--Select '#TEMP',* from #TEMP

--Select '#TEMP1',* from #TEMP1
SET @CollateralID=''
SET @ValuationDate=NULL
SET @ValuationAmount=0
SET @ValuationExpiryDate=NULL
SET @ExpiryBusinessRule=''
SET @Count=0
SET @I=1
SET @MaxRowNumber=0
SET @SecondMaxRowNumber=0

Select @Count=Count(*) from #TEMP1

WHILE(@I<=@Count)
  BEGIN
       SELECT @CollateralID=CollateralID from #TEMP1 WHERE ROWID=@I
	   SELECT @MaxRowNumber=MAX(RowNumber) from #TEMP WHERE CollateralID=@CollateralID

	   IF (@MaxRowNumber)>0
			BEGIN
			  Select @ExpiryBusinessRule=ISNULL(ExpiryBusinessRule,''),@ValuationDate=ValuationDate,@ValuationAmount=ValuationAmount,@ValuationExpiryDate=ValuationExpiryDate
			  from #TEMP where RowNumber= @MaxRowNumber AND CollateralID=@CollateralID
			END
			PRINT '@MaxRowNumber'
			PRINT @MaxRowNumber
			if @MaxRowNumber=1
			  BEGIN 
			  --PRINT 'Sachin'
			  --PRINT '@ValuationAmount'
			  -- PRINT @ValuationAmount

			     INSERT INTO #temp13([RowNumber],[1stValDoc],[1stValuationDate],[1stValuationAmount],[1stValuationExpiryDate],[CollateralID]) 
			       Values(1,@ExpiryBusinessRule,Convert(date,@ValuationDate),@ValuationAmount,Convert(date,@ValuationExpiryDate),@CollateralID)
				   --Select '#temp13',* from  #temp13]
				   --SET @MaxRowNumber=@MaxRowNumber-1
				   PRINT '@MaxRowNumber1'
			PRINT @MaxRowNumber
			  END
        if @MaxRowNumber>1
        BEGIN
					INSERT INTO #temp13([RowNumber],[2ndValDoc],[2ndValuationDate],[2ndValuationAmount],[2ndValuationExpiryDate],[CollateralID]) 
					Values(1,@ExpiryBusinessRule,Convert(date,@ValuationDate),@ValuationAmount,Convert(date,@ValuationExpiryDate),@CollateralID)
			END
			SET @MaxRowNumber=@MaxRowNumber-1
			
		    SET @FinalAmountConsidered=@ValuationAmount
		     --SET @CollateralID=''
			SET @ValuationDate=NULL
			SET @ValuationAmount=0
			SET @ValuationExpiryDate=NULL
			SET @ExpiryBusinessRule=''

			Update #temp13
			SET FinalAmountConsidered=@FinalAmountConsidered
			Where CollateralID=@CollateralID
			

		IF (@MaxRowNumber>0)
		
		    BEGIN
			  Select @ExpiryBusinessRule=ISNULL(ExpiryBusinessRule,''),@ValuationDate=ValuationDate,@ValuationAmount=ValuationAmount,@ValuationExpiryDate=ValuationExpiryDate
			  from #TEMP where RowNumber= @MaxRowNumber AND CollateralID=@CollateralID
			END
			IF @FinalAmountConsidered>@ValuationAmount AND @ValuationDate<>0
			   BEGIN
					SET @FinalAmountConsidered=@ValuationAmount
			 END
			--   PRINT '@MaxRowNumberUpdate'
			--PRINT @MaxRowNumber
			print 'sac'
 --Select '#temp13',* from  #temp13
               IF (@MaxRowNumber>0)
			       BEGIN
						Update #temp13
						SET [1stValDoc]=@ExpiryBusinessRule,
						[1stValuationDate]=Convert(date,@ValuationDate),
						[1stValuationAmount]=@ValuationAmount,
						[1stValuationExpiryDate]=Convert(date,@ValuationExpiryDate),
						FinalAmountConsidered=@FinalAmountConsidered
						Where CollateralID=@CollateralID
			END
			--INSERT INTO abc([RowNumber],[2ndValDoc],[2ndValuationDate],[2ndValuationAmount],[2ndValuationExpiryDate])
			--Values(2,@ExpiryBusinessRule,@ValuationDate,@ValuationAmount,@ValuationExpiryDate)
			 --Select '#temp13',* from  #temp13
			  
			SET @I=@I+1

			 SET @CollateralID=''
			SET @ValuationDate=NULL
			SET @ValuationAmount=0
			SET @ValuationExpiryDate=NULL
			SET @ExpiryBusinessRule=''
        
  END
  --Select '#TEMP11',* from #TEMP11
    --Select '##temp13',* from #temp13

  Select 	A.CollateralID,A.LiabID,A.UCICID,A.CustomerName,A.AssetID,A.Segment,A.CRE,A.CollateralSubTypeDescription,
		A.NameSecuPvd,A.SeniorityofCharge,A.SecurityStatus,A.FDNo,A.ISINNo,
		CAse when QtyShares_MutualFunds_Bonds=0 then NULL else QtyShares_MutualFunds_Bonds END QtyShares_MutualFunds_Bonds  ,Line_No,
		A.CrossCollateral_LiabID,
		A.PropertyAdd,CAse when A.PIN=0 then NULL else A.PIN END PIN,A.DtStockAudit,
		Case WHen A.SBLCIssuingBank='DATA / VALUE NOT PROVIDED' Then NULL ELSE A.SBLCIssuingBank END SBLCIssuingBank ,A.SBLCNumber,A.CurSBLCissued,
		CAse when A.SBLCFCY=0 then NULL else A.SBLCFCY END SBLCFCY,A.DtexpirySBLC,
		A.DtexpiryLIC,A.ModeOperation,A.ExceApproval 
		,A.CreatedBy as MakerID,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy as CheckerID
,A.DateApproved,B.[1stValDoc],
	CONVERT(Varchar(10),B.[1stValuationDate],103) [1stValuationDate],
	B.[1stValuationAmount],
	CONVERT(Varchar(10),B.[1stValuationExpiryDate],103) [1stValuationExpiryDate],
	B.[2ndValDoc],
	CONVERT(Varchar(10),B.[2ndValuationDate],103) [2ndValuationDate],
	Case when B.[2ndValuationAmount]=0 Then NULL else B.[2ndValuationAmount] END [2ndValuationAmount],
	CONVERT(Varchar(10),B.[2ndValuationExpiryDate],103) [2ndValuationExpiryDate],
	B.FinalAmountConsidered from #TEMP11 A 
  Left JOIN #temp13 B
  ON A.CollateralID =B.CollateralID

  END

  
END
GO