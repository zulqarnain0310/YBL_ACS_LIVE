SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 08-Jan-2021
MODIFY DATE : 
DESCRIPTION : PRO.overduedata_component

============================================*/

CREATE PROCEDURE [pro].[Inserdataintooverduedata_component]
AS
BEGIN

  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @Date DATE =(SELECT CAST(EndDate AS DATE) FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
  DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

  INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'INSERT DATA FOR Inserdataintooverduedata_component','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

  DELETE FROM  [PRO].[OverDueData_Component] where DateOfData= @Date

  INSERT INTO [PRO].[OverDueData_Component]
  (
 
[AccountEntityID] ,
[UcifEntityID] ,
[CustomerEntityID] ,
[LiabilityId] ,
[RefCustomerID],
[CustomerAcID] ,
[CurrencyCode] ,
[OverdueComponent] ,
[Dpd] ,
[OverDueSinceDt] ,
[OverdueAmountDue] ,
[OverdueAmountSettled] ,
[DpdAmountContractCurrency] ,
[DpdAmountLcy] ,
[RegionName] ,
[ClusterName] ,
[LiabilityName] ,
[CustomerName] ,
[SegmentCode] ,
[RmCode] ,
[ProductDescription] ,
[BranchCode1] ,
[CustomerRating],
[RmName] ,
[TlCode] ,
[TlName] ,
[BusinessSegment] ,
[PSCode] ,
[BranchCode] ,
[BranchName] ,
[LiabilityRmCode] ,
[AssetRmCode] ,
[BusinessTlSegment] ,
[IndustrySegment] ,
[UCIF_ID],
[PANNO] ,
[DateOfData] ,
[EffectiveFromTimeKey] ,
[EffectiveToTimeKey] 
)

select 
[AccountEntityID] ,
 [UcifEntityID] ,
 [CustomerEntityID],
[liab_id] ,
[cust_id] ,
[contract_ref_no] ,
[currency] ,
[component] ,
[days_dpd] ,
[due_date] ,
[amount_due] ,
[amount_settled] ,
[dpd_amt_contract_ccy] ,
[dpd_amt_lcy] ,
[region] ,
[clusters] ,
[liab_name] ,
[cust_name] ,
[segment] ,
[rm_code] ,
[product_class] ,
[branch_code] ,
[borrower_rating] ,
[rmname] ,
[tl_code] ,
[tl_name] ,
[bs] ,
[ps] ,
[branch] ,
[branch_name] ,
[liab_rm_code] ,
[asset_rm_code] ,
[business_tl_seg] ,
[industry_segment] ,
[ucic] ,
[pan_no] ,
@Date,
@TIMEKEY,
@TIMEKEY

from YBL_ACS_MIS.[dbo].[MV_LDM_FCC_OVERDUE] A INNER JOIN PRO.ACCOUNTCAL B ON A.contract_ref_no=B.CustomerAcID

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR'))
 AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='INSERT DATA FOR Inserdataintooverduedata_component'

  	END 


GO