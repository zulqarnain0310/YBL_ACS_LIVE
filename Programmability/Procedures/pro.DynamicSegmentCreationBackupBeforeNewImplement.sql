SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*===================================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE : 29-10-2018
MODIFY DATE : 29-10-2018
DESCRIPTION : INSERT DATA FOR DEMAND SET OFF TABLE
--EXEC [Pro].[DynamicSegmentCreation]
=====================================================*/
CREATE PROCEDURE [pro].[DynamicSegmentCreationBackupBeforeNewImplement]   
AS  
BEGIN  
  
SET NOCOUNT ON  
      BEGIN TRY                
 DECLARE @Count Int    
  , @CountUpto Int  
  , @AccountEntityID Int  
  , @StartPoint int  
  , @Date Date  
  , @LatestSchNo tinyint  
  , @Query varchar(max)  


SET NOCOUNT ON;  
  
  SET @Date=(SELECT CAST(EndDate AS DATE) FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
  
IF OBJECT_ID('TempDb..#ElegibleAccount') IS NOT NULL  
DROP TABLE #ElegibleAccount  
  
SELECT Rec.UCIF_ID, ROW_NUMBER() OVER (ORDER BY Rec.UCIF_ID) SrNo  
INTO #ElegibleAccount  
FROM AdvAcCCRecoveryDetail Rec  
INNER JOIN (SELECT UCIF_ID   
            FROM PRO.AcDailyTxnDetailDaily   
            WHERE TxnDate <=@Date
            AND TxnType='CREDIT'  
            AND TxnSubType='RECOVERY'  
            GROUP BY UCIF_ID) TXN ON Rec.UCIF_ID=TXN.UCIF_ID  
INNER JOIN (SELECT UCIF_ID   
            FROM dbo.AdvAcCCDemandDetail  
            WHERE ISNULL(BalanceDemand,0)>0  
            GROUP BY UCIF_ID) Dmd ON Dmd.UCIF_ID=Rec.UCIF_ID                            
WHERE ISNULL(BalRecovery,0) > 0  
GROUP BY Rec.UCIF_ID  
  
Declare @NoofSegments TinyInt = 1 

TRUNCATE TABLE DemandRunSegmentMark  
  
INSERT INTO DemandRunSegmentMark (UCIF_ID, SrNo, SegmentNo)  
SELECT AeD.UCIF_ID ,aed.SrNo, NTILE(@NoofSegments) OVER (ORDER BY aed.SrNo) SegmentNo  
FROM #ElegibleAccount AeD  
  
SELECT SegmentNo, COUNT(1)  
FROM DemandRunSegmentMark  
GROUP BY SegmentNo  
ORDER BY SegmentNo  
  
PRINT '1'  
  
SET @Count  = @NoofSegments  
SET @Query  = ''  
  
while @Count >   0  
begin  
  
set @Query = null   
select @Query ='  
IF OBJECT_ID(''dbo.AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+''')  IS NOT NULL  
DROP TABLE dbo.AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'  
  
CREATE TABLE dbo.AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' (  
 [EntityKey] [int] IDENTITY(1,1) NOT NULL,  
 [CustomerID] [varchar](30) NULL,  
 [DemandType] [varchar](25) NULL,  
 [DemandDate] [date] NOT NULL,  
 [DemandAmt] [decimal](16, 2) NULL,  
 [RecDate] [date] NULL,  
 [RecAdjDate] [date] NULL,  
 [RecAmount] [decimal](16, 2) NULL,  
 [BalanceDemand] [decimal](16, 2) NULL,  
 [DmdSchNumber] [tinyint] NULL,  
 [AcType] [varchar](25) NULL ,
 [UCIF_ID][varchar](50) NULL
) ON [PRIMARY]'   
EXEC (@Query)  
SET @Count = @Count - 1  
END 
      
--***********************************************************************************************************************************  
--  
--************************************************************************************************************************************       
PRINT '2'  
SET @Count  = @NoofSegments  
SET @Query  = ''  
  
while @Count >   0  
begin  
  
set @Query = null   
select @Query ='   
IF OBJECT_ID(''dbo.AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+''')  IS NOT NULL  
DROP TABLE dbo.AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'  
  
CREATE TABLE dbo.AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'(  
 [EntityKey] [int] IDENTITY(1,1) NOT NULL,  
 [TxnID] [varchar](50) NULL,  
 [CustomerID] [varchar](30) NULL,   
 [RecAmt] [decimal](16, 2) NULL,  
 [RecDate] [date] NOT NULL,  
 [DemandDate] [date] NULL,  
 --[DemandAdj] [decimal](16, 2) NULL,  
 [BalRecovery] [decimal](16, 2) NULL  ,
 [UCIF_ID][varchar](50) NULL
) ON [PRIMARY]'   
EXEC (@Query)  
set @Count = @Count - 1  
end  
  
