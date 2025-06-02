SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CollateralDetailSearchList 16,'','',1,100

--There is already an object named '#TEMP24' in the database.


--exec CollateralDetailSearchList @OperationFlag=16,@UCIF_ID=N'',@newPage=1,@pageSize=10
-- CollateralDetailSearchList 16,'','',1,100
create PROC [dbo].[CollateralDetailSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 16
													,@UCIF_ID Varchar(50)=''
													,@Collateral Varchar(30)=''
													 ,@newPage SMALLINT =1    
													,@pageSize INT = 100   
 
												--	,@CustomerID Varchar(30)
AS
     
	 BEGIN
	 --Declare @OperationFlag  INT

	 --Set @OperationFlag=1
SET NOCOUNT ON;
Declare @Timekey as Int

DECLARE @PageFrom INT, @PageTo INT   
  
SET @PageFrom = (@pageSize*@newPage)-(@pageSize) +1  
SET @PageTo = @pageSize*@newPage  


Declare @LatestColletralSum Decimal(18,2),@LatestColletral1 Decimal(18,2)
Declare @Count Int,@I Int,@RowNumber Int,@CollateralID Varchar(30)

Declare @LatestColletralCount Int
Declare @CustomerID Varchar(30),@CustomerIDPre Varchar(30)
Declare @CollateralID1 Varchar(30)
Declare @ValuationDate datetime	
Declare @ValuationAmount decimal(16, 2)	
Declare @ValuationExpiryDate datetime
DEclare @ExpiryBusinessRule Varchar(100)
Declare @Count1 INT,@I1 INT,@MaxRowNumber INT,@SecondMaxRowNumber INT

SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')


------------------Added on 03-04-2021 -----------------------------


IF OBJECT_ID('TempDB..#Tag1') IS NOT NULL Drop Table #Tag1


IF OBJECT_ID('TempDB..#temp101') IS NOT NULL Drop Table #temp101

Select 1 as TaggingAlt_Key,A.RefCustomerId as CustomerID,A.CollateralID,D.TotalCollateralValue 
into #Tag1 
from Curdat.AdvSecurityDetail A
Inner Join (			Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						from DimParameter where DimParameterName='DimRatingType'
						and ParameterName not in ('Guarantor')
						And EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
						)B
						ON A.TaggingAlt_Key=B.ParameterAlt_Key
						And A.TaggingAlt_Key=1
Inner Join (
						Select A.RefCustomerId as CustomerID,Sum(C.CurrentValue)TotalCollateralValue 
						from Curdat.AdvSecurityDetail A
						Inner Join Curdat.AdvSecurityValueDetail C ON C.CollateralID=A.CollateralID
						And C.EffectiveFromTimeKey<=@Timekey  and C.EffectiveToTimeKey>=@Timekey
						Where A.EffectiveFromTimeKey<=@Timekey  and A.EffectiveToTimeKey>=@Timekey
						Group By A.RefCustomerId
			)D 
ON D.CustomerID=A.RefCustomerId
Where A.EffectiveFromTimeKey<=@Timekey 
 and A.EffectiveToTimeKey>=@Timekey


IF OBJECT_ID('TempDB..#Tag2') IS NOT NULL
Drop Table #Tag2

Select 2 as TaggingAlt_Key,A.RefSystemAcId as AccountID,A.CollateralID,D.TotalCollateralValue 
into #Tag2 from Curdat.AdvSecurityDetail A
Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  And A.TaggingAlt_Key=2
Inner Join (
Select A.RefSystemAcId as AccountID,Sum(C.CurrentValue)TotalCollateralValue from Curdat.AdvSecurityDetail A
Inner Join Curdat.AdvSecurityValueDetail C ON C.CollateralID=A.CollateralID
And C.EffectiveFromTimeKey<=@Timekey  and C.EffectiveToTimeKey>=@Timekey
Where A.EffectiveFromTimeKey<=@Timekey  and A.EffectiveToTimeKey>=@Timekey
Group By A.RefSystemAcId)D ON D.AccountID=A.RefSystemAcId
Where A.EffectiveFromTimeKey<=@Timekey  and A.EffectiveToTimeKey>=@Timekey
-------------------------------------------------

 IF OBJECT_ID('TempDB..#temp13') IS NOT NULL DROP TABLE  #temp13; 
CREATE TABLE [dbo].[#temp13](
	[RowNumber1] [bigint] NULL,
	[CollateralID1] [varchar](30) NULL,
	[1stValDoc] [varchar](100) NULL,
	[1stValuationDate] [datetime] NULL,
	[1stValuationAmount] [decimal](16, 2) NULL,
	[1stValuationExpiryDate] [datetime] NULL,
	[2ndValDoc] [varchar](100) NULL,
	[2ndValuationDate] [datetime] NULL,
	[2ndValuationAmount] [decimal](16, 2) NULL,
	[2ndValuationExpiryDate] [datetime] NULL
)	
	

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in ( 16,17,20))
BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL DROP TABLE  #temp;
			 IF OBJECT_ID('TempDB..#temp12') IS NOT NULL DROP TABLE  #temp12;
			  IF OBJECT_ID('TempDB..#TEMP1') IS NOT NULL DROP TABLE  #TEMP1;
			 IF OBJECT_ID('TempDB..#temp14') IS NOT NULL DROP TABLE  #temp14;
			 IF OBJECT_ID('TempDB..#temp101') IS NOT NULL DROP TABLE  #temp101;
             IF OBJECT_ID('TempDB..#temp103') IS NOT NULL DROP TABLE  #temp103;   
			 IF OBJECT_ID('TempDB..#temp104') IS NOT NULL DROP TABLE  #temp104;  
			 IF OBJECT_ID('TempDB..#temp105') IS NOT NULL DROP TABLE  #temp105; 
			 IF OBJECT_ID('TempDB..#temp1061') IS NOT NULL DROP TABLE #temp1061;
			  IF OBJECT_ID('TempDB..#temp181') IS NOT NULL DROP TABLE #temp181;
			  IF OBJECT_ID('TempDB..#temp182') IS NOT NULL DROP TABLE #temp182;
			  IF OBJECT_ID('TempDB..#temp186') IS NOT NULL DROP TABLE #temp186;
			  		  
                 SELECT		
							
							A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,a.SegmentName
							,A.CRE
							,a.CREName
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,A.SeniorityofChargeDesc
							,A.SecurityStatus
							,a.SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,a.SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,A.CurSBLCissuedName
							,A.SBLCFCY
							, A.DtexpirySBLC 
							,  A.DtexpiryLIC
							,A.ModeOperation
							,(CASE WHEN ISNULL(A.ModeOperation,'0') IN ('1') then 'ADD' WHEN ISNULL(A.ModeOperation,'0') IN ('2')  then 'Release'  WHEN ISNULL(A.ModeOperation,'0') IN ('3')  then 'Delete' WHEN ISNULL(A.ModeOperation,'0') IN ('4')  then 'MODIFY'  ELSE '' END)ModeOperationDesc
							,A.ExceApproval
							,(CASE WHEN ISNULL(A.ExceApproval,'0') IN ('1') then 'Yes' WHEN ISNULL(A.ExceApproval,'0')  IN ('2')  then 'No' WHEN ISNULL(A.ExceApproval,'0')  IN ('3')  then 'Select' ELSE '' END)ExceApprovalDesc
							,A.CollateralID,A.AuthorisationStatus
							,(CASE WHEN A.AuthorisationStatus in ('A','R') THEN 'Authorized' ELSE 'UnAuthorized' END)AuthorisationStatusName,
							--A.ExpiryBusinessRule,
							--A.ValuationDate,
							--A.CurrentValue as ValueConsidered,
							--A.AuthorisationStatus,
						    A.SecurityEntityID,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							 A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,H.SegmentName
							,A.CRE
							,I.ParameterName as CREName
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,j.ParameterName as SeniorityofChargeDesc
							,A.SecurityStatus
							,K.ParameterName as SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,O.BankName as SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,L.CurrencyName as CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,A.ExceApproval
							,A.CollateralID
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus	
							--,Z.ExpiryBusinessRule
							--,Z.ValuationDate
							--,Z.CurrentValue

							,A.SecurityEntityID							
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy 
							,A.DateApproved 
                            ,A.ModifiedBy
							,A.DateModified
						    ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
					    FROM	 Curdat.AdvSecurityDetail A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@Timekey
						   LEFT JOIN DimSegment H
						  ON A.Segment = H.SegmentAlt_key
						   LEFT JOIN (Select ParameterAlt_Key
									,ParameterName
									,'CREMaster' as Tablename 
									from DimParameter where DimParameterName='DimYesNo'
									and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
						  ON A.CRE = I.ParameterAlt_Key	
						  LEFT JOIN  (	Select ParameterAlt_Key
										,ParameterName
										,'SeniorityOfChargeMaster' as Tablename 
										from DimParameter where DimParameterName='DimSeniorityOfCharge'
										and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
									 )j
							on A.SeniorityofCharge = J.ParameterAlt_Key
							LEFT JOIN  (Select ParameterAlt_Key
							,ParameterName
							,'SecurityStatusMaster' as Tablename 
							from DimParameter where DimParameterName='DimSecuritySt'
							and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	) K
							on	a.SecurityStatus = K.ParameterAlt_Key
							 LEFT JOIN (Select CurrencyAlt_Key,CurrencyName,'CurrencyTable'  as TableName 
										 from DimCurrency
										where EffectiveFromTimeKey<=@TimeKey
										 AND EffectiveToTimeKey >=@TimeKey
										 and CurrencyCode in('INR','USD','GBP','Euro','Yen','Swiss Franc')	 
										 )l
								 on a.cURsblcISSUED   = l.CurrencyName
								left joIN ( Select  BankAlt_Key
									,BankName
									,'BankMaster' as TableName 
									from DimBank A 
									where	 A.EffectiveFromTimeKey<=@TimeKey
									AND A.EffectiveToTimeKey >=@TimeKey)O
									ON A.sblcissuingBank = O.BankAlt_Key
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						  --LEFT JOIN Curdat.AdvSecurityValueDetail Z ON A.CollateralID=Z.CollateralID
						 WHERE A.EffectiveFromTimeKey <= @Timekey
                           AND A.EffectiveToTimeKey >= @Timekey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
					--	   AND  Z.SecurityEntityID IN
					--(Select Max(SecurityEntityID) from Curdat.AdvSecurityValueDetail
					--WHERE EffectiveFromTimeKey <= @Timekey
    --                         AND EffectiveToTimeKey >= @Timekey
					
                     --GROUP BY CollateralID)

            UNION


                     	SELECT A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,H.SegmentName
							,A.CRE
							,I.ParameterName as CREName
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,j.ParameterName as SeniorityofChargeDesc
							,A.SecurityStatus
							,K.ParameterName as SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,O.BankName as SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,L.CurrencyName as CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,A.ExceApproval
							,A.CollateralID
							--,A.AuthorisationStatus
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
							--,Z.ExpiryBusinessRule
							--,Z.ValuationDate
							--,Z.CurrentValue

							,A.SecurityEntityID							
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy 
							,A.DateApproved 
      ,A.ModifiedBy
							,A.DateModified
						    ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
                     FROM	DBO.AdvSecurityDetail_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  LEFT JOIN DimSegment H
						  ON A.Segment = H.SegmentAlt_key
						   LEFT JOIN (Select ParameterAlt_Key
									,ParameterName
									,'CREMaster' as Tablename 
									from DimParameter where DimParameterName='DimYesNo'
									and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
						  ON A.CRE = I.ParameterAlt_Key	
						  LEFT JOIN  (	Select ParameterAlt_Key
										,ParameterName
										,'SeniorityOfChargeMaster' as Tablename 
										from DimParameter where DimParameterName='DimSeniorityOfCharge'
										and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
									 )j
							on A.SeniorityofCharge = J.ParameterAlt_Key
							LEFT JOIN  (Select ParameterAlt_Key
							,ParameterName
							,'SecurityStatusMaster' as Tablename 
							from DimParameter where DimParameterName='DimSecuritySt'
							and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	) K
							on	a.SecurityStatus = K.ParameterAlt_Key
							 LEFT JOIN (Select CurrencyAlt_Key,CurrencyName,'CurrencyTable'  as TableName 
								 from DimCurrency
								where EffectiveFromTimeKey<=@TimeKey
								 AND EffectiveToTimeKey >=@TimeKey
								 and CurrencyCode in('INR','USD','GBP','Euro','Yen','Swiss Franc')	 )l
								 on a.cURsblcISSUED   = l.CurrencyAlt_Key
								left joIN ( Select  BankAlt_Key
									,BankName
									,'BankMaster' as TableName 
									from DimBank A 
									where	 A.EffectiveFromTimeKey<=@TimeKey
									AND A.EffectiveToTimeKey >=@TimeKey)O
									ON A.sblcissuingBank = O.BankAlt_Key
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@Timekey						  
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						  --LEFT JOIN Curdat.AdvSecurityValueDetail Z ON A.CollateralID=Z.CollateralID
						 WHERE A.EffectiveFromTimeKey <= @Timekey
                           AND A.EffectiveToTimeKey >= @Timekey        --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
						FROM DBO.AdvSecurityDetail_Mod
                         WHERE EffectiveFromTimeKey <= @Timekey
                               AND EffectiveToTimeKey >= @Timekey
    AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY CollateralID
                     )

					
					 
                 ) A 
      
                 
   GROUP BY	
							A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,a.SegmentName
							,A.CRE
							,a.CREName
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,A.SeniorityofChargeDesc
							,A.SecurityStatus
							,a.SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,a.SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,A.CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,A.ExceApproval
							,A.CollateralID
							,A.AuthorisationStatus,
							--A.ExpiryBusinessRule,
							--A.ValuationDate,
							--A.CurrentValue,
						   A.SecurityEntityID,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							 A.ModAppByFirst,
							A.ModAppDateFirst;

					--     Drop Table 		 #temp101

					--Select '#temp',CollateralID,* from #temp
					--Where CollateralID='1000037'

                 SELECT *
				INTO #temp101
				 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Collateral' TableName, 
                            *,len(AuthorisationStatus) as AuthorisationStatuslen
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				-- order by DataPointOwner.AuthorisationStatuslen desc 

				--Select '#temp101' ,*  from #temp101  --Sachin
				 ------------------------------------------------------------------------
				  Select Distinct CollateralID into #TEMP12 from #temp101

				  --Select '#TEMP12' ,*  from #TEMP12  --Sachin

				  SELECT * INTO #TEMP14 FROM(		
