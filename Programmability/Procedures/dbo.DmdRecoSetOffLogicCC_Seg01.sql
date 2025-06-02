SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 /*===========================================
   AUTHER : SANJEEV KUMAR SHARMA
   CREATE DATE : 01-11-2018
   MODIFY DATE : 01-11-2018
   DESCRIPTION : DEMAND RECOVERY SET OFF
    ================================================*/
CREATE PROCEDURE [dbo].[DmdRecoSetOffLogicCC_Seg01]    
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
  WHERE D.TimeKey = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y') 

  IF OBJECT_ID('TEMPDB..#RecoveryAmtList') IS NOT NULL
		DROP TABLE #RecoveryAmtList
 
	;WITH CTE_DMD_CUST
	AS
	(
		SELECT UCIF_ID FROM AdvAcCCDemandDetail_Seg01
			GROUP BY UCIF_ID 
	)
	  
  	SELECT ROW_NUMBER() OVER (ORDER BY A.UCIF_ID,RecDate) SrNo, A.*
        INTO #RecoveryAmtList  
     FROM AdvAcCCRecoveryDetail_Seg01 A   
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
           FROM AdvAcCCDemandDetail_Seg01 DmD 
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
  
  
                         IF OBJECT_ID('Tempdb..#DemandAmtList') IS NOT NULL  
                         DROP TABLE #DemandAmtList  
                            
                         SELECT ROW_NUMBER() OVER (ORDER BY DemandDate) SrNo_Dmd, *  
                         INTO #DemandAmtList  
                         FROM AdvAcCCDemandDetail_Seg01 DmD  
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
                        FROM AdvAcCCDemandDetail_Seg01 Dt_Demand  
                        INNER JOIN #DemandAmtList Dl on Dt_Demand.EntityKey = Dl.EntityKey  
                        WHERE DL.SrNo_Dmd = 1  
                        AND Dt_Demand.DemandDate <= @RecDate  
  
           
                        SET @BalRecAmt = (CASE WHEN ISNULL(@Demand_Amount,0) < @BalRecAmt   
                               THEN @BalRecAmt - ISNULL(@Demand_Amount,0)  
                             ELSE 0  
                             END)  
                      -- If the excess demand has found then insert a new row for excess demand   
           
		                IF @ExcessDemandAmt > 0  
                        BEGIN  
  
                           INSERT INTO AdvAcCCDemandDetail_Seg01(customerid,DemandType,DemandDate,DemandAmt,RecDate,RecAdjDate,RecAmount,BalanceDemand,DmdSchNumber,AcType,UCIF_ID,MnemonicCode)  
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
							   ,Dt_Demand.MnemonicCode 
                           FROM AdvAcCCDemandDetail_Seg01 Dt_Demand  
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
             FROM AdvAcCCRecoveryDetail_Seg01 Dt  
             INNER JOIN #RecoveryAmtList RL on RL.EntityKey = Dt.EntityKey  
              WHERE RL.SrNo = @Recovery_Loop 
           END  
  
           ELSE  
           BEGIN  
  
              -- nullfy if there is no excess recovery  
             UPDATE Dt  
             SET Dt.BalRecovery = 0  
             FROM AdvAcCCRecoveryDetail_Seg01 Dt  
             INNER JOIN #RecoveryAmtList RL on RL.EntityKey = Dt.EntityKey  
             WHERE RL.SrNo = @Recovery_Loop 
           END  
  
         SET @Recovery_Loop = @Recovery_Loop + 1  
      END  
  

  IF  OBJECT_ID('BalanceRecoveryAmtList') is not null
	DROP TABLE BalanceRecoveryAmtList
	
	SELECT UCIF_ID,RECDATE,BalRecovery INTO BalanceRecoveryAmtList FROM AdvAcCCRecoveryDetail_Seg01 WHERE BalRecovery>0
	union all
	select UCIF_ID,RECDATE,BalRecovery  from [DBO].[ADVACCCRECOVERYDETAIL] where UCIF_ID not in(SELECT UCIF_ID from TempElegibleAccount)




	DELETE DMD
	FROM DemandRunSegmentMark A
	INNER JOIN dbo.AdvAcCCDemandDetail DMD ON A.UCIF_ID=DMD.UCIF_ID
	 DELETE REC
	FROM DemandRunSegmentMark A
	INNER JOIN dbo.AdvAcCCRecoveryDetail REC ON A.UCIF_ID=REC.UCIF_ID


  END TRY  
  
  BEGIN CATCH  
               SELECT 'Proc Name: ' + ERROR_PROCEDURE() + ' Error Msg: ' + ERROR_MESSAGE()  
  END CATCH  
END
GO