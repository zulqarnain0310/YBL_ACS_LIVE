SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE procedure [pro].[InsertDataINTOHIST_TABLE]
@TIMEKEY int
with recompile
as
begin


DECLARE @DataBase varchar(10)='YBL_ACS_'
DECLARE @Year varchar(10) = (SELECT left(EndDate,4) 
FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y' ) 
DECLARE @TableName varchar(50)='.dbo.CustomerCal_Main_' 
DECLARE @Month varchar(10) = (SELECT LEFT(datename(MM,StartDate),3)FROM PRO.EXTDATE_MISDB a 
WHERE FLG = 'Y' )
DECLARE @DerivedTable VARCHAR(100) =@DataBase+''+@Year+''+''+@TableName+''+@Year+'_'+@Month 
SELECT @DerivedTable
Declare @InsertSQL Varchar(Max),@DeleteSQL Varchar(Max)

 IF EXISTS(SELECT 1 FROM Pro.ProcessingTableStatus WHERE CurrentTimekey=@TIMEKEY and TableName='CustomerCal_Hist')
 BEGIN
	   SET @DeleteSQL='DELETE  FROM  '+@DerivedTable+ ' WHERE EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY'
	   EXEC (@DeleteSQL)
	   DELETE  FROM  [PRO].[ProcessingTableStatus] WHERE CurrentTimekey=@TIMEKEY AND TableName='CustomerCal_Hist'
 END
SET @InsertSQL ='INSERT INTO '+ @DerivedTable+ 
' (
EntityKey
,BranchCode
,UCIF_ID
,UcifEntityID
,CustomerEntityID
,ParentCustomerID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,CustSegmentCode
,ConstitutionAlt_Key
,PANNO
,AadharCardNO
,SrcAssetClassAlt_Key
,SysAssetClassAlt_Key
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,SMA_Class_Key
,PNPA_Class_Key
,PrvQtrRV
,CurntQtrRv
,TotProvision
,BankTotProvision
,RBITotProvision
,SrcNPA_Dt
,SysNPA_Dt
,DbtDt
,DbtDt2
,DbtDt3
,LossDt
,MOC_Dt
,ErosionDt
,SMA_Dt
,PNPA_Dt
,ProcessingDt
,Asset_Norm
,FlgDeg
,FlgUpg
,FlgMoc
,FlgSMA
,FlgProcessing
,FlgErosion
,FlgPNPA
,FlgPercolation
,FlgInMonth
,FlgDirtyRow
,DegDate
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CommonMocTypeAlt_Key
,InMonthMark
,MocStatusMark
,SourceAlt_Key
,BankAssetClass
,Cust_Expo
,MOCReason
,AddlProvisionPer
,FraudDt
,FraudAmount
,DegReason
,IMAXID_CCube
,DateOfData
,CustMoveDescription
,TotOsCust
,MOCTYPE
,CustomerPartnerSegment

)
select 
EntityKey
,BranchCode
,UCIF_ID
,UcifEntityID
,CustomerEntityID
,ParentCustomerID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,CustSegmentCode
,ConstitutionAlt_Key
,PANNO
,AadharCardNO
,SrcAssetClassAlt_Key
,SysAssetClassAlt_Key
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,SMA_Class_Key
,PNPA_Class_Key
,PrvQtrRV
,CurntQtrRv
,TotProvision
,BankTotProvision
,RBITotProvision
,SrcNPA_Dt
,SysNPA_Dt
,DbtDt
,DbtDt2
,DbtDt3
,LossDt
,MOC_Dt
,ErosionDt
,SMA_Dt
,PNPA_Dt
,ProcessingDt
,Asset_Norm
,FlgDeg
,FlgUpg
,FlgMoc
,FlgSMA
,FlgProcessing
,FlgErosion
,FlgPNPA
,FlgPercolation
,FlgInMonth
,FlgDirtyRow
,DegDate
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CommonMocTypeAlt_Key
,InMonthMark
,MocStatusMark
,SourceAlt_Key
,BankAssetClass
,Cust_Expo
,MOCReason
,AddlProvisionPer
,FraudDt
,FraudAmount
,DegReason
,IMAXID_CCube
,DateOfData
,CustMoveDescription
,TotOsCust
,MOCTYPE
,CustomerPartnerSegment

 from pro.CustomerCal'

 EXEC (@InsertSQL)

--UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
--	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
--	WHERE RUNNINGPROCESSNAME='InsertDataIntoHistTable' 

INSERT INTO [PRO].[ProcessingTableStatus]
           ([TableName]
           ,[CurrentTimekey]
		   )
     VALUES
           ('CustomerCal_Hist'
           ,@TIMEKEY
		   )
end







GO