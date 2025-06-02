SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*==================================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE : 24-10-2018
MODIFY DATE : 24-10-2018
DESCRIPTION : GENERATED ACCOUNT AND CUSTOMER ,UCIFID IN MASTER KEY
--EXEC [Pro].[CUSTOMER_ACCOUNT_UCIFID_MASTERKEY_GENERATION]

=======================================================*/

Create PROCEDURE [pro].[CUSTOMER_ACCOUNT_UCIFID_MASTERKEY_GENERATION]
AS
BEGIN

BEGIN TRY

DECLARE @TIMEKEY INT =(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for Customer_Account_Ucif_Id_Masterkey_Generation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

/*--------------CLEAN SOURCE DATA-------------------*/


 UPDATE CustomerData SET SourceSystemName='GANASEVA' FROM YBL_ACS_MIS..CustomerData WHERE SourceSystemName IN ('GANASEVA' ,'GANSEVA') AND SourceSystemName<>'GANASEVA'
 UPDATE AccountData SET SourceSystemName='GANASEVA' FROM YBL_ACS_MIS..AccountData WHERE SourceSystemName IN ('GANASEVA' ,'GANSEVA')  AND SourceSystemName<>'GANASEVA'

UPDATE CustomerData SET SourceSystemCustomerID=SourceSystemName+CAST(SourceSystemCustomerID AS VARCHAR(60))FROM YBL_ACS_MIS..CustomerData WHERE SourceSystemName='FinnOne'  and SourceSystemCustomerID not like '%FinnOne%'
UPDATE AccountData SET SourceSystemCustomerID=SourceSystemName+CAST(SourceSystemCustomerID AS VARCHAR(60)) FROM YBL_ACS_MIS..AccountData  WHERE SourceSystemName='FinnOne'  and SourceSystemCustomerID not like '%FinnOne%'

UPDATE CustomerData SET SourceSystemCustomerID=SourceSystemName+CAST(SourceSystemCustomerID AS VARCHAR(60))FROM YBL_ACS_MIS..CustomerData WHERE SourceSystemName='GANASEVA'  and SourceSystemCustomerID not like '%GANASEVA%'
UPDATE AccountData SET SourceSystemCustomerID=SourceSystemName+CAST(SourceSystemCustomerID AS VARCHAR(60)) FROM YBL_ACS_MIS..AccountData  WHERE SourceSystemName='GANASEVA'  and SourceSystemCustomerID not like '%GANASEVA%'

------Added on 20220311 Triloki
--UPDATE CustomerData_CA SET SourceSystemCustomerID='CRED'+CAST(SourceSystemCustomerID AS VARCHAR(60)) FROM YBL_ACS_MIS..CustomerData_CA   WHERE SourceSystemName='CREDAVENUE_DA'  and SourceSystemCustomerID not like '%CRED%'
--UPDATE AccountData_CA SET SourceSystemCustomerID='CRED'+CAST(SourceSystemCustomerID AS VARCHAR(60)) FROM YBL_ACS_MIS..AccountData_CA   WHERE SourceSystemName='CREDAVENUE_DA'  and SourceSystemCustomerID not like '%CRED%'


----Changed 2023-09-15
UPDATE CustomerData_CA SET SourceSystemCustomerID='CREDAVENUE'+CAST(FCR_CustomerID AS VARCHAR(60)) FROM YBL_ACS_MIS..CustomerData_CA where  FCR_CustomerID is not null 
UPDATE AccountData_CA SET SourceSystemCustomerID='CREDAVENUE'+CAST(FCR_CustomerID AS VARCHAR(60)) FROM YBL_ACS_MIS..AccountData_CA   where  FCR_CustomerID is not null 




UPDATE YBL_ACS_MIS.DBO.AccountData SET NPADate=NULL WHERE NPADate='1900-01-01' 

update CustomerData set FCR_CustomerID=ltrim(FCR_CustomerID) from YBL_ACS_MIS..CustomerData
update CustomerData set SourceSystemCustomerID=ltrim(SourceSystemCustomerID) from YBL_ACS_MIS..CustomerData 
update AccountData set FCR_CustomerID=ltrim(FCR_CustomerID) from YBL_ACS_MIS..AccountData 
update AccountData set SourceSystemCustomerID=ltrim(SourceSystemCustomerID) from YBL_ACS_MIS..AccountData  
UPDATE YBL_ACS_MIS..AccountData SET SourceSystemCustomerID= FCR_CustomerID WHERE SourceSystemName='GOLD' AND SourceSystemCustomerID IS  NULL



-------Updation of UCIC where source not providing ---12-Feb-2021
IF OBJECT_ID('TEMPDB..#tempcustomer') is not  null 
   DROP TABLE #tempcustomer

select A.UCIC_ID,A.FCR_CustomerID into #tempcustomer from YBL_ACS_MIS..CustomerData A where A.UCIC_ID is not null and A.FCR_CustomerID is not null


update A set UCIC_ID = b.UCIC_ID from YBL_ACS_MIS..CustomerData  A inner join #tempcustomer b on a.FCR_CustomerID= b.FCR_CustomerID 
where A.UCIC_ID is null


----Changed cred Avenue 15-09-2023
update A set UCIC_ID = b.UCIC_ID from YBL_ACS_MIS..CustomerData_CA  A inner join #tempcustomer b on a.FCR_CustomerID= b.FCR_CustomerID 
where A.UCIC_ID is null


-----30-Dec-2021 changed by Triloki
update A set UCIC_ID = FCR_CustomerID from YBL_ACS_MIS..CustomerData  A where (A.UCIC_ID is null or A.UCIC_ID ='0')  and A.FCR_CustomerID is not null

------End Updation of UCIC where source not providing ----

/*--------------NEW INSERT RECORD FOR ALL CUSTOMER DATA-------------------*/

IF OBJECT_ID('TEMPDB..#TempTableCustomerID') is not  null 
   DROP TABLE #TempTableCustomerID

SELECT SourceSystemCustomerID SourceCustomerID into #TempTableCustomerID 
FROM YBL_ACS_MIS..AccountData  where YBL_ACS_MIS..AccountData.SourceSystemCustomerID
 is not null and YBL_ACS_MIS..AccountData.SourceSystemCustomerID<>'999999999'
EXCEPT 
SELECT SourceCustomerID FROM PRO.CustomerMaster where Effectivetotimekey=49999



INSERT INTO PRO.CUSTOMERMASTER
(SourceCustomerID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT  SourceCustomerID,@TIMEKEY EFFECTIVEFROMTIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TEMPTABLECUSTOMERID

/*------------NEW INSERT RECORD FOR MUREX CUSTOMER DATA-------------------*/
/*------------COMMENT DUE TO MUREX BASE PRESNT IN FCC/FCR  TRILOKI 14/01/2019-------------------*/
--IF OBJECT_ID('TEMPDB..#TempTableCustomerIDMUREX') is not  null 
--   DROP TABLE #TempTableCustomerIDMUREX

--SELECT  'INV'+CAST(CONTRACTORIGINREFERENCE AS VARCHAR(50)) SourceCustomerID 
--INTO #TempTableCustomerIDMUREX 
--FROM YBL_ACS_MIS..ODS_MUREX_DPD_NPA 
--where ( FCC_CustomerID <>'')
--EXCEPT 
--SELECT SourceCustomerID FROM PRO.CustomerMaster where Effectivetotimekey=49999



UPDATE YBL_ACS_MIS..ODS_MUREX_DPD_NPA SET Match_FCR='N'

UPDATE C SET Match_FCR='Y' FROM PRO.CustomerMaster  A
INNER JOIN  YBL_ACS_MIS..CustomerData B ON A.SourceCustomerID=B.SourceSystemCustomerID
INNER JOIN YBL_ACS_MIS..ODS_MUREX_DPD_NPA  C ON C.FCC_CustomerID=B.FCR_CustomerID
WHERE A.Effectivetotimekey=49999  AND (C.FCC_CustomerID <>'')

IF OBJECT_ID('TEMPDB..#TempTableCustomerIDMUREX') is not  null 
   DROP TABLE #TempTableCustomerIDMUREX

--SELECT SourceSystemCustomerID SourceCustomerID into #TempTableCustomerIDMUREX FROM YBL_ACS_MIS..CustomerData
--where  SourceSystemCustomerID in( select distinct FCC_CustomerID  FROM YBL_ACS_MIS..ODS_MUREX_DPD_NPA 
--where ( FCC_CustomerID <>'')) 
--EXCEPT 
--SELECT SourceCustomerID FROM PRO.CustomerMaster where Effectivetotimekey=49999

SELECT DISTINCT FCC_CUSTOMERID SOURCECUSTOMERID INTO #TEMPTABLECUSTOMERIDMUREX   FROM YBL_ACS_MIS..ODS_MUREX_DPD_NPA 
WHERE ( FCC_CUSTOMERID <>'')AND MATCH_FCR='N'
EXCEPT
SELECT SourceCustomerID FROM PRO.CustomerMaster where Effectivetotimekey=49999

INSERT INTO PRO.CUSTOMERMASTER
(SourceCustomerID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT SourceCustomerID,@TIMEKEY EFFECTIVEFROMTIMEKEY ,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerIDMUREX


/*-----------NEW INSERT RECORD FOR ECBF CUSTOMER DATA---------------*/

IF OBJECT_ID('TEMPDB..#TempTableCustomerIDECBF') is not  null 
   DROP TABLE #TempTableCustomerIDECBF

SELECT   distinct A.Ubscustomerid  SourceCustomerID
INTO #TempTableCustomerIDECBF 
--FROM YBL_ACS_MIS.[dbo].[ODS_ECBF_BORROWERMST]
from YBL_ACS_MIS.[DBO].[ODS_ECBF_BORROWERMST]  A
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBMST B ON A.borrowerID=B.borrowerID
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONREF C ON B.lbid=C.lbid
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONMST D ON D.WHRNUMBER=C.WHRNUMBER 
AND D.WHRCLOSEFLAG<>1  INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_LBLOANPROCESSREF E ON E.WHRINWARDID=D.WHRINWARDID

EXCEPT 
SELECT SourceCustomerID FROM PRO.CustomerMaster where Effectivetotimekey=49999

INSERT INTO PRO.CUSTOMERMASTER
(SourceCustomerID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT SourceCustomerID,@TIMEKEY EFFECTIVEFROMTIMEKEY ,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerIDECBF



-----------NON FUNDED CUSTOMER ID 06/01/2022-------
----IF OBJECT_ID('TEMPDB..#TempTableCustomerIDNF') is not  null 
----   DROP TABLE #TempTableCustomerIDNF

----SELECT DISTINCT SourceSystemCustomerID SourceCustomerID into #TempTableCustomerIDNF 
----FROM YBL_ACS_MIS..AccountData_NF  where YBL_ACS_MIS..AccountData_NF.SourceSystemCustomerID
---- is not null and YBL_ACS_MIS..AccountData_NF.SourceSystemCustomerID<>'999999999'
----EXCEPT 
----SELECT SourceCustomerID FROM PRO.CustomerMaster where Effectivetotimekey=49999



----INSERT INTO PRO.CUSTOMERMASTER
----(SourceCustomerID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
----SELECT  SourceCustomerID,@TIMEKEY EFFECTIVEFROMTIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerIDNF



-------CRED CUSTOMER ID 19/01/2022-------
IF OBJECT_ID('TEMPDB..#TempTableCustomerIDCRED') is not  null 
   DROP TABLE #TempTableCustomerIDCRED

SELECT DISTINCT SourceSystemCustomerID SourceCustomerID into #TempTableCustomerIDCRED 
FROM YBL_ACS_MIS..CustomerData_CA  where YBL_ACS_MIS..CustomerData_CA.SourceSystemCustomerID
 is not null and YBL_ACS_MIS..CustomerData_CA.SourceSystemCustomerID<>'999999999'
EXCEPT 
SELECT SourceCustomerID FROM PRO.CustomerMaster where Effectivetotimekey=49999



INSERT INTO PRO.CUSTOMERMASTER
(SourceCustomerID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT  SourceCustomerID,@TIMEKEY EFFECTIVEFROMTIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerIDCRED





--------/*----EXPIRE OLD DATA CUSTOMER DATA-----------------*/

--------IF OBJECT_ID('TEMPDB..#TempTableCustomerIDEXPIRE') is not  null 
--------   DROP TABLE #TempTableCustomerIDEXPIRE

--------/*------------COMMENT DUE TO MUREX BASE PRESNT IN FCC/FCR  TRILOKI 14/01/2019-------------------*/


----------SELECT SourceCustomerID  INTO #TempTableCustomerIDEXPIRE FROM #TempTableCustomerIDMUREX
----------UNION ALL 
--------SELECT SourceCustomerID INTO #TempTableCustomerIDEXPIRE FROM PRO.CustomerMaster WHERE EffectiveToTimekey=49999
--------UNION ALL
--------SELECT SourceCustomerID FROM #TempTableCustomerIDECBF

--------UPDATE A SET A.EffectiveToTimekey=@TIMEKEY-1
-------- FROM PRO.CUSTOMERMASTER A LEFT OUTER JOIN  #TempTableCustomerIDEXPIRE  B 
--------ON A.SourceCustomerID=B.SourceCustomerID
--------WHERE B.SourceCustomerID IS NULL AND A.EffectiveToTimekey=49999


/*-----------NEW ACCOUNT DATA INSERT-----------------*/

--(1) 869 prodcut in FCR should exclude as same data will be given by ECFS.
--(2) 605 prodcut in FCR should exclude as same data will be given by ecbf.
--(3) 891 prodcut in FCR should exclude as same data will be given by eifs.
--(4) 703 prodcut in FCR should exclude as same data will be given by eifs.
--(5) 704 prodcut in FCR should exclude as same data will be given by eifs.
--(6) 705,209 prodcut in FCR should exclude as same data will be given by eifs.
--(7) Exclude write off Product from data preperation as per mail dated 29/01/2019 by Pramod Shetty ODS 

IF OBJECT_ID('TEMPDB..#TempTableCustomerAcid') is not  null 
   DROP TABLE #TempTableCustomerAcid

SELECT AccountID CustomerAcid into #TempTableCustomerAcid FROM YBL_ACS_MIS..AccountData 
--where ProductCode not in('869','605','891','703','704','705') and SourceSystemName not in('FCR')
where (ProductCode not in('869','605','891','703','704','705','209') OR SourceSystemName NOT in('FCR'))
--AND (ProductCode not in ('NP01','WA01','WA02','WA03','WA04','CHFL' ))
AND (ProductCode not in ('NP01','CHFL' )) --- INCLUDE  WRITE OFF ACCOUNT 17/02/2020 TRILOKI KHANNA AS PER BANK POINT
EXCEPT 
SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999


INSERT INTO PRO.ACCOUNTMASTER
(CUSTOMERACID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT CUSTOMERACID,@TIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TEMPTABLECUSTOMERACID


----Mail dated 25/02/2019 changed  done product code 869 present in FCR also Mahesh Shirali ---
-----	We also  have a similar situation like COMMODITY & EINF where lines are set in 869 product code for accounts open in DMS/Channel, 
--however a part of loan the portfolio also exists in FCR too, so at this point in time we cannot ignore this product code we have to wait till entire loan portfolio is migrated  to Channel/DMS & this Product code will be a dummy code which will be used for tracking for limits – We need discussion here.       


IF OBJECT_ID('TEMPDB..#TEMPTABLECUSTOMERACIDCUSTOMER869') IS NOT  NULL 
   DROP TABLE #TEMPTABLECUSTOMERACIDCUSTOMER869

SELECT DISTINCT FCR_CUSTOMERID INTO #TEMPTABLECUSTOMERACIDCUSTOMER869 FROM YBL_ACS_MIS..ACCOUNTDATA WHERE  PRODUCTCODE='869'
EXCEPT
SELECT DISTINCT FCR_CUSTOMERID FROM YBL_ACS_MIS..ACCOUNTDATA WHERE  SOURCESYSTEMNAME='ECFS'



IF OBJECT_ID('TEMPDB..#TEMPTABLECUSTOMERACID869') IS NOT  NULL 
   DROP TABLE #TEMPTABLECUSTOMERACID869

SELECT ACCOUNTID CUSTOMERACID INTO #TEMPTABLECUSTOMERACID869 FROM  #TEMPTABLECUSTOMERACIDCUSTOMER869 A
INNER JOIN YBL_ACS_MIS..ACCOUNTDATA B ON A.FCR_CUSTOMERID=B.FCR_CUSTOMERID
 AND B.PRODUCTCODE='869'
EXCEPT 
SELECT CUSTOMERACID FROM PRO.ACCOUNTMASTER WHERE EFFECTIVETOTIMEKEY=49999


INSERT INTO PRO.ACCOUNTMASTER
(CUSTOMERACID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT CUSTOMERACID,@TIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TEMPTABLECUSTOMERACID869


/*-----------NEW ACCOUNT DATA INSERT MUREX-----------------*/


IF OBJECT_ID('TEMPDB..#TempTableCustomerAcidMUREX') is not  null 
   DROP TABLE #TempTableCustomerAcidMUREX

--SELECT 'INV'+CAST(TrnInternalTradeNo AS varchar(50)) CustomerAcid into #TempTableCustomerAcidMUREX 
--FROM YBL_ACS_MIS..ODS_MUREX_DPD_NPA
--EXCEPT 
--SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999

SELECT CAST(TrnInternalTradeNo AS varchar(50)) CustomerAcid into #TempTableCustomerAcidMUREX 
FROM YBL_ACS_MIS..ODS_MUREX_DPD_NPA
where ( FCC_CustomerID <>'')
EXCEPT 
SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999

INSERT INTO PRO.AccountMaster
(CustomerAcid,EffectiveFromTimekey,EffectiveToTimekey)
SELECT CustomerAcid,@TIMEKEY,49999 FROM  #TempTableCustomerAcidMUREX 



/*-----------NEW ACCOUNT DATA ECBF------------------*/


 update b set CustomerAcid=a.AccountID
 from YBL_ACS_MIS..AccountData a
inner join YBL_ACS_MIS..ODS_ECBF_BORROWERMST b 
on a.FCR_CustomerID=b.Ubscustomerid
 where ProductCode='605'
 and b.CustomerAcid is null

IF OBJECT_ID('TEMPDB..#TempTableCustomerAcidECBF') is not  null 
   DROP TABLE #TempTableCustomerAcidECBF
   --After discussion with team mapping change to borrowerID to CustomerAcid

--SELECT distinct A.borrowerID CustomerAcid into #TempTableCustomerAcidECBF    
SELECT distinct A.CustomerAcid CustomerAcid into #TempTableCustomerAcidECBF    
--FROM YBL_ACS_MIS.[dbo].[ODS_ECBF_BORROWERMST] 
from YBL_ACS_MIS.[DBO].[ODS_ECBF_BORROWERMST]  A
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBMST B ON A.borrowerID=B.borrowerID
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONREF C ON B.lbid=C.lbid
INNER JOIN YBL_ACS_MIS.dbo.ODS_ECBF_LBWHRVALUATIONMST D ON D.WHRNUMBER=C.WHRNUMBER 
AND D.WHRCLOSEFLAG<>1  INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_LBLOANPROCESSREF E ON E.WHRINWARDID=D.WHRINWARDID
EXCEPT 
SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999

INSERT INTO PRO.AccountMaster
(CustomerAcid,EffectiveFromTimekey,EffectiveToTimekey)
SELECT CustomerAcid,@TIMEKEY,49999 FROM  #TempTableCustomerAcidECBF 





IF OBJECT_ID('TEMPDB..#TempTableCustomerACIDEXPIRE') IS  NOT NULL
    DROP TABLE #TempTableCustomerACIDEXPIRE

SELECT CustomerAcid INTO #TempTableCustomerACIDEXPIRE FROM #TempTableCustomerAcidMUREX
UNION ALL
SELECT CUSTOMERACID FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999 
UNION ALL
SELECT CUSTOMERACID FROM #TempTableCustomerAcidECBF



-----------NON FUNDED Account DATA 06/01/2022-------

----IF OBJECT_ID('TEMPDB..#TempTableCustomerAcidNF') is not  null 
----   DROP TABLE #TempTableCustomerAcidNF

----SELECT DISTINCT AccountID CustomerAcid into #TempTableCustomerAcidNF FROM YBL_ACS_MIS..AccountData_NF 

----EXCEPT 
----SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999


----INSERT INTO PRO.ACCOUNTMASTER
----(CUSTOMERACID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
----SELECT CUSTOMERACID,@TIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerAcidNF




-------CRED Account DATA 19/01/2022-------

IF OBJECT_ID('TEMPDB..#TempTableCustomerAcidCRED') is not  null 
   DROP TABLE #TempTableCustomerAcidCRED

SELECT DISTINCT AccountID CustomerAcid into #TempTableCustomerAcidCRED FROM YBL_ACS_MIS..AccountData_CA 

EXCEPT 
SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999


INSERT INTO PRO.ACCOUNTMASTER
(CUSTOMERACID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT CUSTOMERACID,@TIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerAcidCRED


/*-------INSERT DATA FOR SFIN 15102023---------------------------------*/

IF OBJECT_ID('TEMPDB..#TempTableCustomerAcidSFIN') is not  null 
   DROP TABLE #TempTableCustomerAcidSFIN

SELECT DISTINCT ContractRefNo CustomerAcid into #TempTableCustomerAcidSFIN FROM YBL_ACS_MIS..AccountData_FinSmart 
EXCEPT 
SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999


INSERT INTO PRO.ACCOUNTMASTER
(CUSTOMERACID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT CUSTOMERACID,@TIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerAcidSFIN

/*-------INSERT DATA FOR SFIN 15102023---------------------------------*/


IF OBJECT_ID('TEMPDB..#TempTableCustomerAcidMissingECFS') is not  null 
   DROP TABLE #TempTableCustomerAcidMissingECFS

SELECT DISTINCT ContractRefNo CustomerAcid into #TempTableCustomerAcidMissingECFS FROM  YBL_ACS_MIS.dbo.accountdata where sourcesystemname='ECFS' 
EXCEPT 
SELECT CustomerAcid FROM PRO.AccountMaster WHERE EffectiveToTimekey=49999


INSERT INTO PRO.ACCOUNTMASTER
(CUSTOMERACID,EFFECTIVEFROMTIMEKEY,EFFECTIVETOTIMEKEY)
SELECT CUSTOMERACID,@TIMEKEY,49999 EFFECTIVETOTIMEKEY FROM #TempTableCustomerAcidMissingECFS


------/*------EXPIRE OLD DATA-----------------*/

------UPDATE A SET A.EffectiveToTimekey=@TIMEKEY-1
------FROM PRO.AccountMaster A LEFT OUTER JOIN  #TempTableCustomerACIDEXPIRE  B 
------ON A.CustomerAcid=B.CustomerAcid
------WHERE B.CustomerAcid IS NULL AND A.EffectiveToTimekey=49999


/*----NEW UCIFID  DATA INSERT --------------------*/

IF OBJECT_ID('TEMPDB..#TempTableUCIFID') is not  null 
   DROP TABLE #TempTableUCIFID

select distinct b.UCIC_ID  UCIFID into #TempTableUCIFID from PRO.CustomerMaster a inner join YBL_ACS_MIS..CustomerData b
 on a.SourceCustomerID=b.SourceSystemCustomerID and b.UCIC_ID is not null
 EXCEPT 
SELECT UCIFID FROM PRO.UcifidMaster WHERE EffectiveToTimekey=49999

insert into pro.UcifidMaster
(UCIFID,EffectiveFromTimekey,EffectiveToTimekey)
select UCIFID,@TIMEKEY,49999 EffectiveToTimekey from #TempTableUCIFID



---------NON FUNDED UCIFID DATA 06/01/2022-------

--IF OBJECT_ID('TEMPDB..#TempTableUCIFIDNF') is not  null 
--   DROP TABLE #TempTableUCIFIDNF

--SELECT DISTINCT UCIF UCIFID into #TempTableUCIFIDNF FROM YBL_ACS_MIS..AccountData_NF 

--EXCEPT 
--SELECT UCIFID FROM pro.UcifidMaster WHERE EffectiveToTimekey=49999


--insert into pro.UcifidMaster
--(UCIFID,EffectiveFromTimekey,EffectiveToTimekey)
--select UCIFID,@TIMEKEY,49999 EffectiveToTimekey from #TempTableUCIFIDNF



IF OBJECT_ID('TEMPDB..#TempTableUCIFIDCREDF') is not  null 
   DROP TABLE #TempTableUCIFIDCREDF

SELECT DISTINCT UCIC_ID UCIFID into #TempTableUCIFIDCREDF FROM YBL_ACS_MIS..CustomerData_CA   where UCIC_ID is not null


EXCEPT 
SELECT UCIFID FROM pro.UcifidMaster WHERE EffectiveToTimekey=49999


insert into pro.UcifidMaster
(UCIFID,EffectiveFromTimekey,EffectiveToTimekey)
select UCIFID,@TIMEKEY,49999 EffectiveToTimekey from #TempTableUCIFIDCREDF


Delete from PRO.UcifidMaster where UCIFID='0'

----UPDATE F SET EFFECTIVETOTIMEKEY=@TIMEKEY-1
----FROM YBL_ACS_MIS.[DBO].[ODS_ECBF_BORROWERMST]  A
----INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_LBMST B ON A.BORROWERID=B.BORROWERID
----INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_LBWHRVALUATIONREF C ON B.LBID=C.LBID
----INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_LBWHRVALUATIONMST D ON D.WHRNUMBER=C.WHRNUMBER 
----AND D.WHRCLOSEFLAG=1  INNER JOIN YBL_ACS_MIS.DBO.ODS_ECBF_LBLOANPROCESSREF E ON E.WHRINWARDID=D.WHRINWARDID 
----AND A.CUSTOMERACID IS NOT NULL
----INNER JOIN YBL_ACS.PRO.ACCOUNTMASTER F ON F.CUSTOMERACID=A.CUSTOMERACID
----WHERE F.EFFECTIVETOTIMEKEY=49999 

------/*------EXPIRE DATA FOR UCIFID---------------------*/
------UPDATE A SET A.EffectiveToTimekey=@TIMEKEY-1
------FROM PRO.UcifidMaster A LEFT OUTER JOIN  
------(
------select b.UCIC_ID  UCIFID  from PRO.CustomerMaster a inner join YBL_ACS_MIS..CustomerData b
------ on a.SourceCustomerID=b.SourceSystemCustomerID and b.UCIC_ID is not null
------) C 
------ON A.UCIFID=C.UCIFID
------WHERE C.UCIFID IS NULL AND A.EffectiveToTimekey=49999

;WITH CUSTOMERMASTER_CTE AS  
(  
   SELECT *, ROW_NUMBER() over (PARTITION BY SourceCustomerID ORDER BY SourceCustomerID) as abc  
   FROM PRO.CUSTOMERMASTER where Effectivetotimekey=49999
)  
DELETE FROM CUSTOMERMASTER_CTE WHERE abc >1


    DROP TABLE #TempTableCustomerID
	DROP TABLE #TempTableCustomerIDMUREX
	DROP TABLE #TempTableCustomerIDECBF
	DROP TABLE #TempTableCustomerAcid
	DROP TABLE #TEMPTABLECUSTOMERACIDCUSTOMER869
	DROP TABLE #TEMPTABLECUSTOMERACID869
	DROP TABLE #TempTableCustomerAcidMUREX
	DROP TABLE #TempTableCustomerAcidECBF
	DROP TABLE #TempTableCustomerACIDEXPIRE
	DROP TABLE #TempTableUCIFID
	DROP TABLE #tempcustomer    ----12-Feb-2021

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for Customer_Account_Ucif_Id_Masterkey_Generation'


END TRY
BEGIN CATCH
   SELECT  'ERROR MESSAGE :'+ERROR_MESSAGE()+'ERROR PROCEDURE: '+ERROR_PROCEDURE();
END CATCH
END










GO