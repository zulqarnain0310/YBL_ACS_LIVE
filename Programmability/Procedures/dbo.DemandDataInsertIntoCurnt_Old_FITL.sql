SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 25-04-2019
MODIFY DATE : 25-04-2019
DESCRIPTION : DemandDataInsertIntoCurnt_Old
--EXEC DemandDataInsertIntoCurnt_Old_FITL
============================================*/

CREATE PROCEDURE [dbo].[DemandDataInsertIntoCurnt_Old_FITL]
AS
BEGIN


BEGIN TRY
	IF OBJECT_ID('TEMPDB..#UCIF_TO_BE_SERV') IS NOT NULL
		DROP TABLE #UCIF_TO_BE_SERV


		SELECT DISTINCT A.UCIF_ID
			INTO #UCIF_TO_BE_SERV
			FROM [DBO].[ADVACCCDEMANDDETAIL] A
		INNER JOIN (SELECT UCIF_ID FROM [DBO].[ADVACCCRECOVERYDETAIL] GROUP BY UCIF_ID
					)B
					ON A.UCIF_ID=B.UCIF_ID


--DELETE DMD
--FROM DemandRunSegmentMark A
--INNER JOIN dbo.AdvAcCCDemandDetail DMD ON A.UCIF_ID=DMD.UCIF_ID
-- DELETE REC
--FROM DemandRunSegmentMark A
--INNER JOIN dbo.AdvAcCCRecoveryDetail REC ON A.UCIF_ID=REC.UCIF_ID



DECLARE @Count SMALLINT 
, @Query VARCHAR(MAX)


SET @Count = 1
SET @Query = NULL 

WHILE @Count >   0
BEGIN

SET @Query = null 
 
	--SET @Count = @Count - 1

----fitl
SELECT @Query = 
'
            INSERT INTO [AdvAcCCRecoveryDetail_FITL]
           ([customerid],[RecAmt],[RecDate]
           ,[BalRecovery],[UCIF_ID])
		SELECT [customerid],[RecAmt],[RecDate]
                  ,[BalRecovery] ,[UCIF_ID]       
          FROM AdvAcCCRecoveryDetail_Seg_FITL'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'


   INSERT INTO [AdvAcCCDemandDetaiL_FITL]
           ([customerid],[DemandType],[DemandDate],[DemandAmt],[RecDate],[RecAdjDate],[RecAmount]
           ,[BalanceDemand],[DmdSchNumber],[Actype],[UCIF_ID],MnemonicCode)
       SELECT [customerid],[DemandType],[DemandDate],[DemandAmt],[RecDate],[RecAdjDate],[RecAmount]
               ,[BalanceDemand],[DmdSchNumber],[Actype],[UCIF_ID],MnemonicCode
          FROM AdvAcCCDemandDetail_Seg_FITL'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count) 

	EXEC (@Query)
	SET @Count = @Count - 1



END
--
/* check recovery addjested error */
	DECLARE @DATE DATE=(SELECT StartDate  FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
	DECLARE @TotalDmdCountServiced INT,
			@MinDmdCountServiced INT,
			@UCIF_ID VARCHAR(MAX)

	IF OBJECT_ID('TEMPDB..#MissingUcifId') IS NOT NULL
		DROP TABLE #MissingUcifId

		CREATE TABLE #MissingUcifId (UCIF_ID VARCHAR(30))

				INSERT INTO #MissingUcifId
				SELECT A.UCIF_ID 
					FROM #UCIF_TO_BE_SERV A
						LEFT JOIN (	SELECT DISTINCT UCIF_ID 
									FROM [AdvAcCCDemandDetail] 
									WHERE RecDate=@DATE or RecAdjDate=@DATE
								)B
							ON A.UCIF_ID=B.UCIF_ID
					WHERE B.UCIF_ID IS NULL
		-------	END


		SELECT  @UCIF_ID= LEFT(C, LEN(C) - 1) 
							FROM 
							(  SELECT ', '+UCIF_ID FROM #MissingUcifId M1
								FOR XML PATH('')
							) AS D(C)

		SET @UCIF_ID=RIGHT(@UCIF_ID,LEN(@UCIF_ID)-1)

		SELECT @MinDmdCountServiced=COUNT(DISTINCT UCIF_ID), @TotalDmdCountServiced=COUNT(UCIF_ID) 
		FROM [AdvAcCCDemandDetail] WHERE RecDate=@DATE or RecAdjDate=@DATE


		UPDATE [dbo].[InttServiceControlTbl_FITL] 
		SET TotalDmdCountServiced=@TotalDmdCountServiced, 
			MinDmdCountServiced=@MinDmdCountServiced ,
			[MissingUCIF_ID]=@UCIF_ID
	WHERE ProcessingDate=@DATE

	UPDATE [dbo].[InttServiceControlTbl_FITL] 
		SET Tallied='Y' 
			,EndTime= GETDATE()
	WHERE ProcessingDate=@DATE AND MinDmdCountServiced>=MinDmdCountToBeServiced

	--------declare @DATE date='2019-04-01'
	--IF  EXISTS (select 1 from [dbo].[InttServiceControlTbl_FITL] where ProcessingDate=@DATE and Tallied='N')
	--	BEGIN

	--		SELECT 'Demand Recovery Set of Error.......' Error
	--		RETURN 
	--	END
/* end  */

insert into pro.AdvAcCCDemandDetail_old
(
CustomerID
,DemandType
,DemandDate
,DemandAmt
,RecDate
,RecAdjDate
,RecAmount
,BalanceDemand
,DmdSchNumber
,AcType
,UCIF_ID
,MnemonicCode
)
select
CustomerID
,DemandType
,DemandDate
,DemandAmt
,RecDate
,RecAdjDate
,RecAmount
,BalanceDemand
,DmdSchNumber
,AcType
,UCIF_ID
,MnemonicCode
from AdvAcCCDemandDetail_fitl
where isnull(BalanceDemand,0)=0


insert into pro.AdvAcCCDemandDetail_curnt
(
CustomerID
,DemandType
,DemandDate
,DemandAmt
,RecDate
,RecAdjDate
,RecAmount
,BalanceDemand
,DmdSchNumber
,AcType
,UCIF_ID
,MnemonicCode
)
select
CustomerID
,DemandType
,DemandDate
,DemandAmt
,RecDate
,RecAdjDate
,RecAmount
,BalanceDemand
,DmdSchNumber
,AcType
,UCIF_ID
,MnemonicCode
from AdvAcCCDemandDetail_fitl
where isnull(BalanceDemand,0)>0




 UPDATE [dbo].[InttServiceControlTbl_FITL] 
		SET EndTime= GETDATE()
	WHERE ProcessingDate=@DATE 


END TRY
BEGIN CATCH
		SELECT 'Error in Megre process...'
END CATCH


END






GO