Select  ROW_NUMBER() OVER(Partition BY CollateralID ORDER BY CollateralID,ValuationExpiryDate) AS RowNumber,ExpiryBusinessRule, ValuationDate,	CurrentValue as ValuationAmount,
ValuationExpiryDate,CollateralID  from [Curdat].[AdvSecurityValueDetail]
Where CollateralID in(Select Distinct CollateralID from #TEMP12 )

Group By CollateralID,ValuationExpiryDate,ValuationDate,CurrentValue,ExpiryBusinessRule
)X
 --Select '#TEMP14' ,*  from #TEMP14  --Sachin
--Select * from #TEMP


Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,CollateralID INTO #TEMP1 from(
Select   Distinct CollateralID  from #TEMP14
)Y
 --Select '#TEMP1' ,*  from #TEMP1  --Sachin
--Select * from #TEMP
--Select * from #TEMP1
SET @CollateralID=''
SET @ValuationDate=NULL
SET @ValuationAmount=0
SET @ValuationExpiryDate=NULL
SET @ExpiryBusinessRule=''
SET @Count1=0
SET @I1=1
SET @MaxRowNumber=0
SET @SecondMaxRowNumber=0

Select @Count1=Count(*) from #TEMP1
Print 'SacStart'
----Print '@I1'
----   Print @I1
--   Print '@@Count1'
--   Print @Count1

