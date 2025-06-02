SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=====================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE : 05-07-2018
MODIFY DATE : 05-07-2018
DESCRIPTION : SMA MARKING
EXEC PRO.SMA_MARKING  @TIMEKEY=25140
====================================*/
CREATE PROCEDURE [pro].[SMA_MARKING]
@TIMEKEY INT
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
	 
DECLARE @PROCESSDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)
Declare @vEffectiveto INT Set @vEffectiveto= (select Timekey-1 from PRO.EXTDATE_MISDB where Flg='Y')


 UPDATE A SET A.SMA_CLASS=NULL
             ,A.SMA_REASON=NULL
		     ,A.SMA_DT=NULL
		     ,A.FLGSMA=NULL
 FROM PRO.ACCOUNTCAL A 
 
UPDATE A SET A.SMA_CLASS=
   (CASE  WHEN DPD_MAX  BETWEEN 1 AND 30  THEN 'SMA_0'
	      WHEN DPD_MAX  BETWEEN 31 AND 60  THEN 'SMA_1'
		  WHEN DPD_MAX  BETWEEN 61 AND 90  THEN 'SMA_2'
		  WHEN DPD_MAX >90 THEN 'SMA_2'
		  ELSE NULL
		  END)
,A.SMA_REASON= (CASE 
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_INTSERVICE,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY INT NOT SERVICED'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_NOCREDIT,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY NO CREDIT'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_OVERDRAWN,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY CONTI EXCESS'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_STOCKSTMT,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY STOCK STATEMENT'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_RENEWAL,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY REVIEW DUE DATE'
					 WHEN A.FACILITYTYPE IN ('TL','DL','BP','BD','PC') AND ISNULL(DPD_OVERDUE,0)=ISNULL(DPD_MAX,0) THEN  'DEGRADE BY OVERDUE'
				  ELSE 'OTHER'
					END)
,A.SMA_DT=   DATEADD(DAY, -DPD_MAX ,@PROCESSDATE)
,A.FLGSMA='Y'
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.REFCUSTOMERID=B.REFCUSTOMERID
INNER JOIN DIMPRODUCT C ON C.PRODUCTALT_KEY=A.PRODUCTALT_KEY
WHERE ISNULL(B.FLGPROCESSING,'N')='N' AND ISNULL(FINALASSETCLASSALT_KEY,1)=1
 AND ISNULL(DPD_MAX,0)>0 AND ISNULL(A.BALANCE,0)>0 
   AND ISNULL(C.PRODUCTGROUP,'N')<>'KCC'  AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)

UPDATE A SET A.SMA_CLASS= (
                              CASE WHEN A.FACILITYTYPE IN('CC','OD') THEN ( CASE WHEN  REFPERIODOVERDRAWN-60>=DPD_MAX
							                                                       THEN 'SMA_0'
							                                                  WHEN REFPERIODOVERDRAWN-30>=DPD_MAX  THEN 'SMA_1'
																			    ELSE 'SMA_2' END) 
                              ELSE ( CASE WHEN  REFPERIODOVERDUE-60>=DPD_MAX
							                                                       THEN 'SMA_0'
							                                                  WHEN REFPERIODOVERDUE-30>=DPD_MAX  THEN 'SMA_1'
																			    ELSE 'SMA_2' END)
							  END)
			,A.SMA_REASON= (CASE 
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_INTSERVICE,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY INT NOT SERVICED'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_NOCREDIT,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY NO CREDIT'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_OVERDRAWN,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY CONTI EXCESS'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_STOCKSTMT,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY STOCK STATEMENT'
					 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD_RENEWAL,0)=ISNULL(DPD_MAX,0) THEN 'DEGRADE BY REVIEW DUE DATE'
					 WHEN A.FACILITYTYPE IN ('TL','DL','BP','BD','PC') AND ISNULL(DPD_OVERDUE,0)=ISNULL(DPD_MAX,0) THEN  'DEGRADE BY OVERDUE'
				  ELSE 'OTHER'
					END)
			,A.SMA_DT=   DATEADD(DAY, -DPD_MAX ,@PROCESSDATE)
			,A.FLGSMA='Y'				  
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.REFCUSTOMERID=B.REFCUSTOMERID
INNER JOIN DIMPRODUCT C ON C.PRODUCTALT_KEY=A.PRODUCTALT_KEY
WHERE ISNULL(B.FLGPROCESSING,'N')='N' AND ISNULL(FINALASSETCLASSALT_KEY,1)=1
AND ISNULL(DPD_MAX,0)>0  AND ISNULL(A.BALANCE,0)>0
AND ISNULL(C.PRODUCTGROUP,'N')='KCC'  AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)

