SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 13-11-2018
MODIFY DATE : 13-11-2018
DESCRIPTION : INSERT DATA BILL DETAILS TABLE
--EXEC [Pro].[AdvFacBillDetail_INSERT_DATA]
============================================*/

Create PROCEDURE [pro].[AdvFacBillDetail_INSERT_DATA]
AS
BEGIN
   DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')


   DELETE  FROM  CURDAT.ADVFACBILLDETAIL WHERE EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY

   
--IF OBJECT_ID ('TEMPDB..#ADVFACBILLDETAIL') IS NOT NULL
--DROP TABLE #ADVFACBILLDETAIL


--CREATE TABLE #ADVFACBILLDETAIL (
--	[Ac_Key] [INT] IDENTITY(1,1) NOT NULL,
--	AccountEntityId [INT] NOT NULL,
--	RefSystemAcid [VARCHAR](30) NOT NULL,
--	EffectiveFromTimeKey [INT] NULL,
--	EffectiveToTimeKey [INT] NULL,
--	BillNo [VARCHAR](100) NOT NULL, 
--	BillRefNo [VARCHAR](100) NOT NULL, 
--	BillAmt DECIMAL (18,2),
--	OverDueInterest DECIMAL (18,2), 
--	OverDuePenalInterest DECIMAL (18,2),
--	BillDueDt [DATE] NULL,
--	AdvAmount DECIMAL (18,2),
--	Balance DECIMAL (18,2),	
--	BillLimit DECIMAL (18,2)
--  LbID [INT]
--	)


--	INSERT INTO	#ADVFACBILLDETAIL
--			(
--					AccountEntityId,
--					RefSystemAcid,
--					EffectiveFromTimeKey,
--					EffectiveToTimeKey,
--					BillNo,
--					BillRefNo,
--					BillAmt,
--					OverDueInterest,
--					OverDuePenalInterest,
--					BillDueDt,
--					AdvAmount,
--					Balance,
--					BillLimit
--					LbID
--		    )

		
--	 SELECT 
--				F.AccountEntityID,
--				A.BORROWERID,
--				@TIMEKEY,
--				@TIMEKEY,
--				B.caserefno AS BillNo,
--				C.WHRNUMBER AS BillRefNo ,
--				ISNULL(TotalLoanOutstanding,0) AS BillAmt,
--				ISNULL(Interestos,0) AS Interestos ,
--				ISNULL(PENALINTERESTOS,0) AS PENALINTERESTOS,
--				LOANMATURITYDATE
--				,ISNULL(TotalLoanOutstanding,0) AS AdvAmount
--				,ISNULL(TotalLoanOutstanding,0) AS Balance
--				,ISNULL(D.FINALLIMITAVAILABLEASPERMARGIN,0) AS BillLimit


			--from YBL_ACS_MIS.[DBO].[ODS_ECBF_BORROWERMST]  A

			--INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBMST B ON A.borrowerID=B.borrowerID
			--INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONREF C ON B.lbid=C.lbid
			--INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONMST D ON D.WHRNUMBER=C.WHRNUMBER
			--INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBLOANPROCESSREF E ON E.whrinwardid=D.whrinwardid

			--INNER JOIN PRO.AccountMaster F ON F.CustomerAcid=A.borrowerID
			--				AND F.EffectiveFromTimekey<=@TIMEKEY AND F.EffectiveToTimekey>=@TIMEKEY
				
--			from YBL_ACS_MIS.[DBO].[ODS_ECBF_BORROWERMST]  A

--			INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBMST B ON A.borrowerID=B.borrowerID
--			INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONREF C ON B.lbid=C.lbid
--			INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONMST D ON D.WHRNUMBER=C.WHRNUMBER
--			INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBLOANPROCESSREF E ON E.whrinwardid=D.whrinwardid

--			INNER JOIN PRO.AccountMaster F ON F.CustomerAcid=A.borrowerID		AND F.EffectiveFromTimekey<=@TIMEKEY AND F.EffectiveToTimekey>=@TIMEKEY

						
----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
----INSERT DATA INTO CURDAT.ADVFACBILLDETAIL TABLE
----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-