WHILE(@I1<=@Count1)
  BEGIN

  Print '@I1'
   Print @I1

       SELECT @CollateralID=CollateralID from #TEMP1 WHERE ROWID=@I1
	    PRINT '@@CollateralID'
	    PRINT @CollateralID
	     
	   SELECT @MaxRowNumber=MAX(RowNumber) from #TEMP14 WHERE CollateralID=@CollateralID
	  
	    
	   IF (@MaxRowNumber)>0
			BEGIN
			  Select @ExpiryBusinessRule=ISNULL(ExpiryBusinessRule,''),@ValuationDate=ValuationDate,
			  @ValuationAmount=ValuationAmount,@ValuationExpiryDate=ValuationExpiryDate
			  from #TEMP14 where RowNumber= @MaxRowNumber AND CollateralID=@CollateralID
			--  PRINT '@ExpiryBusinessRule'
			--    PRINT @ExpiryBusinessRule
			-- PRINT' @ValuationDate'
			--    PRINT @ValuationDate
			--PRINT '@ValuationAmount'
			--    PRINT @ValuationAmount
			--PRINT '@ValuationExpiryDate'
			--    PRINT @ValuationExpiryDate
			END
			INSERT INTO #temp13([RowNumber1],[1stValDoc],[1stValuationDate],[1stValuationAmount],[1stValuationExpiryDate],[CollateralID1]) 
			Values(1,@ExpiryBusinessRule,@ValuationDate,@ValuationAmount,@ValuationExpiryDate,@CollateralID)

			SET @MaxRowNumber=@MaxRowNumber-1
		
		     --SET @CollateralID=''
			SET @ValuationDate=NULL
			SET @ValuationAmount=0
			SET @ValuationExpiryDate=NULL
			SET @ExpiryBusinessRule=''

		IF (@MaxRowNumber)>0
		    BEGIN
			  Select @ExpiryBusinessRule=ISNULL(ExpiryBusinessRule,''),@ValuationDate=ValuationDate,@ValuationAmount=ValuationAmount,@ValuationExpiryDate=ValuationExpiryDate
			  from #TEMP14 where RowNumber= @MaxRowNumber AND CollateralID=@CollateralID
			END
			Update #temp13
			SET [2ndValDoc]=@ExpiryBusinessRule,
			[2ndValuationDate]=@ValuationDate,
			[2ndValuationAmount]=@ValuationAmount,
			[2ndValuationExpiryDate]=@ValuationExpiryDate
			Where CollateralID1=@CollateralID
			--INSERT INTO abc([RowNumber],[2ndValDoc],[2ndValuationDate],[2ndValuationAmount],[2ndValuationExpiryDate])
			--Values(2,@ExpiryBusinessRule,@ValuationDate,@ValuationAmount,@ValuationExpiryDate)

			SET @I1=@I1+1

			 SET @CollateralID1=''
			SET @ValuationDate=NULL
			SET @ValuationAmount=0
			SET @ValuationExpiryDate=NULL
			SET @ExpiryBusinessRule=''

  END
  --Select '#TEMP11',* from #TEMP11
    --Select '##temp13',* from #temp13
	--Select Case When @UCIF_ID<>'' Then @UCIF_ID END  as Sac
	--Drop Table #temp13
	IF (ISNULL(@UCIF_ID,'')<>'' AND ISNULL(@Collateral,'')='')
		BEGIN
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.*,B.* 
		 INTO #temp181 from #temp101 A 
		  Left JOIN #temp13 B
		  ON A.CollateralID =B.CollateralID1
		 WHERE 
		   ISNULL(UCICID,'')=@UCIF_ID
		 
		 Select * from #temp181 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')<>'')
		BEGIN
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.*,B.* 
		 INTO #temp182 from #temp101 A 
		  Left JOIN #temp13 B
		  ON A.CollateralID =B.CollateralID1
		 WHERE 
		   ISNULL(A.CollateralID,'')=@Collateral
		 
		 Select * from #temp182 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='')
		BEGIN
		  Select ROW_NUMBER() OVER( ORDER BY CrModDate desc) RowORD,A.*,B.* INTO #temp186
		  from #temp101 A 
		  Left JOIN #temp13 B
		  ON A.CollateralID =B.CollateralID1
		-- WHERE A.Rownumber BETWEEN @PageFrom AND @PageTo
		--order by  CrModDate desc

		
		  Select * from #temp186 A
		 WHERE A.RowORD BETWEEN @PageFrom AND @PageTo

	

	END
 
				
		


             END;
             ELSE
			 



			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in (16,17))

          BEGIN
			IF OBJECT_ID('TempDB..#temp16') IS NOT NULL DROP TABLE #temp16;   
			IF OBJECT_ID('TempDB..#temp102') IS NOT NULL DROP TABLE #temp102;
			IF OBJECT_ID('TempDB..#temp106') IS NOT NULL DROP TABLE #temp106;
			IF OBJECT_ID('TempDB..#temp107') IS NOT NULL DROP TABLE #temp107;
			IF OBJECT_ID('TempDB..#temp108') IS NOT NULL DROP TABLE #temp108;
			IF OBJECT_ID('TempDB..#temp1091') IS NOT NULL DROP TABLE #temp1091;
			IF OBJECT_ID('TempDB..#TEMP22') IS NOT NULL DROP TABLE #TEMP22;
			IF OBJECT_ID('TempDB..#TEMP248') IS NOT NULL DROP TABLE #TEMP248;
			IF OBJECT_ID('TempDB..#TEMP2') IS NOT NULL DROP TABLE #TEMP2;
			IF OBJECT_ID('TempDB..#temp184') IS NOT NULL DROP TABLE #temp184;
			IF OBJECT_ID('TempDB..#temp183') IS NOT NULL DROP TABLE #temp183;
			IF OBJECT_ID('TempDB..#temp185') IS NOT NULL DROP TABLE #temp185;
			IF OBJECT_ID('TempDB..#TEMP24') IS NOT NULL DROP TABLE #TEMP24;

			PRINT 'Sachin'
			SELECT		
							
							A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,a.SegmentName
							,A.CRE
							,a.CREName
							,A.CollateralSubTypeAlt_Key
							,a.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,A.SeniorityofChargeDesc
							,A.SecurityStatus
							,a.SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,a.SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,A.CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,(CASE WHEN ISNULL(A.ModeOperation,'0') IN ('1') then 'ADD' WHEN ISNULL(A.ModeOperation,'0') IN ('2')  then 'Release'  WHEN ISNULL(A.ModeOperation,'0') IN ('3')  then 'Delete' WHEN ISNULL(A.ModeOperation,'0') IN ('4')  then 'MODIFY'  ELSE '' END)ModeOperationDesc
							,A.ExceApproval
							,(CASE WHEN ISNULL(A.ExceApproval,'0') IN ('1') then 'Yes' WHEN ISNULL(A.ExceApproval,'0')  IN ('2')  then 'No' WHEN ISNULL(A.ExceApproval,'0')  IN ('3')  then 'Select' ELSE '' END)ExceApprovalDesc
							,A.CollateralID,A.AuthorisationStatus
							,'UnAuthorized' AuthorisationStatusName
							--,A.ExpiryBusinessRule
							--,A.ValuationDate
							--,A.CurrentValue as ValueConsidered
						     ,A.SecurityEntityID,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
							A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							 A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp16
 FROM 
         (

			SELECT A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,H.SegmentName
							,A.CRE
							,I.ParameterName as CREName
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,j.ParameterName as SeniorityofChargeDesc
							,A.SecurityStatus
							,K.ParameterName as SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,O.BankName as SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,L.CurrencyName as CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,A.ExceApproval
							,A.CollateralID
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
							--,Z.ExpiryBusinessRule
							--,Z.ValuationDate
							--,Z.CurrentValue
							,A.SecurityEntityID
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy 
							,A.DateApproved 
                            ,A.ModifiedBy
							,A.DateModified
						    ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
                     FROM DBO.AdvSecurityDetail_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						   LEFT JOIN DimSegment H
						  ON A.Segment = H.SegmentAlt_key
						   LEFT JOIN (Select ParameterAlt_Key
									,ParameterName
									,'CREMaster' as Tablename 
									from DimParameter where DimParameterName='DimYesNo'
									and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
						  ON A.CRE = I.ParameterAlt_Key	
						  LEFT JOIN  (	Select ParameterAlt_Key
										,ParameterName
										,'SeniorityOfChargeMaster' as Tablename 
										from DimParameter where DimParameterName='DimSeniorityOfCharge'
										and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
									 )j
							on A.SeniorityofCharge = J.ParameterAlt_Key
							LEFT JOIN  (Select ParameterAlt_Key
							,ParameterName
							,'SecurityStatusMaster' as Tablename 
							from DimParameter where DimParameterName='DimSecuritySt'
							and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	) K
							on	a.SecurityStatus = K.ParameterAlt_Key
							 LEFT JOIN (Select CurrencyAlt_Key,CurrencyName,'CurrencyTable'  as TableName 
								 from DimCurrency
								where EffectiveFromTimeKey<=@TimeKey
								 AND EffectiveToTimeKey >=@TimeKey
								 and CurrencyCode in('INR','USD','GBP','Euro','Yen','Swiss Franc')	 )l
								 on a.cURsblcISSUED   = l.CurrencyAlt_Key
								left joIN ( Select  BankAlt_Key
									,BankName
									,'BankMaster' as TableName 
									from DimBank A 
									where	 A.EffectiveFromTimeKey<=@TimeKey
									AND A.EffectiveToTimeKey >=@TimeKey)O
									ON A.sblcissuingBank = O.BankAlt_Key
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@Timekey						  
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						    --LEFT JOIN Curdat.AdvSecurityValueDetail Z ON A.CollateralID=Z.CollateralID
						 WHERE 
						 A.EffectiveFromTimeKey <= @Timekey
                           AND A.EffectiveToTimeKey >= @Timekey AND       --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                            A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
							FROM DBO.AdvSecurityDetail_Mod
                         WHERE EffectiveFromTimeKey <= @Timekey
                               AND EffectiveToTimeKey >= @Timekey
							 AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CollateralID
                 )
					--  AND  Z.SecurityEntityID IN
					--(Select Max(SecurityEntityID) from Curdat.AdvSecurityValueDetail
					--WHERE EffectiveFromTimeKey <= @Timekey
     --                          AND EffectiveToTimeKey >= @Timekey
					--	GROUP BY CollateralID)
					
                         
                 ) A 
                      

      GROUP BY	
							A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,a.SegmentName
							,A.CRE
							,a.CREName
							,A.CollateralSubTypeAlt_Key
							,a.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,A.SeniorityofChargeDesc
							,A.SecurityStatus
							,a.SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,a.SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,A.CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,A.ExceApproval
							,A.CollateralID

							,A.AuthorisationStatus,
							--A.ExpiryBusinessRule,
							--A.ValuationDate,
							--A.CurrentValue ,
						    A.SecurityEntityID,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                    A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							 A.ModAppByFirst,
							A.ModAppDateFirst;