/*------SMA MARKING FOR CUSTOMER LEVEL-------------------------*/

 UPDATE A SET A.FLGSMA=NULL
             ,A.SMA_CLASS_KEY=NULL
		     ,A.SMA_DT=NULL
		   FROM PRO.CUSTOMERCAL A 

UPDATE A SET A.FLGSMA='Y'
FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.REFCUSTOMERID =B.REFCUSTOMERID
WHERE B.FLGSMA='Y'


IF OBJECT_ID('TEMPDB..#TEMPTABLE_SMACLASS') IS NOT NULL
   DROP TABLE #TEMPTABLE_SMACLASS

SELECT A.REFCUSTOMERID,MAX(CASE WHEN SMA_CLASS='SMA_0' THEN  1 
                             WHEN SMA_CLASS='SMA_1' THEN  2
							 WHEN SMA_CLASS='SMA_2' THEN  3 ELSE 0 END ) MAXSMA_CLASS
							 ,MIN(A.SMA_Dt) AS SMA_Dt
                               
INTO #TEMPTABLE_SMACLASS
 FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B
ON A.REFCUSTOMERID=B.REFCUSTOMERID AND  B.FLGSMA='Y'
GROUP BY A.REFCUSTOMERID

UPDATE A SET A.SMA_CLASS_KEY=B.MAXSMA_CLASS,A.SMA_DT=B.SMA_Dt
FROM PRO.CUSTOMERCAL A  INNER JOIN  #TEMPTABLE_SMACLASS B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE A.FLGSMA='Y'



 IF EXISTS(SELECT 1 FROM PRO.SMA_MOVEMENT_HISTORY WHERE TIMEKEY=@TIMEKEY)
 BEGIN
  DELETE FROM PRO.SMA_MOVEMENT_HISTORY WHERE TIMEKEY=@TIMEKEY
 END


 IF OBJECT_ID('TEMPDB..#SMACLASS') IS NOT NULL
   DROP TABLE #SMACLASS

SELECT A.CustomerAcID,ISNULL(A.SMA_CLASS,CHOOSE(B.SMA_CLASS_KEY,'SMA_0','SMA_1','SMA_2'))  SMA_CLASS INTO #SMACLASS
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.REFCUSTOMERID=B.REFCUSTOMERID
 AND A.CUSTOMERENTITYID=B.CUSTOMERENTITYID AND A.FLGSMA='Y' 
WHERE B.FLGSMA='Y' AND  ISNULL(A.BALANCE,0)>0 AND ISNULL(B.SYSASSETCLASSALT_KEY,1)=1 

UPDATE #SMACLASS SET SMA_CLASS=(CASE WHEN SMA_CLASS='SMA_0' THEN 1
					WHEN SMA_CLASS='SMA_1' THEN 2
					WHEN SMA_CLASS='SMA_2' THEN 3 ELSE SMA_CLASS END)

