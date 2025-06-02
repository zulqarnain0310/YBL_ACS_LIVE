SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 16-02-2021
MODIFY DATE : 16-02-2021
DESCRIPTION : INSERT DATA STOCKSTDATE

============================================*/

CREATE PROCEDURE [pro].[StockStDate_Insert_Data]
AS
BEGIN
   DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
   DECLARE @processingdate date=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE Flg='Y')

   DELETE  FROM  PRO.StockStDate WHERE EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY

   
INSERT INTO PRO.StockStDate
(
 ICRABorrowerID
,PDTSID
,Segment
,CustomerName
,RMName
,CovenantType
,CovenantDescription
--,DueDate
,Remark
--,DeferralDate
,DPD
,NoofGraceDays
,Frequency
,Authority
,EffectiveFromTimeKey
,EffectiveToTimeKey
,Processingdate
)

SELECT 
 ICRA_BORR_ID AS ICRABorrowerID
,PDTS_ID AS PDTSID
,B_SEGMENT AS Segment
,CUSTOMER_NAME AS CustomerName
,RM_NAME AS RMName
,TYPE_OF_COVENANT AS CovenantType
,COVENANT_DESC AS CovenantDescription
--,CASE WHEN DUE_DATE='NULL'  OR  DUE_DATE='' THEN NULL ELSE CONVERT(Date, DUE_DATE, 103) END AS DueDate 
,REMARKS AS Remark
--,CASE WHEN DEFF_DATE='NULL' OR  DEFF_DATE='' THEN NULL ELSE CONVERT(Date, DEFF_DATE, 103) END AS DeferralDate 
,DAYS_PAST_DUE AS DPD
,No_of_Days AS NoofGraceDays
,Frequency AS Frequency
,APPROVING_AUTHORITY as Authority
,@TIMEKEY AS EffectiveFromTimeKey
,@TIMEKEY AS EffectiveToTimeKey
,@processingdate as Processingdate

from YBL_ACS_MIS.[DBO].[RPT_CONSOL_EXCEPTION_StockStatement] 
where TYPE_OF_COVENANT in 
('BB Stock Statement for DP',
'Qualified Stock Statement',
'Stock Statement',
'Unsecured Stock Statement',
'Cash Budget for DP',
'INF Stock Statement for DP'
)
AND DAYS_PAST_DUE > 0


---Actual due date logic
update PRO.StockStDate set [ActualDueDate] =DATEADD(DAY,-NoofGraceDays,DueDate) -- DeferralDate Removed as per mail dated 2023-08-23 done by Pranay --DATEADD(DAY,-NoofGraceDays,isnull(DeferralDate,DueDate))
where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY and  CovenantType in 
('BB Stock Statement for DP','Qualified Stock Statement','Stock Statement','Unsecured Stock Statement','INF Stock Statement for DP')
-----End Actual due date logic

-----Actual stock duedate

update PRO.StockStDate set ActualStockduedate =
case when Frequency in ('NA','Monthly') then DATEADD(month,-1,ActualDueDate)
when Frequency ='Quarterly' then  DATEADD(month,-3,ActualDueDate)
when Frequency ='Half Yearly' then  DATEADD(month,-6,ActualDueDate)
when Frequency ='Annually' then  DATEADD(month,-12,ActualDueDate)
end
where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY and  CovenantType in 
('BB Stock Statement for DP','Qualified Stock Statement','Stock Statement','Unsecured Stock Statement','INF Stock Statement for DP')
----End Actual stock duedate

----Stock statement date DPD calculation

 update PRO.StockStDate set  [ActualStockDPD] =DATEdiff(DAY,ActualStockduedate,Processingdate)
 where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY and  CovenantType in 
('BB Stock Statement for DP','Qualified Stock Statement','Stock Statement','Unsecured Stock Statement','INF Stock Statement for DP')

 ----End 

 ---Actual due date logic of Cash Budget for DP
update PRO.StockStDate set [ActualDueDate] =DATEADD(DAY,-NoofGraceDays,DueDate) -- DeferralDate Removed as per mail dated 2023-08-23 done by Pranay -- DATEADD(DAY,-NoofGraceDays,isnull(DeferralDate,DueDate))
where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY and  CovenantType in 
('Cash Budget for DP')
-----End Actual due date logic

-----Actual stock duedate

update PRO.StockStDate set ActualStockduedate =[ActualDueDate]
where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY and  CovenantType in 
('Cash Budget for DP')
----End Actual stock duedate



--------Stock statement date DPD calculation for Cash Budget for DP

---- update PRO.StockStDate set  [ActualStockDPD] =DATEdiff(DAY,[ActualDueDate],Processingdate)
---- where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY and  CovenantType in 
----('Cash Budget for DP')
--------Stock statement date DPD calculation for Cash Budget for DP

 update PRO.StockStDate set  [ActualStockDPD] =DATEdiff(DAY,[ActualStockduedate],Processingdate)
 where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY and  CovenantType in 
('Cash Budget for DP')

 ----End 

END


GO