--Select '#temp16',* from #temp16
                 SELECT *
				 INTO #temp102
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Collateral' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner

          --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@Pag;eNo * @PageSize)

				 
--Select '#temp102',* from #temp102
				 ----------------------------------------------------------------
				  Select Distinct CollateralID into #TEMP22 from #temp102

				  --Select '#TEMP22' ,*  from #TEMP22  --Sachin

				  SELECT * INTO #TEMP24 FROM(		
Select  ROW_NUMBER() OVER(Partition BY CollateralID ORDER BY CollateralID,ValuationExpiryDate) AS RowNumber,ExpiryBusinessRule, ValuationDate,	CurrentValue as ValuationAmount,
ValuationExpiryDate,CollateralID  from DBO.[AdvSecurityValueDetail_MOD]
Where CollateralID in(Select Distinct CollateralID from #TEMP22 )
AND AuthorisationStatus in('NP','MP')
Group By CollateralID,ValuationExpiryDate,ValuationDate,CurrentValue,ExpiryBusinessRule
)X
 --Select '#TEMP14' ,*  from #TEMP14  --Sachin
--Select '#TEMP24' ,*  from #TEMP24



Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,CollateralID INTO #TEMP2 from(
Select   Distinct CollateralID  from #TEMP24
)Y
 --Select '#TEMP1' ,*  from #TEMP1  --Sachin
