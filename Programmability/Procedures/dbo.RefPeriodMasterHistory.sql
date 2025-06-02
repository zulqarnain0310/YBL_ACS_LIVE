SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[RefPeriodMasterHistory]
@RuleAlt_Key INt
						--@SourceAlt_Key Int

AS
	BEGIN

	
			Select A.Rule_Key,
					A.RuleAlt_Key,
					A.BusinessRule,
					A.SourceSystemAlt_Key as SourceAlt_Key,
					B.SourceName as SourceSysName,
					A.IRACParameter,
					A.RefValue as DPD,
					A.RefUnit as ReferenceUnit,
					A.Grade,
					A.CreatedBy, 
					Convert(Varchar(20),A.DateCreated,103) DateCreated,
					A.ApprovedBy, 
					Convert(Varchar(20),A.DateApproved,103) DateApproved,
					A.ModifiedBy, 
					Convert(Varchar(20),A.DateModified,103) DateModified
					FROM Pro.RefPeriod A
					 Inner Join DimSourceDB B ON A.SourceSystemAlt_Key=B.SourceAlt_Key And B.EffectiveToTimeKey=49999
					 
					 WHERE A.RuleAlt_Key=@RuleAlt_Key
					-- And ISNULL(A.AuthorisationStatus,'A')='A'  -- commented for below changes
					 AND A.BusinessRule In (
					 'AadharCard','ACCOUNTSTATUS_FCC_181','ACCOUNTSTATUS_FCC_366'
					,'ACCOUNTSTATUS_FCR_181','ACCOUNTSTATUS_FCR_366','AcParam1','AcParam2'
					,'AcParam3','CustParam1','CustParam2','DB1_Days','DB1_Months','DB2_Days'
					,'DB2_Months','DebitSinceDate','FINNONE365','FINNONE366'
					,'FINNONE730','FINNONE90','FINNONE91','FLGLCBG_FCC_91','FLGLCBG_FCR_91'
					,'Individual Farmer','InttServicingModel','Joint Account','Joint Liability Group-Member'
					,'Joint Liability Group-Representative','LineCode_FCC_181','LineCode_FCC_366','LineCode_FCR_181'
					,'LineCode_FCR_366','LookBackPeriod','MoveToDB1','MoveToLoss','Other than Individuals OTC'
					,'Other than Individuals','PanCardNO','PROC_CONDITION','PROC_FREQ','PROV_FREQ','QtrFirstMonth'
					,'RecoveryAdjustment','RefPeriodAgr366','RefPeriodAgr456','RefPeriodAgr731','RefPeriodIntService'
					,'RefPeriodIntServiceUpg','RefPeriodNoCredit','RefPeriodNoCreditUpg','RefPeriodOverDrawn','RefPeriodOverDrawnUpg'
					,'RefPeriodOverdue','RefPeriodOverdueUpg','RefPeriodReview','RefPeriodReviewUpg','RefPeriodStkStatement'
					,'RefPeriodStkStatementUpg','SUB_Days','SUB_Months','UCFIC','UPG_FREQ','LookBackPeriodClass'
					 )

-------Below code added by omkar to show original entry of record-----------------------------------

					AND A.EntityKey IN
                     (
                         SELECT Min(EntityKey)
                         FROM Pro.RefPeriod
                         GROUP BY RuleAlt_Key
                     )
--------------------------------------------------------------------------------------------------------					
UNION ALL

			Select A.Rule_Key,
					A.RuleAlt_Key,
					A.BusinessRule,
					A.SourceSystemAlt_Key as SourceAlt_Key,
					B.SourceName as SourceSysName,
					A.IRACParameter,
					A.RefValue as DPD,
					A.RefUnit as ReferenceUnit,
					A.Grade,
					A.CreatedBy, 
					Convert(Varchar(20),A.DateCreated,103) DateCreated,
					A.ApprovedBy, 
					Convert(Varchar(20),A.DateApproved,103) DateApproved,
					A.ModifiedBy, 
					Convert(Varchar(20),A.DateModified,103) DateModified
					FROM Pro.RefPeriod_Mod A
					 Inner Join DimSourceDB B ON A.SourceSystemAlt_Key=B.SourceAlt_Key And B.EffectiveToTimeKey=49999
					 
					 WHERE A.RuleAlt_Key=@RuleAlt_Key
					 And ISNULL(A.AuthorisationStatus,'A')='A'-- in ('NP','MP','FM','1A','R')  --commented to show only authorised records
					 AND A.BusinessRule In (
					 'AadharCard','ACCOUNTSTATUS_FCC_181','ACCOUNTSTATUS_FCC_366'
					,'ACCOUNTSTATUS_FCR_181','ACCOUNTSTATUS_FCR_366','AcParam1','AcParam2'
					,'AcParam3','CustParam1','CustParam2','DB1_Days','DB1_Months','DB2_Days'
					,'DB2_Months','DebitSinceDate','FINNONE365','FINNONE366'
					,'FINNONE730','FINNONE90','FINNONE91','FLGLCBG_FCC_91','FLGLCBG_FCR_91'
					,'Individual Farmer','InttServicingModel','Joint Account','Joint Liability Group-Member'
					,'Joint Liability Group-Representative','LineCode_FCC_181','LineCode_FCC_366','LineCode_FCR_181'
					,'LineCode_FCR_366','LookBackPeriod','MoveToDB1','MoveToLoss','Other than Individuals OTC'
					,'Other than Individuals','PanCardNO','PROC_CONDITION','PROC_FREQ','PROV_FREQ','QtrFirstMonth'
					,'RecoveryAdjustment','RefPeriodAgr366','RefPeriodAgr456','RefPeriodAgr731','RefPeriodIntService'
					,'RefPeriodIntServiceUpg','RefPeriodNoCredit','RefPeriodNoCreditUpg','RefPeriodOverDrawn','RefPeriodOverDrawnUpg'
					,'RefPeriodOverdue','RefPeriodOverdueUpg','RefPeriodReview','RefPeriodReviewUpg','RefPeriodStkStatement'
					,'RefPeriodStkStatementUpg','SUB_Days','SUB_Months','UCFIC','UPG_FREQ','LookBackPeriodClass'
					 
					 )


	END

GO