INSERT INTO PRO.SMA_MOVEMENT_HISTORY (TIMEKEY,CustomerAcID,PREVSTATUS,CURRENTSTATUS)
SELECT @TIMEKEY,B.CustomerAcID,A.SMA_CLASS,B.SMA_CLASS 
FROM PRO.PREVSMASTATUS A  RIGHT OUTER JOIN  #SMACLASS B
ON A.CustomerAcID=B.CustomerAcID
WHERE B.SMA_CLASS IS NOT NULL AND ISNULL(A.SMA_CLASS,'')<>ISNULL(B.SMA_CLASS,'')

TRUNCATE TABLE PRO.PREVSMASTATUS

INSERT INTO PRO.PREVSMASTATUS
SELECT @TIMEKEY,CustomerAcID,SMA_CLASS
FROM #SMACLASS


   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='STD' WHERE SYSASSETCLASSALT_KEY=1
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SUB' WHERE SYSASSETCLASSALT_KEY=2
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='DB1' WHERE SYSASSETCLASSALT_KEY=3 
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='DB2' WHERE SYSASSETCLASSALT_KEY=4 
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='DB3' WHERE SYSASSETCLASSALT_KEY=5 
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='LOS' WHERE SYSASSETCLASSALT_KEY=6
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SMA_0' WHERE SMA_CLASS_KEY=1
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SMA_1' WHERE SMA_CLASS_KEY=2
   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SMA_2 ' WHERE SMA_CLASS_KEY=3

   UPDATE PRO.AccountCal SET SMA_CLASS='STD' WHERE FinalAssetClassAlt_Key=1 AND  SMA_CLASS is NULL
   UPDATE PRO.AccountCal SET SMA_CLASS='SUB' WHERE FinalAssetClassAlt_Key=2 AND  SMA_CLASS is NULL
   UPDATE PRO.AccountCal SET SMA_CLASS='DB1' WHERE FinalAssetClassAlt_Key=3  AND  SMA_CLASS is NULL
   UPDATE PRO.AccountCal SET SMA_CLASS='DB2' WHERE FinalAssetClassAlt_Key=4  AND  SMA_CLASS is NULL
   UPDATE PRO.AccountCal SET SMA_CLASS='DB3' WHERE FinalAssetClassAlt_Key=5  AND  SMA_CLASS is NULL
   UPDATE PRO.AccountCal SET SMA_CLASS='LOS' WHERE FinalAssetClassAlt_Key=6 AND  SMA_CLASS is NULL
  



  if EXISTS  ( select  1  from PRO.ACCOUNT_MOVEMENT_HISTORY where  [EffectiveFromTimeKey]= @Timekey)
	  begin
		 print 'NO NEDD TO INSERT DATA'
	  end 
else
begin
	IF OBJECT_ID ('TEMPDB..#ACCOUNT_MOVEMENT_HISTORY') IS NOT NULL
	DROP TABLE #ACCOUNT_MOVEMENT_HISTORY


CREATE TABLE #ACCOUNT_MOVEMENT_HISTORY (
	[UCIF_ID] [varchar](50) NULL,
	[RefCustomerID] [varchar](50) NULL,
	[SourceSystemCustomerID] [varchar](50) NULL,
	[CustomerAcID] [varchar](225) NULL,
	[FinalAssetClassAlt_Key] [int] NULL,
	[FinalNpaDt] [date] NULL,
	[EffectiveFromTimeKey] [int] NULL,
	[EffectiveToTimeKey] [int] NULL,
	[MovementFromStatus] [varchar](10) NULL,
	[MovementToStatus]   [varchar](10) NULL,
	[TotOsAcc] DECIMAL(18,2),
	/*  added by amar 19072023 - for optimisation*/
	MovementFromDate date,   
	MovementToDate date,   
	)


	INSERT INTO	#ACCOUNT_MOVEMENT_HISTORY
			(
					UCIF_ID,
					RefCustomerID,
					SourceSystemCustomerID,
					CustomerAcID,
					FinalAssetClassAlt_Key,
					FinalNpaDt,
					EffectiveFromTimeKey,
					EffectiveToTimeKey,
					MovementFromStatus,
					MovementToStatus,
					TotOsAcc,
					/*  added by amar 19072023 - for optimisation*/
					MovementFromDate,   
					MovementToDate   

		    )

		