--Select '#TEMP2' ,*  from #TEMP2
--Select * from #TEMP1
SET @CollateralID=''
SET @ValuationDate=NULL
SET @ValuationAmount=0
SET @ValuationExpiryDate=NULL
SET @ExpiryBusinessRule=''
SET @Count1=0
SET @I1=1
SET @MaxRowNumber=0
SET @SecondMaxRowNumber=0

Select @Count1=Count(*) from #TEMP2
--Print 'SacStart'
----Print '@I1'
----   Print @I1
--   Print '@@Count1'
--   Print @Count1

WHILE(@I1<=@Count1)
  BEGIN

  --Print '@I1'
  -- Print @I1

       SELECT @CollateralID=CollateralID from #TEMP2 WHERE ROWID=@I1
	    --PRINT '@@CollateralID'
	    --PRINT @CollateralID
	     
	   SELECT @MaxRowNumber=MAX(RowNumber) from #TEMP24 WHERE CollateralID=@CollateralID
	  
	    
	   IF (@MaxRowNumber)>0
			BEGIN
			  Select @ExpiryBusinessRule=ISNULL(ExpiryBusinessRule,''),@ValuationDate=ValuationDate,
			  @ValuationAmount=ValuationAmount,@ValuationExpiryDate=ValuationExpiryDate
			  from #TEMP24 where RowNumber= @MaxRowNumber AND CollateralID=@CollateralID
			--  PRINT '@ExpiryBusinessRule'
			--    PRINT @ExpiryBusinessRule
			-- PRINT' @ValuationDate'
			--    PRINT @ValuationDate
			--PRINT '@ValuationAmount'
			--    PRINT @ValuationAmount
			--PRINT '@ValuationExpiryDate'
			--    PRINT @ValuationExpiryDate
			END
			INSERT INTO #temp13([RowNumber1],[1stValDoc],[1stValuationDate],[1stValuationAmount],[1stValuationExpiryDate],[CollateralID1]) 
			Values(1,@ExpiryBusinessRule,@ValuationDate,@ValuationAmount,@ValuationExpiryDate,@CollateralID)

			SET @MaxRowNumber=@MaxRowNumber-1
		
		     --SET @CollateralID=''
			SET @ValuationDate=NULL
			SET @ValuationAmount=0
			SET @ValuationExpiryDate=NULL
			SET @ExpiryBusinessRule=''

		IF (@MaxRowNumber)>0
		    BEGIN
			  Select @ExpiryBusinessRule=ISNULL(ExpiryBusinessRule,''),@ValuationDate=ValuationDate,@ValuationAmount=ValuationAmount,@ValuationExpiryDate=ValuationExpiryDate
			  from #TEMP24 where RowNumber= @MaxRowNumber AND CollateralID=@CollateralID
			END
			Update #temp13
			SET [2ndValDoc]=@ExpiryBusinessRule,
			[2ndValuationDate]=@ValuationDate,
			[2ndValuationAmount]=@ValuationAmount,
			[2ndValuationExpiryDate]=@ValuationExpiryDate
			Where CollateralID1=@CollateralID
			--INSERT INTO abc([RowNumber],[2ndValDoc],[2ndValuationDate],[2ndValuationAmount],[2ndValuationExpiryDate])
			--Values(2,@ExpiryBusinessRule,@ValuationDate,@ValuationAmount,@ValuationExpiryDate)

			SET @I1=@I1+1

			 SET @CollateralID1=''
			SET @ValuationDate=NULL
			SET @ValuationAmount=0
			SET @ValuationExpiryDate=NULL
			SET @ExpiryBusinessRule=''

  END
  --Select '#TEMP11',* from #TEMP11
    --Select '##temp13',* from #temp13
		IF (ISNULL(@UCIF_ID,'')<>'' AND ISNULL(@Collateral,'')='')
		BEGIN
		PRINT 'Sac1'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.*,B.* 
		 INTO #temp184 from #temp102 A 
		  Left JOIN #temp13 B
		  ON A.CollateralID =B.CollateralID1
		 WHERE 
		   ISNULL(UCICID,'')=@UCIF_ID
		 
		 Select * from #temp184 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')<>'')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.*,B.* 
		 INTO #temp183 from #temp102 A 
		  Left JOIN #temp13 B
		  ON A.CollateralID =B.CollateralID1
		 WHERE 
		   ISNULL(A.CollateralID,'')=@Collateral
		 
		 Select * from #temp183 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END
	 --Select '#temp13',* from #temp13
	 --	 Select '#temp102',* from #temp102
	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='')
		BEGIN
		PRINT 'Sac3'
		  Select ROW_NUMBER() OVER( ORDER BY CrModDate desc) RowORD,A.*,B.*  INTO #temp185 from #temp102 A 
		  Left JOIN #temp13 B
		  ON A.CollateralID =B.CollateralID1
		  --order by  CrModDate desc

		  Select * from #temp185 A
		 WHERE A.RowORD BETWEEN @PageFrom AND @PageTo
		

		--Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID1, A.*,B.* from #temp102 A 
		--  Left JOIN #temp13 B
		--  ON A.CollateralID =B.CollateralID1
		-- --WHERE A.Rownumber BETWEEN @PageFrom AND @PageTo
		--order by  CrModDate desc
	END

				


					------------------------------------------------------------------------
     
   END;
  ElSE

  IF(@OperationFlag  in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp120') IS NOT NULL DROP TABLE  #temp120;
             IF OBJECT_ID('TempDB..#temp121') IS NOT NULL DROP TABLE  #temp121;    
             IF OBJECT_ID('TempDB..#temp122') IS NOT NULL DROP TABLE  #temp122;    
				PRINT 'Nitin'
				SELECT		
							
							A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,a.SegmentName
							,A.CRE
							,a.CREName
							,A.CollateralSubTypeAlt_Key
							,a.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,A.SeniorityofChargeDesc
							,A.SecurityStatus
							,a.SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,a.SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,A.CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,(CASE WHEN ISNULL(A.ModeOperation,'0') IN ('1') then 'ADD' WHEN ISNULL(A.ModeOperation,'0') IN ('2')  then 'Release'  WHEN ISNULL(A.ModeOperation,'0') IN ('3')  then 'Delete' WHEN ISNULL(A.ModeOperation,'0') IN ('4')  then 'MODIFY'  ELSE '' END)ModeOperationDesc
							,A.ExceApproval
							,(CASE WHEN ISNULL(A.ExceApproval,'0') IN ('1') then 'Yes' WHEN ISNULL(A.ExceApproval,'0')  IN ('2')  then 'No' WHEN ISNULL(A.ExceApproval,'0')  IN ('3')  then 'Select' ELSE '' END)ExceApprovalDesc
							,A.CollateralID,A.AuthorisationStatus
							,'UnAuthorized' AuthorisationStatusName
						    ,A.SecurityEntityID,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
  A.CreatedBy, 
                 A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							 A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp120
                 FROM 
  (

		SELECT				A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,H.SegmentName
							,A.CRE
							,I.ParameterName as CREName
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,j.ParameterName as SeniorityofChargeDesc
							,A.SecurityStatus
							,K.ParameterName as SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,O.BankName as SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,L.CurrencyName as CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,A.ExceApproval
							,A.CollateralID
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
							,A.SecurityEntityID
							,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy 
							,A.DateApproved 
              ,A.ModifiedBy
							,A.DateModified
						    ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
                     FROM Dbo.AdvSecurityDetail_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  LEFT JOIN DimSegment H
						  ON A.Segment = H.SegmentAlt_key
						   LEFT JOIN (Select ParameterAlt_Key
									,ParameterName
									,'CREMaster' as Tablename 
									from DimParameter where DimParameterName='DimYesNo'
									and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
						  ON A.CRE = I.ParameterAlt_Key	
						  LEFT JOIN  (	Select ParameterAlt_Key
										,ParameterName
										,'SeniorityOfChargeMaster' as Tablename 
										from DimParameter where DimParameterName='DimSeniorityOfCharge'
										and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
									 )j
							on A.SeniorityofCharge = J.ParameterAlt_Key
							LEFT JOIN  (Select ParameterAlt_Key
							,ParameterName
							,'SecurityStatusMaster' as Tablename 
							from DimParameter where DimParameterName='DimSecuritySt'
							and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	) K
							on	a.SecurityStatus = K.ParameterAlt_Key
							 LEFT JOIN (Select CurrencyAlt_Key,CurrencyName,'CurrencyTable'  as TableName 
								 from DimCurrency
								where EffectiveFromTimeKey<=@TimeKey
								 AND EffectiveToTimeKey >=@TimeKey
								 and CurrencyCode in('INR','USD','GBP','Euro','Yen','Swiss Franc')	 )l
								 on a.cURsblcISSUED   = l.CurrencyAlt_Key
								left joIN ( Select  BankAlt_Key
									,BankName
									,'BankMaster' as TableName 
									from DimBank A 
									where	 A.EffectiveFromTimeKey<=@TimeKey
									AND A.EffectiveToTimeKey >=@TimeKey)O
									ON A.sblcissuingBank = O.BankAlt_Key
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@Timekey						  
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						 WHERE 
						 A.EffectiveFromTimeKey <= @Timekey
                           AND A.EffectiveToTimeKey >= @Timekey  AND       --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                            A.EntityKey IN
						(
							SELECT MAX(EntityKey)
							FROM DBO.AdvSecurityDetail_Mod
							WHERE EffectiveFromTimeKey <= @Timekey
                            AND EffectiveToTimeKey >= @Timekey
							AND ISNULL(AuthorisationStatus, 'A') IN('1A')
							GROUP BY CollateralID
                     )
                 ) A 
                      
					  
      GROUP BY	
							A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.LiabID
							,A.AssetID
							,A.Segment
							,a.SegmentName
							,A.CRE
							,a.CREName
							,A.CollateralSubTypeAlt_Key
							,a.CollateralSubTypeDescription
							,A.SeniorityofCharge
							,A.SeniorityofChargeDesc
							,A.SecurityStatus
							,a.SecurityStatusDesc
							,A.FDNo
							,A.ISINNo
							,A.FolioNo
							,A.QtyShares_MutualFunds_Bonds
							,A.Line_No
							,A.CrossCollateral_LiabID
							,A.NameSecuPvd
							,A.PropertyAdd
							,A.PIN
							,A.DtStockAudit
							,A.SBLCIssuingBank
							,a.SBLCIssuingBankName
							,A.SBLCNumber
							,A.CurSBLCissued
							,A.CurSBLCissuedName
							,A.SBLCFCY
							,A.DtexpirySBLC
							,A.DtexpiryLIC
							,A.ModeOperation
							,A.ExceApproval
							,A.CollateralID
							,A.AuthorisationStatus,
							A.SecurityEntityID,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
							A.DateApproved, 
							 A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							 A.ModAppByFirst,
							A.ModAppDateFirst;

							
                 SELECT *
				 INTO #tmp121
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Collateral' TableName, 
                *
                     FROM
                     (
                         SELECT *
                         FROM #temp120 A
       --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
    --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner

			
			Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,CustomerID) ) RecentRownumber,* INTO #temp122 from #tmp121


				Select * from #temp122	
              WHERE RecentRownumber BETWEEN @PageFrom AND @PageTo
				 order by  DateCreated desc
				
             END;


   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


  
  
    END;


GO