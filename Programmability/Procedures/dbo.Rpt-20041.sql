SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




 CREATE PROCEDURE [dbo].[Rpt-20041]
   @TimeKey AS INT,
   @RangeFrom VARCHAR(20),
   @RangeTo   VARCHAR(20),
   @Cost      AS FLOAT
AS 

   --     DECLARE 
   --     @TimeKey AS INT =25749,
	  --@RangeFrom VARCHAR(20)='03-11-2010',
	  --@RangeTo   VARCHAR(20)='03-11-2023',
	  --@Cost      AS FLOAT=1

	  declare @From1 date,@to1 date 
SET @From1=(SELECT * FROM dbo.DateConvert(@RangeFrom))
SET @to1=(SELECT * FROM dbo.DateConvert(@RangeTo))




--IF OBJECT_ID('TEMPDB.dbo.#CUSTOMERCAL20041') IS NOT NULL
--  DROP TABLE #CUSTOMERCAL20041 

--select * into #CUSTOMERCAL20041 FROM PRO.Customercal_hist L where L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY

--IF OBJECT_ID('TEMPDB.dbo.#accountcal20041') IS NOT NULL
--  DROP TABLE #accountcal20041

--select * into #accountcal20041 FROM PRO.accountcal_hist L where L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY

--Select 
--C.SourceDBName AS [SOURCE SYSTEM]
--,A.UCIF_ID
--,A.RefCustomerID AS  CustomerID
--,A.SourceSystemCustomerID AS SourceSystemCustomerID
--,A.CustomerName AS CustomerName
--,A.PANNO AS [PAN NO]
--,B.CustomerAcID AS CustomerAcID
--,ISNULL(B.IntOverdue,0)/@cost AS [O/S INTEREST AMT]
--,ISNULL(B.Balance,0)/@cost AS [O/S AMT (LCY)]
--,ISNULL(B.PrincOutStd,0)/@cost AS POS
--,ISNULL(B.OverdueAmt,0)/@cost AS OverdueAmt
--,ISNULL(B.DPD_IntService,0) AS DPD_IntService
--,ISNULL(B.DPD_Overdrawn,0) AS DPD_Overdrawn
--,ISNULL(B.DPD_Overdue,0) AS DPD_Overdue
--,ISNULL(B.DPD_Renewal,0) AS DPD_Renewal
--,ISNULL(B.DPD_StockStmt,0) AS DPD_StockStmt 
--,ISNULL(B.DPD_Max,0) AS DPD_Max
--,B.PNPA_Reason AS PNPA_Reason
--,case when B.PNPA_Reason like '%PERCOLATION%' then ltrim(rtrim((substring(B.PNPA_Reason,patindex('%Account%',B.PNPA_Reason)+7,len(B.PNPA_Reason)-patindex('%Account%',B.PNPA_Reason)+7)))) else  B.CustomerAcID end as [Trigger Account]
--, CONVERT(VARCHAR(20),A.PNPA_Dt,103)   AS CustPNPA_Dt
--, CONVERT(VARCHAR(20),B.PNPA_DATE,103)  as AccountPNPA_Dt
--,B.ProductCode AS ProductCode
--,B.ASSET_NORM AS ASSET_NORM  
--from #CUSTOMERCAL20041 A  
--inner join #accountcal20041 B   
--on A.CustomerEntityID=B.CustomerEntityID
--INNER JOIN DimSourceDB C ON C.SourceAlt_Key=B.SourceAlt_Key
--AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)
--where A.FlgPNPA='Y'  
--AND ((cast(A.PNPA_Dt as date) BETWEEN cast(@From1 as date) and cast(@to1 as date) and @From1 is not null )
--or(@From1 is null and @to1 is not null and cast(ISNULL(A.PNPA_Dt,'1900-01-01') as date) <=cast(@to1 as date))
--or(@From1 is not null and @to1 is  null and cast(A.PNPA_Dt as date) >=cast(@From1 as date))
--or (@From1 is  null and @to1 is  null)
--)
--order by A.PNPA_Dt,A.UCIF_ID,A.REFCUSTOMERID asc
--DROP TABLE #accountcal20041,#CUSTOMERCAL20041


Select 
C.SourceDBName AS [SOURCE SYSTEM]
,A.UCIF_ID
,A.RefCustomerID AS  CustomerID
,A.SourceSystemCustomerID AS SourceSystemCustomerID
,A.CustomerName AS CustomerName
,A.PANNO AS [PAN NO]
,B.CustomerAcID AS CustomerAcID
,ISNULL(B.IntOverdue,0)/@cost AS [O/S INTEREST AMT]
,ISNULL(B.Balance,0)/@cost AS [O/S AMT (LCY)]
,ISNULL(B.PrincOutStd,0)/@cost AS POS
,ISNULL(B.OverdueAmt,0)/@cost AS OverdueAmt
,ISNULL(B.DPD_IntService,0) AS DPD_IntService
,ISNULL(B.DPD_Overdrawn,0) AS DPD_Overdrawn
,ISNULL(B.DPD_Overdue,0) AS DPD_Overdue
,ISNULL(B.DPD_Renewal,0) AS DPD_Renewal
,ISNULL(B.DPD_StockStmt,0) AS DPD_StockStmt 
,ISNULL(B.DPD_Max,0) AS DPD_Max
,B.PNPA_Reason AS PNPA_Reason
,case when B.PNPA_Reason like '%PERCOLATION%' then ltrim(rtrim((substring(B.PNPA_Reason,patindex('%Account%',B.PNPA_Reason)+7,len(B.PNPA_Reason)-patindex('%Account%',B.PNPA_Reason)+7)))) else  B.CustomerAcID end as [Trigger Account]
, CONVERT(VARCHAR(20),A.PNPA_Dt,103)   AS CustPNPA_Dt
, CONVERT(VARCHAR(20),B.PNPA_DATE,103)  as AccountPNPA_Dt
,B.ProductCode AS ProductCode
,B.ASSET_NORM AS ASSET_NORM  
from PRO.Customercal_hist A  
inner join PRO.accountcal_hist B   
on A.CustomerEntityID=B.CustomerEntityID
and  A.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND A.EFFECTIVETOTIMEKEY=@TIMEKEY
and B.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND B.EFFECTIVETOTIMEKEY=@TIMEKEY
INNER JOIN DimSourceDB C ON C.SourceAlt_Key=B.SourceAlt_Key
AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)
where A.FlgPNPA='Y'  
AND ((cast(A.PNPA_Dt as date) BETWEEN cast(@From1 as date) and cast(@to1 as date) and @From1 is not null )
or(@From1 is null and @to1 is not null and cast(ISNULL(A.PNPA_Dt,'1900-01-01') as date) <=cast(@to1 as date))
or(@From1 is not null and @to1 is  null and cast(A.PNPA_Dt as date) >=cast(@From1 as date))
or (@From1 is  null and @to1 is  null)
)
order by A.PNPA_Dt,A.UCIF_ID,A.REFCUSTOMERID asc




GO