SELECT 
   UCIF_ID,
   RefCustomerID,
   SourceSystemCustomerID,
   CustomerAcID,
   FinalAssetClassAlt_Key,
   FinalNpaDt,
   EffectiveFromTimeKey,
   49999 AS  EffectiveToTimeKey
   ,SMA_CLASS AS MovementFromStatus
   ,SMA_CLASS AS MovementToStatus
   ,ISNULL(Balance,0) as TotOsAcc
 	/*  added by amar 19072023 - for optimisation*/
   ,@ProcessDate	MovementFromDate   
   ,'2086-11-21'	 MovementToDate     
     FROM  PRO.ACCOUNTCAL 
   
  
  INSERT  INTO  PRO.ACCOUNT_MOVEMENT_HISTORY

  (
					UCIF_ID,
					RefCustomerID,
					SourceSystemCustomerID,
					CustomerAcID,
					FinalAssetClassAlt_Key,
					FinalNpaDt,
					EffectiveFromTimeKey,
					EffectiveToTimeKey,
					MovementFromStatus,
					MovementToStatus
					,TotOsAcc,
					/*  added by amar 19072023 - for optimisation*/
				MovementFromDate,   
					MovementToDate     
  )
  SELECT 

                   A.UCIF_ID,
					A.RefCustomerID,
					A.SourceSystemCustomerID,
					A.CustomerAcID,
					A.FinalAssetClassAlt_Key,
					A.FinalNpaDt,
					A.EffectiveFromTimeKey,
					A.EffectiveToTimeKey,
					ISNULL(B.MovementTOStatus,A.MovementFromStatus),
					A.MovementToStatus,
					ISNULL(A.TotOsAcc,0) AS TotOsAcc,
					/*  added by amar 19072023 - for optimisation*/
					A.MovementFromDate,   
					A.MovementToDate      

					FROM #ACCOUNT_MOVEMENT_HISTORY A 
					LEFT JOIN PRO.ACCOUNT_MOVEMENT_HISTORY B ON A.CustomerAcID=B.CustomerAcID
					 AND B.EFFECTIVETOTimekey=49999

				WHERE  
			       (CASE WHEN  B.CustomerAcID IS NULL THEN 1
						 WHEN B.CustomerAcID IS NOT NULL AND  A.MOVEMENTFROMSTATUS<>B.MOVEMENTTOSTATUS THEN 1 END )=1

 UPDATE AA
SET 
 	EffectiveToTimeKey = @vEffectiveto
	,MovementToDate =dateadd(dd,-1,@ProcessDate)  	/*  added by amar 19072023 - for optimisation*/
FROM PRO.ACCOUNT_MOVEMENT_HISTORY AA
LEFT JOIN #ACCOUNT_MOVEMENT_HISTORY B ON  AA.CustomerAcID=B.CustomerAcID AND B.EffectiveToTimeKey =49999
WHERE AA.EffectiveToTimeKey = 49999
and B.CustomerAcID is null

  
   UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto
  	 ,MovementToDate =dateadd(dd,-1,@ProcessDate)  	/*  added by amar 19072023 - for optimisation*/
