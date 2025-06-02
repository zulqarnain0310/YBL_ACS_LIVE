SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 07-01-2022
MODIFY DATE : 07-01-2022
DESCRIPTION : INSERT DATA NF DETAILS TABLE
--EXEC [Pro].[AdvFacNFDetail_INSERT_DATA]
============================================*/

CREATE PROCEDURE [pro].[AdvFacNFDetail_INSERT_DATA]
AS
BEGIN
   DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')


   DELETE  FROM  CURDAT.ADVFACNFDETAIL WHERE EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY

   
IF OBJECT_ID ('TEMPDB..#ADVFACNFDETAIL') IS NOT NULL
DROP TABLE #ADVFACNFDETAIL


CREATE TABLE #ADVFACNFDETAIL (
	EntityKey [INT] IDENTITY(1,1) NOT NULL,
	AccountEntityId [INT] NOT NULL,
	RefCustomerid [VARCHAR](30) NOT NULL,
	RefSystemAcId [VARCHAR](30) NOT NULL,
	LCBGNo [VARCHAR](100) NOT NULL, 
	Balance DECIMAL (18,2),
	MarginAccNo [VARCHAR](16) NULL,
	EffectiveFromTimeKey [INT] NULL,
	EffectiveToTimeKey [INT] NULL,
	
	)


	INSERT INTO	#ADVFACNFDETAIL
			(
					AccountEntityId,
					RefCustomerid,
					RefSystemAcId,
					LCBGNo,
					Balance,
					MarginAccNo,
					EffectiveFromTimeKey,
					EffectiveToTimeKey
		    )

		
	 SELECT 
				     B.AccountEntityId
					,A.SourceSystemCustomerID RefCustomerid
					,A.accountid RefSystemAcId
					,A.ContractRefNo LCBGNo
					,A.TotalOutstandingAmount as balance
					,A.FacilityCodeLineCode MarginAccNo
					,@TIMEKEY as EffectiveFromTimeKey
					,@TIMEKEY as EffectiveToTimeKey
					
			from YBL_ACS_MIS.[dbo].[AccountData_NF]    A
			INNER JOIN PRO.AccountMaster B ON B.CustomerAcid=A.accountid
			AND B.EffectiveFromTimekey<=@TIMEKEY AND B.EffectiveToTimekey>=@TIMEKEY
			
						
----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
----INSERT DATA INTO CURDAT.ADVFACNFDETAIL TABLE
----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-


MERGE CURDAT.ADVFACNFDETAIL AS O
USING #ADvFacNFDetail AS T
ON O.LCBGNo=T.LCBGNo  
AND O.AccountEntityId=T.AccountEntityId
AND O.EffectiveFromTimeKey<=@TimeKey  AND O.EffectiveToTimeKey>=@TimeKey


 WHEN MATCHED AND 
								(  

										          ISNULL(O.AccountEntityID,0) <> ISNULL(T.AccountEntityID,0)
											   OR ISNULL(O.RefSystemAcid,'') <> ISNULL(T.RefSystemAcid,'')
											   OR ISNULL(O.LCBGNo,'') <> ISNULL(T.LCBGNo,'')
											   OR ISNULL(O.MarginAccNo,'') <> ISNULL(T.MarginAccNo,'')
											   OR ISNULL(O.Balance,0) <> ISNULL(T.Balance,0)
											  											   )

Then
UPDATE SET 
 O.EFFECTIVETOTimekey=@TIMEKEY-1,
 O.DateModified=CONVERT(DATE,GETDATE());

UPDATE AA
SET 
 EffectiveToTimeKey = @TIMEKEY-1,
 DateModified=CONVERT(date,GETDATE(),103),
 ModifiedBy='SSISUSER' 

FROM CURDAT.ADVFACNFDETAIL AA
WHERE AA.EffectiveFromTimeKey<=@TimeKey  AND AA.EffectiveToTimeKey>=@TimeKey
AND NOT EXISTS (SELECT 1 FROM #ADvFacNFDetail BB
				WHERE AA.AccountEntityId=BB.AccountEntityId
				AND AA.LCBGNo=BB.LCBGNo
				AND BB.EffectiveFromTimeKey<=@TimeKey  AND BB.EffectiveToTimeKey>=@TimeKey
			   )

			   
Merge CURDAT.ADVFACNFDETAIL BP
USING #ADvFacNFDetail T_BP
ON BP.LCBGNo=T_BP.LCBGNo
AND BP.AccountEntityId=T_BP.AccountEntityId
AND BP.EffectiveFromTimeKey<=@TimeKey  AND BP.EffectiveToTimeKey>=@TimeKey

WHEN NOT MATCHED
THEN
INSERT
(                   AccountEntityId,
					RefCustomerid,
					RefSystemAcId,
					LCBGNo,
					Balance,
					MarginAccNo,
					EffectiveFromTimeKey,
					EffectiveToTimeKey
												
			)
Values
( 
					T_BP.AccountEntityId,
					T_BP.RefCustomerid,
					T_BP.RefSystemAcId,
					T_BP.LCBGNo,
					T_BP.Balance,
					T_BP.MarginAccNo,
					T_BP.EffectiveFromTimeKey,
					T_BP.EffectiveToTimeKey
					);
		

END



GO