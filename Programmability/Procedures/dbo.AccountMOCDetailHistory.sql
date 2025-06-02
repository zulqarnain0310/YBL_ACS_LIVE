SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AccountMOCDetailHistory]
@AccountEntityId  INT=0
,@OperationFlag    INT=1
,@UserId	   VARCHAR(50)=''
,@TimeKey		   INT=0
,@CustomerAcID  VARCHAR(50)=''
AS
BEGIN

			SET @TIMEKEY =25141
			

			SELECT 
			ACC.AccountEntityId
			,CustomerAcID
			,FacilityType
			,ActSegmentCode
			,Balance	Balance
			,AddlProvisionPer	AddlProvisionPer
			,AddlProvision	AddlProvision
			,SecApp  	SecApp
			,FlgFITL	FlgFITL
			,DFVAmt	DFVAmt
			,convert(varchar(20),RepossessionDate,103)	RepossessionDate
			,convert(varchar(20),RestructureDt,103)	RestructureDt
			,convert(varchar(20),OriginalEnvisagCompletionDt,103)	OriginalEnvisagCompletionDt
			,convert(varchar(20),ActualCompletionDt,103)	ActualCompletionDt
			,convert(varchar(20),RevisedCompletionDt,103)	RevisedCompletionDt

			,'AccountList' TableName
			 from pro.accountcal_hist ACC
			 LEFT OUTER JOIN curdat.AdvAcRestructureDetail RES ON ACC.CustomerAcID=RES.RefSystemAcId
			 LEFT OUTER JOIN AdvAcProjectDetail PRO ON ACC.CustomerAcID=RES.RefSystemacid

			 WHERE (ACC.EffectiveFromTimeKey<=@TIMEKEY AND ACC.EffectiveToTimeKey>=@TIMEKEY) AND ACC.CustomerAcID=@CustomerAcID
END


GO