FROM PRO.ACCOUNT_MOVEMENT_HISTORY AA
WHERE AA.EffectiveToTimeKey = 49999 AND AA.EffectiveFROMTimeKey<@TIMEKEY
AND  EXISTS (SELECT 1 FROM #ACCOUNT_MOVEMENT_HISTORY BB

				WHERE AA.CustomerAcID=BB.CustomerAcID
				AND BB.EffectiveToTimeKey =49999
				--AND AA.MOVEMENTFROMSTATUS<>BB.MOVEMENTTOSTATUS  	/*  cimmented by amar 19072023 - for optimisation*/
				AND AA.MOVEMENTTOSTATUS<>BB.MOVEMENTTOSTATUS 
				)

  
   	/*  commented by amar 19072023 - for optimisation*/
  /*
  UPDATE A SET MovementFromDate=B.DATE
    FROM PRO.ACCOUNT_MOVEMENT_HISTORY  A 
   inner join sysdaymatrix B on A.EffectiveFromTimeKey=B.TimeKey
   UPDATE A SET MovementToDate=B.DATE


    FROM PRO.ACCOUNT_MOVEMENT_HISTORY  A 
   inner join sysdaymatrix B on A.EffectiveToTimeKey=B.TimeKey
     */
	/*  added by amar 19072023 - for optimisation*/
      UPDATE A SET MovementToDate=dateadd(dd,-1,@ProcessDate)
    FROM PRO.ACCOUNT_MOVEMENT_HISTORY  A 
		where a.EffectiveToTimeKey =@vEffectiveto
   END

  if EXISTS  ( select  1  from PRO.CUSTOMER_MOVEMENT_HISTORY where  [EffectiveFromTimeKey]= @Timekey)
	  begin
		 print 'NO NEDD TO INSERT DATA'
	  end 
else
begin
	IF OBJECT_ID ('TEMPDB..#Customer_MOVEMENT_HISTORY') IS NOT NULL
	DROP TABLE #Customer_MOVEMENT_HISTORY


CREATE TABLE #Customer_MOVEMENT_HISTORY (
	[UCIF_ID] [varchar](50) NULL,
	[RefCustomerID] [varchar](50) NULL,
	[SourceSystemCustomerID] [varchar](50) NULL,
	[CustomerName] [varchar](225) NULL,
	[SysAssetClassAlt_Key] [int] NULL,
	[SysNPA_Dt] [date] NULL,
	[EffectiveFromTimeKey] [int] NULL,
	[EffectiveToTimeKey] [int] NULL,
	[MovementFromStatus] [varchar](10) NULL,
	[MovementToStatus]   [varchar](10) NULL,
	[TotOsCust] decimal(18,2),
	/*  added by amar 19072023 - for optimisation*/
	MovementFromDate DATE,	 
	MovementToDate DATE,		 
	)


	INSERT INTO	#Customer_MOVEMENT_HISTORY
			(
					UCIF_ID,
					RefCustomerID,
					SourceSystemCustomerID,
					CustomerName,
					SysAssetClassAlt_Key,
					SysNPA_Dt,
					EffectiveFromTimeKey,
					EffectiveToTimeKey,
					MovementFromStatus,
					MovementToStatus,
					totOsCust,
					/*  added by amar 19072023 - for optimisation*/
					MovementFromDate,		 
					MovementToDate			 
					
		    )

		
SELECT 
   UCIF_ID,
   RefCustomerID,
   SourceSystemCustomerID,
   CustomerName,
   SysAssetClassAlt_Key,
   SysNPA_Dt,
   EffectiveFromTimeKey,
   49999 AS  EffectiveToTimeKey
   ,CustMoveDescription AS MovementFromStatus
   ,CustMoveDescription AS MovementToStatus
   ,ISNULL(TotOsCust,0) AS TotOsCust
   /*  added by amar 19072023 - for optimisation*/
   ,@ProcessDate	MovementFromDate   
   ,'2086-11-21'MovementToDate		 

     FROM  PRO.CustomerCal 
   
  
  INSERT  INTO  PRO.CUSTOMER_MOVEMENT_HISTORY

  (
					UCIF_ID,
					RefCustomerID,
					SourceSystemCustomerID,
					CustomerName,
					SysAssetClassAlt_Key,
					SysNPA_Dt,
					EffectiveFromTimeKey,
					EffectiveToTimeKey,
					MovementFromStatus,
					MovementToStatus,
					TotOsCust,
					/*  added by amar 19072023 - for optimisation*/
					MovementFromDate,	 
					MovementToDate	 
  )
  SELECT 

                   A.UCIF_ID,
					A.RefCustomerID,
					A.SourceSystemCustomerID,
					A.CustomerName,
					A.SysAssetClassAlt_Key,
					A.SysNPA_Dt,
					A.EffectiveFromTimeKey,
					A.EffectiveToTimeKey,
					ISNULL(B.MovementTOStatus,A.MovementFromStatus),
					A.MovementToStatus,
					ISNULL(A.TotOsCust,0) AS TotOsCust,
					/*  added by amar 19072023 - for optimisation*/
					A.MovementFromDate,  
					A.MovementToDate     
					FROM #Customer_MOVEMENT_HISTORY A 
					LEFT JOIN PRO.CUSTOMER_MOVEMENT_HISTORY B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
					 AND B.EFFECTIVETOTimekey=49999