--***********************************************************************************************************************************  
--INSERT DATA INTO AdvAcDemandDetail  
--************************************************************************************************************************************       
PRINT '3'  
SET @Count = @NoofSegments  
SET @Query = NULL   
  
while @Count >   0  
begin  
  
set @Query = null   
select @Query =   
'INSERT INTO AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'   
           ([CustomerID],[DemandType],[DemandDate],[DemandAmt],[RecDate],[RecAdjDate],[RecAmount]  
           ,[BalanceDemand],[DmdSchNumber],[AcType],[UCIF_ID])  
    SELECT  DMD.[CustomerID],[DemandType],[DemandDate],[DemandAmt],[RecDate],[RecAdjDate],[RecAmount]  
           ,[BalanceDemand],[DmdSchNumber],[AcType],DMD.[UCIF_ID]
FROM  AdvAcCCDemandDetail DMD  
INNER JOIN DemandRunSegmentMark B ON DMD.UCIF_ID = B.UCIF_ID  
WHERE B.SegmentNo = '+CONVERT(VARCHAR(50),@Count)            
  
exec (@Query)  
set @Count = @Count - 1  
end      
  
--***********************************************************************************************************************************  
--INSERT DATA INTO AdvAcRecoveryDetail  
--************************************************************************************************************************************       
PRINT '4'  
  
SET @Count = @NoofSegments  
SET @Query = NULL   
  
while @Count >   0  
begin  
  
set @Query = null   
select @Query =   
'INSERT INTO AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'   
           ([CustomerID],[RecAmt],[RecDate]  
           ,[BalRecovery],[UCIF_ID])  
 SELECT      [DMD].[CustomerID],[RecAmt],[RecDate]  
            ,[BalRecovery]  ,DMD.[UCIF_ID]  
FROM AdvAcCCRecoveryDetail DMD  
INNER JOIN DemandRunSegmentMark B ON DMD.UCIF_ID = B.UCIF_ID  
WHERE B.SegmentNo = '+CONVERT(VARCHAR(50),@Count)                       
  
EXEC (@Query)  
set @Count = @Count - 1  
end 
  
--**********************************************************************************************************************************  
--CREATE INDEXES   
--**********************************************************************************************************************************  
PRINT '5'  
  
SET @Count = @NoofSegments  
SET @Query = NULL   
  
while @Count >   0  
begin  
  
set @Query = null   
select @Query =   
'  
CREATE CLUSTERED INDEX AdvAcCCDemandDetail_ctrl_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)  
+'  ON dbo.AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'    
(  
 [EntityKey] ASC  
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE =ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80)  
ON [PRIMARY]  
  
/****** Object:  Index [AdvAcCCDemandDetail_001_IX]    Script Date: 05/29/2015 13:22:26 ******/  
CREATE NONCLUSTERED INDEX AdvAcCCDemandDetail_001_IX_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'   
        ON dbo.AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+ '  
(  
 [CustomerID] ASC,  
 [DemandDate] ASC,  
 [BalanceDemand] ASC  ,
 [UCIF_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80)   
ON [PRIMARY]  
  
  
/****** Object:  Index [AdvAcCCDemandDetail_002_IX]    Script Date: 05/29/2015 13:25:07 ******/  
CREATE NONCLUSTERED INDEX AdvAcCCDemandDetail_002_IX_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'    
    ON dbo.AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'    
(  
 [DemandDate] ASC  
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80)   
ON [PRIMARY]  
  
CREATE NONCLUSTERED INDEX AdvAcCCDemandDetail_003_IX_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'     
            ON dbo.AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'     
(  
 [CustomerID] ASC,  
 [DemandType] ASC  ,
 [UCIF_ID] ASC
)  
INCLUDE ( [BalanceDemand])   
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80)   
ON [PRIMARY]  
  
  
/****** Object:  Index [AdvAcCCRecoveryDetail_ctrl]    Script Date: 05/29/2015 13:36:02 ******/  
CREATE CLUSTERED INDEX AdvAcCCRecoveryDetail_ctrl_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'     
 ON dbo.AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'      
(  
 [EntityKey] ASC  
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80)   
ON [PRIMARY]  
  
  
/****** Object:  Index [AdvAcCCRecoveryDetail_001_IX]    Script Date: 05/29/2015 13:37:54 ******/  
CREATE NONCLUSTERED INDEX AdvAcCCRecoveryDetail_001_IX_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'      
        ON dbo.AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'       
