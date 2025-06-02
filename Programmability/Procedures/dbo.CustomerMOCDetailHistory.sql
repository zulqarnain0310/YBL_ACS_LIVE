SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CustomerMOCDetailHistory]
@CustomerEntityId  INT=0
,@OperationFlag    INT=1
,@UserId	   VARCHAR(50)=''
,@TimeKey		   INT=0
,@RefCustomerID  VARCHAR(50)=''
AS
BEGIN

			SET @TIMEKEY =25141
	

			SELECT 
			CustomerEntityId
			,BankAssetClass
			,RefCustomerID
			,SysAssetClassAlt_Key
			,convert(varchar(20), SysNPA_Dt,103) SysNPA_Dt
			,isnull(CurntQtrRv,0) AS   CurntQtrRv
			,AddlProvisionPer
			,MOCReason
			,'CustomerData' TableName
			 from pro.customercal_hist  A

			WHERE (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY) AND RefCustomerID=@RefCustomerID
			
			
			
END


GO