WHERE  
			       (CASE WHEN  B.SourceSystemCustomerID IS NULL THEN 1
						 WHEN B.SourceSystemCustomerID IS NOT NULL AND  A.MOVEMENTFROMSTATUS<>B.MOVEMENTTOSTATUS THEN 1 END )=1

 UPDATE AA
SET 
	 EffectiveToTimeKey = @vEffectiveto
	 ,MovementToDate =dateadd(dd,-1,@ProcessDate) /*  added by amar 19072023 - for optimisation*/
FROM PRO.CUSTOMER_MOVEMENT_HISTORY AA
LEFT JOIN #Customer_MOVEMENT_HISTORY B ON  AA.SourceSystemCustomerID=B.SourceSystemCustomerID AND B.EffectiveToTimeKey =49999
WHERE AA.EffectiveToTimeKey = 49999
and B.SourceSystemCustomerID is null

  
   UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto
   ,MovementToDate =dateadd(dd,-1,@ProcessDate) /*  added by amar 19072023 - for optimisation*/
FROM PRO.CUSTOMER_MOVEMENT_HISTORY AA
WHERE AA.EffectiveToTimeKey = 49999 AND AA.EffectiveFROMTimeKey<@TIMEKEY
AND  EXISTS (SELECT 1 FROM #Customer_MOVEMENT_HISTORY BB

				WHERE AA.SourceSystemCustomerID=BB.SourceSystemCustomerID
				AND BB.EffectiveToTimeKey =49999
				AND AA.MOVEMENTTOSTATUS<>BB.MOVEMENTTOSTATUS 
				)

  
   	/*  commented by amar 19072023 - for optimisation*/
 
 /*
  UPDATE A SET MovementFromDate=B.DATE
    FROM PRO.Customer_MOVEMENT_HISTORY  A 
   inner join sysdaymatrix B on A.EffectiveFromTimeKey=B.TimeKey

   UPDATE A SET MovementToDate=B.DATE
    FROM PRO.Customer_MOVEMENT_HISTORY  A 
   inner join sysdaymatrix B on A.EffectiveToTimeKey=B.TimeKey
*/
	/*  added by amar 19072023 - for optimisation*/
   UPDATE A SET MovementToDate=DATEADD(DD,1,@ProcessDate)
    FROM PRO.Customer_MOVEMENT_HISTORY  A 
   ----inner join sysdaymatrix B on A.EffectiveToTimeKey=B.TimeKey
    WHERE A.EffectiveToTimeKey =@vEffectiveto
   end 



UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
WHERE RUNNINGPROCESSNAME='SMA_MARKING'

    


END TRY
BEGIN  CATCH


     DROP TABLE #TEMPTABLE_SMACLASS
	 DROP TABLE #SMACLASS
	 DROP TABLE #ACCOUNT_MOVEMENT_HISTORY
	 DROP TABLE #Customer_MOVEMENT_HISTORY

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
WHERE RUNNINGPROCESSNAME='SMA_MARKING'

END CATCH
SET NOCOUNT OFF
END

GO