--MERGE CURDAT.ADVFACBILLDETAIL AS O
--USING #ADvFacBillDetail AS T
--ON O.BillNO=T.BillNO  
--AND O.AccountEntityId=T.AccountEntityId
--AND O.EffectiveFromTimeKey<=@TimeKey  AND O.EffectiveToTimeKey>=@TimeKey


-- WHEN MATCHED AND 
--								(  

--										          ISNULL(O.AccountEntityID,0) <> ISNULL(T.AccountEntityID,0)
--											   OR ISNULL(O.RefSystemAcid,'') <> ISNULL(T.RefSystemAcid,'')
--											   OR ISNULL(O.BillNo,'') <> ISNULL(T.BillNo,'')
--											   OR ISNULL(O.BillRefNo,'') <> ISNULL(T.BillRefNo,'')
--											   OR ISNULL(O.BillAmt,0) <> ISNULL(T.BillAmt,0) 
--											   OR ISNULL(O.OverDueInterest,0) <> ISNULL(T.OverDueInterest,0)
--											   OR ISNULL(O.OverDuePenalInterest,0) <> ISNULL(T.OverDuePenalInterest,0)
--											   OR ISNULL(O.BillDueDt,'1900-01-01') <> ISNULL(T.BillDueDt,'1900-01-01')
--											   OR ISNULL(O.AdvAmount,0) <> ISNULL(T.AdvAmount,0)
--											   OR ISNULL(O.Balance,0) <> ISNULL(T.Balance,0)
--											   OR ISNULL(O.BillLimit,0) <> ISNULL(T.BillLimit,0)
--											   OR ISNULL(O.LbID,0) <> ISNULL(T.LbID,0)
--											   )

--Then
--UPDATE SET 
-- O.EFFECTIVETOTimekey=@TIMEKEY-1,
-- O.DateModified=CONVERT(DATE,GETDATE());

--UPDATE AA
--SET 
-- EffectiveToTimeKey = @TIMEKEY-1,
-- DateModified=CONVERT(date,GETDATE(),103),
-- ModifiedBy='SSISUSER' 

--FROM CURDAT.ADVFACBILLDETAIL AA
--WHERE AA.EffectiveFromTimeKey<=@TimeKey  AND AA.EffectiveToTimeKey>=@TimeKey
--AND NOT EXISTS (SELECT 1 FROM #ADvFacBillDetail BB
--				WHERE AA.AccountEntityId=BB.AccountEntityId
--				AND AA.BillRefNo=BB.BillRefNo
--				AND BB.EffectiveFromTimeKey<=@TimeKey  AND BB.EffectiveToTimeKey>=@TimeKey
--			   )

			   
--Merge CURDAT.ADVFACBILLDETAIL BP
--USING #ADvFacBillDetail T_BP
--ON BP.BillRefNo=T_BP.BillRefNo
--AND BP.AccountEntityId=T_BP.AccountEntityId
--AND BP.EffectiveFromTimeKey<=@TimeKey  AND BP.EffectiveToTimeKey>=@TimeKey

--WHEN NOT MATCHED
--THEN
--INSERT
--(                                             AccountEntityId,
--												RefSystemAcid,
--												EffectiveFromTimeKey,
--												EffectiveToTimeKey,
--												BillNo,
--												BillRefNo,
--												BillAmt,
--												OverDueInterest,
--												OverDuePenalInterest,
--												BillDueDt,
--												AdvAmount,
--												Balance,
--												BillLimit
--												LbID
												
--			)
--Values
--( 
--												T_BP.AccountEntityId,
--												T_BP.RefSystemAcid,
--												T_BP.EffectiveFromTimeKey,
--												T_BP.EffectiveToTimeKey,
--												T_BP.BillNo,
--												T_BP.BillRefNo,
--												T_BP.BillAmt,
--												T_BP.OverDueInterest,
--												T_BP.OverDuePenalInterest,
--												T_BP.BillDueDt,
--												T_BP.AdvAmount,
--												T_BP.Balance,
--												T_BP.BillLimit
--												T_BP.LbID);