(  
 [CustomerID] ASC,  
 [BalRecovery] ASC,  
 [RecDate] ASC ,
 [UCIF_ID] ASC 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80)   
ON [PRIMARY]'  
  
EXEC (@Query)  
set @Count = @Count - 1  
end   
   
  
--**********************************************************************************************************************************  
--DmdRecoSetOffLogicCC Creation   
--**********************************************************************************************************************************  
PRINT '6'  
  
SET @Count = @NoofSegments  
  
DECLARE   @Query_1 varchar(max)=NULL  
  , @Query_2 varchar(max)=NULL  
  , @ProcExistance varchar(max)=NULL  
        , @Query_3 varchar(max)=NULL  
  
WHILE @Count >0  
BEGIN  
  
SET @Query_1 = null   
  
  
SELECT @ProcExistance =    
'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''dbo.[DmdRecoSetOffLogicCC_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+']'') AND type in (N''P'', N''PC''))  
DROP PROCEDURE [dbo].[DmdRecoSetOffLogicCC_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+']'  
  
EXEC (@ProcExistance)  
  
SELECT @Query_1 =  
' /*===========================================
   AUTHER : SANJEEV KUMAR SHARMA
   CREATE DATE : 01-11-2018
   MODIFY DATE : 01-11-2018
   DESCRIPTION : DEMAND RECOVERY SET OFF
    ================================================*/
CREATE PROCEDURE [dbo].[DmdRecoSetOffLogicCC_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+']    
                                            -- (   
              --@TimeKey INT  
            --,@UCIF_ID VARCHAR(30)  
           -- )  
WITH Recompile  
AS  
  
BEGIN  
  
SET NOCOUNT ON;  
  
        BEGIN TRY  
  
                             
                
       declare  @Recovery_Count Int  =1           
        , @Recovery_Loop Int = 1  
        , @BalRecAmt Decimal(36,2)  
        , @RecDate Date  
        , @Demand_Count Int  
        , @Demand_Loop Int = 1  
        , @Demand_Amount Decimal(36,2)  
        , @ExcessDemandAmt Decimal(36,2)  
        , @ProcessDate Date  
		, @Customerid VARCHAR (30)
		, @UCIF_ID VARCHAR (50)
    SELECT @ProcessDate = CAST(Date AS DATE)  
  FROM dbo.SysDayMatrix D  
  WHERE D.TimeKey = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = ''Y'') 

  IF OBJECT_ID('+'''TEMPDB..#RecoveryAmtList'''+') IS NOT NULL
		DROP TABLE #RecoveryAmtList
 
	;WITH CTE_DMD_CUST
	AS
	(
		SELECT UCIF_ID FROM AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count) +'
			GROUP BY UCIF_ID 
	)
	  
  	SELECT ROW_NUMBER() OVER (ORDER BY A.UCIF_ID,RecDate) SrNo, A.*
        INTO #RecoveryAmtList  
     FROM AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' A   
			INNER JOIN CTE_DMD_CUST B
				ON A.UCIF_ID=B.UCIF_ID
		WHERE ISNULL(BalRecovery,0) > 0  
			AND RecDate <= @ProcessDate  
        ORDER BY DemandDate ASC,BalRecovery ASC  
			OPTION(Recompile)  

     CREATE CLUSTERED INDEX #RecoveryAmtList_Ctrl
		ON #RecoveryAmtList (SrNo)
  
  SELECT @Recovery_Count =  COUNT(1)  
  FROM #RecoveryAmtList    

  
    WHILE @Recovery_Loop <= @Recovery_Count  
      BEGIN  
  
           /*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/  
          /*  Taking All Recovery which are having balance recovery for specific account        */  
         /*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/  
  
            -- Reset parameter value  
  
          SELECT   @BalRecAmt = NULL   
                  , @RecDate = NULL   
                  ,@UCIF_ID =null
				  
  
           SELECT    @BalRecAmt = BalRecovery    
                   , @RecDate = RecDate   
                   , @UCIF_ID = UCIF_ID   
           FROM #RecoveryAmtList Dt  
           WHERE Dt.SrNo = @Recovery_Loop 
  
  
           SELECT @Demand_Count = COUNT(1)  
                 , @Demand_Loop = 1  
           FROM AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' DmD 
           WHERE UCIF_ID = @UCIF_ID
           AND ISNULL(DmD.BalanceDemand,0) > 0   
           AND DemandDate <= @ProcessDate  
		   and DemandDate<=@RecDate
    
  
                  WHILE @Demand_Loop < = @Demand_Count  
  
                  BEGIN  
  
  
                    SET @ExcessDemandAmt = 0  
  
           /*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/  
          /*  Taking All Demand which are haing balance Demand Amt for specific account        */  
         /*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/  
  
  
                         IF OBJECT_ID(''Tempdb..#DemandAmtList'') IS NOT NULL  
                         DROP TABLE #DemandAmtList  
                            
                         SELECT ROW_NUMBER() OVER (ORDER BY DemandDate) SrNo_Dmd, *  
                         INTO #DemandAmtList  
                         FROM AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' DmD  
                         WHERE UCIF_ID = @UCIF_ID
                         AND ISNULL(DmD.BalanceDemand,0) > 0   
                         AND DemandDate <= @ProcessDate  
                         ORDER BY DemandDate ASC, BalanceDemand ASC  
                         OPTION(Recompile)  
  
  
                         CREATE CLUSTERED INDEX #DemandAmtList_Ctrl  
                         ON #DemandAmtList (SrNo_Dmd)  
  
                      IF NOT EXISTS (select 1 from #DemandAmtList where DemandDate <= @RecDate)   
                      BREAK;  
                     -- Update Recovery date, Adjustment data and Recovery amount  
                        UPDATE Dt_Demand  
                        SET Dt_Demand.RecDate = @RecDate  
                         , Dt_Demand.RecAdjDate = @ProcessDate  
                         , Dt_Demand.DemandAmt = (CASE WHEN ISNULL(Dt_Demand.DemandAmt,0) <= @BalRecAmt   
                                  THEN ISNULL(Dt_Demand.DemandAmt,0)  
                                ELSE @BalRecAmt  
                               END)  
                         , Dt_Demand.RecAmount = (CASE WHEN ISNULL(Dt_Demand.DemandAmt,0) <= @BalRecAmt   
                                  THEN ISNULL(Dt_Demand.DemandAmt,0)  
                                ELSE @BalRecAmt  
                               END)  
  
                         , Dt_Demand.BalanceDemand = 0    
  
                         , @ExcessDemandAmt = (CASE WHEN ISNULL(Dt_Demand.DemandAmt,0) <= @BalRecAmt   
                                 THEN 0  
                              ELSE ISNULL(Dt_Demand.DemandAmt,0) - @BalRecAmt  
                              END)  
                         , @Demand_Amount = ISNULL(Dt_Demand.DemandAmt,0)  
                        FROM AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' Dt_Demand  
                        INNER JOIN #DemandAmtList Dl on Dt_Demand.EntityKey = Dl.EntityKey  
                        WHERE DL.SrNo_Dmd = 1  
                        AND Dt_Demand.DemandDate <= @RecDate  
  
           
                        SET @BalRecAmt = (CASE WHEN ISNULL(@Demand_Amount,0) < @BalRecAmt   
                               THEN @BalRecAmt - ISNULL(@Demand_Amount,0)  
                             ELSE 0  
                             END)'  
   
  
           ,@Query_2=                    '-- If the excess demand has found then insert a new row for excess demand   
           
		                IF @ExcessDemandAmt > 0  
                        BEGIN  
  
                           INSERT INTO AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'(customerid,DemandType,DemandDate,DemandAmt,RecDate,RecAdjDate,RecAmount,BalanceDemand,DmdSchNumber,AcType,UCIF_ID)  
                           SELECT Dt_Demand.customerid                 
                                  , Dt_Demand.DemandType   
                               , Dt_Demand.DemandDate   
                               , @ExcessDemandAmt AS DemandAmt   
                               , NULL RecDate   
                               , NULL RecAdjDate   
                               , NULL RecAmount   
                               , @ExcessDemandAmt AS BalanceDemand   
                               , Dt_Demand.DmdSchNumber   
                               , Dt_Demand.AcType  
							   ,Dt_Demand.UCIF_ID
                           FROM AdvAcCCDemandDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' Dt_Demand  
                           INNER JOIN #DemandAmtList Dl on Dt_Demand.EntityKey = Dl.EntityKey  
                           WHERE DL.SrNo_Dmd = 1  
                           AND Dt_Demand.DemandDate <= @RecDate  
                        END  
  
   
  
  
                        IF @BalRecAmt < = 0  
                        BREAK  
  
  
                        SET @Demand_Loop = @Demand_Loop + 1  
                  END  
   
  
           IF @BalRecAmt > 0  
           BEGIN  
             
           -- Balance recovery update  
             UPDATE Dt  
             SET Dt.BalRecovery = @BalRecAmt  
             FROM AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' Dt  
             INNER JOIN #RecoveryAmtList RL on RL.EntityKey = Dt.EntityKey  
              WHERE RL.SrNo = @Recovery_Loop 
           END  
  
           ELSE  
           BEGIN  
  
              -- nullfy if there is no excess recovery  
             UPDATE Dt  
             SET Dt.BalRecovery = 0  
             FROM AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+' Dt  
             INNER JOIN #RecoveryAmtList RL on RL.EntityKey = Dt.EntityKey  
             WHERE RL.SrNo = @Recovery_Loop 
           END  
  
         SET @Recovery_Loop = @Recovery_Loop + 1  
      END  
  
  END TRY  
  
  BEGIN CATCH  
               SELECT ''Proc Name: '' + ERROR_PROCEDURE() + '' Error Msg: '' + ERROR_MESSAGE()  
  END CATCH  
END' 
  
SET @Query_3=@Query_1+'  
                      '+@Query_2  


EXEC (@Query_3)  
--PRINT @Query_3
  
SET @Count=@Count-1  
END
  
----**********************************************************************************************************************************  
----CCDemandRecoverySetoff_Run Creation   
----**********************************************************************************************************************************  
--PRINT '7'  
  
  
--SET @Count = @NoofSegments  
  
--WHILE @Count >0  
--BEGIN  
  
--SET @Query_1 = null   
  
  
--SELECT @ProcExistance =  'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[CCDemandRecoverySetoff_Run_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+']'') AND type in (N''P'', N''PC''))  
--DROP PROCEDURE [dbo].[CCDemandRecoverySetoff_Run_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+']'  
  
--EXEC (@ProcExistance)  
  
--SELECT @Query_1 =  
--'  /*===========================================
--   AUTHER : SANJEEV KUMAR SHARMA
--   CREATE DATE : 01-11-2018
--   MODIFY DATE : 01-11-2018
--   DESCRIPTION : DEMAND RECOVERY SET OFF
--    ================================================*/

--CREATE PROCEDURE [dbo].[CCDemandRecoverySetoff_Run_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+']   (@TimeKey int)  
--  AS  
  
--BEGIN  
--         BEGIN TRY  
--             SET NOCOUNT ON;  

--			 declare @date date =(select date From SysDayMatrix where TimeKey= @TimeKey)
  
--IF OBJECT_ID(''Tempdb..#TLDLDMDRECOSETOFF'') IS NOT NULL  
--DROP TABLE #TLDLDMDRECOSETOFF  
  
--SELECT customerID, ROW_NUMBER() OVER (ORDER BY customerID) SrNo  
--INTO #TLDLDMDRECOSETOFF  
--FROM AdvAcCCRecoveryDetail_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'  
--WHERE ISNULL(BalRecovery,0) > 0  
--AND customerID IN (SELECT DISTINCT customerID FROM PRO.AcDailyTxnDetailDaily WHERE TxnDate <=@date)
--GROUP BY customerID  
  

  
--Declare @Count Int = 1  
--  , @CountUpto Int  
--  , @customerID Varchar(30)  
  
  
----==============================================================================================================  
---- Demand Recovery SetOff Running.  
---- As per discussion the any demand must not satisfied by trailed recovery.  
----==============================================================================================================  
  
--SELECT @CountUpto =  count(1)   
--FROM #TLDLDMDRECOSETOFF  
  
  
--WHILE @Count <= @CountUpto  
--  BEGIN  
  
--    SELECT @customerID = customerID
--    FROM #TLDLDMDRECOSETOFF  
--    WHERE SrNo =@Count  
       
--    PRINT  ''COUNT : '' + CONVERT(VARCHAR(100),@Count)  
--    EXEC [DmdRecoSetOffLogicCC_Seg'+REPLICATE('0',(2-LEN(CONVERT(VARCHAR(50),@Count))))+CONVERT(VARCHAR(50),@Count)+'] @TimeKey,@customerID
  
--  SET @Count = @Count + 1  
  
--  END  
  
  
  

  
--   END TRY  
  
--   BEGIN CATCH  
--                 SELECT ERROR_MESSAGE() [ERROR MESSAGE]  
--   END CATCH  
--END'  
  
--EXEC (@Query_1)  
  
--SET @Count=@Count-1  
  
--END  

END TRY  
   BEGIN CATCH  
                SELECT 'Proc Name: ' + ISNULL(ERROR_PROCEDURE(),'') + ' ErrorMsg: ' + ISNULL(ERROR_MESSAGE(),'')  
   END CATCH             
END









GO