INSERT INTO CURDAT.ADVFACBILLDETAIL
(
AccountEntityId,
RefSystemAcid,
EffectiveFromTimeKey,
EffectiveToTimeKey,
BillNo,
BillRefNo,
BillAmt,
OverDueInterest,
OverDuePenalInterest,
BillDueDt,
AdvAmount,
Balance,
BillLimit
,LbID
)

SELECT 
F.AccountEntityID,
--A.BORROWERID AS RefSystemAcid,
A.CustomerAcid AS RefSystemAcid,
@TIMEKEY,
@TIMEKEY,
B.caserefno AS BillNo ,
C.WHRNUMBER AS BillRefNo ,
ISNULL(TotalLoanOutstanding,0) AS BillAmt,
--ISNULL(Interestos,0) AS Interestos ,
sum(ISNULL(m.INTERESTBALANCE,0)) + sum(ISNULL(m.INTERSTONINTBALANCE,0)) AS Interestos ,
--ISNULL(PENALINTERESTOS,0) AS PENALINTERESTOS,
sum(ISNULL(m.PENALINTERESTBALANCE,0)) AS PENALINTERESTOS,
LOANMATURITYDATE AS BillDueDt
,ISNULL(TotalLoanOutstanding,0) AS AdvAmount
--,(ISNULL(TotalLoanOutstanding,0) +ISNULL(Interestos,0) ) AS Balance  --Added ISNULL(Interestos,0) by madhur on 13-03-2019

,(ISNULL(TotalLoanOutstanding,0) +sum(ISNULL(m.INTERESTBALANCE,0)) + sum(ISNULL(m.INTERSTONINTBALANCE,0)) ) AS Balance 
,ISNULL(D.FINALLIMITAVAILABLEASPERMARGIN,0) AS BillLimit 
,B.lbid

--FROM YBL_ACS_MIS.[DBO].[ODS_ECBF_BORROWERMST] A 
--INNER JOIN YBL_ACS_MIS.[DBO].[ODS_ECBF_LBMST] B ON A.BORROWERID=B.BORROWERID
--INNER JOIN PRO.AccountMaster C ON C.CustomerAcid=A.borrowerID
--AND C.EffectiveFromTimekey<=@TIMEKEY AND C.EffectiveToTimekey>=@TIMEKEY
--INNER JOIN YBL_ACS_MIS.[DBO].[ODS_ECBF_LBWHRVALUATIONMST] D ON D.WHRNUMBER=B.WHRNUMBER
--INNER JOIN YBL_ACS_MIS.[DBO].[ODS_ECBF_LBLOANPROCESSREF] E ON E.whrinwardid=D.whrinwardid

from YBL_ACS_MIS.[DBO].[ODS_ECBF_BORROWERMST]  A

INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBMST B ON A.borrowerID=B.borrowerID
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONREF C ON B.lbid=C.lbid
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONMST D ON D.WHRNUMBER=C.WHRNUMBER 
and d.whrcloseflag<>1  ---Added by Madhur
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBLOANPROCESSREF E ON E.whrinwardid=D.whrinwardid
Inner join YBL_ACS_MIS.[dbo].[ODS_ECBF_monthlyinterestmst] M on M.LBWHRVALUATIONID=D.LBWHRVALUATIONID	

INNER JOIN PRO.AccountMaster F ON F.CustomerAcid=A.CustomerAcid--borrowerID
				AND F.EffectiveFromTimekey<=@TIMEKEY AND F.EffectiveToTimekey>=@TIMEKEY


group by F.AccountEntityID,A.CustomerAcid ,				
B.caserefno  ,				
C.WHRNUMBER ,				
ISNULL(TotalLoanOutstanding,0) ,								
LOANMATURITYDATE 				
,ISNULL(TotalLoanOutstanding,0)				
,ISNULL(D.FINALLIMITAVAILABLEASPERMARGIN,0) 				
,B.lbid	



END


GO