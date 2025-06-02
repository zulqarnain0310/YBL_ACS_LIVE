SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[RefPeriodMasterSearchList]
--Declare
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 17
													 ,@MenuID  INT  =24736
AS
 
 ---select AuthLevel,* from SysCRisMacMenu where MenuCaption like '%Source%'    
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					
Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID
 --SET @Authlevel=2
BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT A.Rule_Key,
							A.RuleAlt_Key,
							A.SourceAlt_Key,
							A.BusinessRule,
							A.SourceSysName,
							A.IRACParameter,
							A.DPD,
							A.ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							A.AuthorisationStatus,
							A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changefields
                 INTO #temp
                 FROM 
                 (
                     SELECT A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceSystemAlt_Key as SourceAlt_Key,
							B.SourceName as SourceSysName,
							A.IRACParameter,
							A.RefValue as DPD,
							A.RefUnit as ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
							Case when  isnull(A.AuthorisationStatus, 'A')='A' THen 'Authorized'
							when  isnull(A.AuthorisationStatus, 'A') in ('NP','MP','FM','1A') THen 'Pending Authorisation'
							--when  isnull(A.AuthorisationStatus, 'A')='MP' THen 'Modified Pending'
							--when  isnull(A.AuthorisationStatus, 'A')='FM' THen 'Further Modified'
							--when  isnull(A.AuthorisationStatus, 'A')='R' THen 'Reject'
							--when  isnull(A.AuthorisationStatus, 'A')='1A' THen 'First Authorized'
							ENd AS AuthorisationStatusName,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
								, '' as changefields
                     FROM Pro.RefPeriod A
					 Inner Join DimSourceDB B ON A.SourceSystemAlt_Key=B.SourceAlt_Key
					 And B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND A.BusinessRule In (
						   
					'AadharCard','ACCOUNTSTATUS_FCC_181','ACCOUNTSTATUS_FCC_366'
					,'ACCOUNTSTATUS_FCR_181','ACCOUNTSTATUS_FCR_366','AcParam1','AcParam2'
					,'AcParam3','CustParam1','CustParam2','DB1_Days','DB1_Months','DB2_Days'
					,'DB2_Months','DebitSinceDate','FacilityType','FINNONE365','FINNONE366'
					,'FINNONE730','FINNONE90','FINNONE91','FLGLCBG_FCC_91','FLGLCBG_FCR_91'
					,'Individual Farmer','InttServicingModel','Joint Account','Joint Liability Group-Member'
					,'Joint Liability Group-Representative','LineCode_FCC_181','LineCode_FCC_366','LineCode_FCR_181'
					,'LineCode_FCR_366','LookBackPeriod','MoveToDB1','MoveToLoss','Other than Individuals OTC'
					,'Other than Individuals','PanCardNO','PROC_CONDITION','PROC_FREQ','PROV_FREQ','QtrFirstMonth'
					,'RecoveryAdjustment','RefPeriodAgr366','RefPeriodAgr456','RefPeriodAgr731','RefPeriodIntService'
					,'RefPeriodIntServiceUpg','RefPeriodNoCredit','RefPeriodNoCreditUpg','RefPeriodOverDrawn','RefPeriodOverDrawnUpg'
					,'RefPeriodOverdue','RefPeriodOverdueUpg','RefPeriodReview','RefPeriodReviewUpg','RefPeriodStkStatement'
					,'RefPeriodStkStatementUpg','SUB_Days','SUB_Months','UCFIC','UPG_FREQ'
						   )

                     UNION
                     SELECT A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceSystemAlt_Key as SourceAlt_Key,
							B.SourceName as SourceSysName,
							A.IRACParameter,
							A.RefValue as DPD,
							A.RefUnit as ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
							Case when  isnull(A.AuthorisationStatus, 'A')='A' THen 'Authorized'
							when  isnull(A.AuthorisationStatus, 'A') in ('NP','MP','FM','1A') THen 'Pending Authorisation'
							--when  isnull(A.AuthorisationStatus, 'A')='MP' THen 'Modified Pending'
							--when  isnull(A.AuthorisationStatus, 'A')='FM' THen 'Further Modified'
							--when  isnull(A.AuthorisationStatus, 'A')='R' THen 'Reject'
							--when  isnull(A.AuthorisationStatus, 'A')='1A' THen 'First Authorized'
							ENd AS AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,a.Changefields
                     FROM Pro.RefPeriod_Mod A
					 Inner Join DimSourceDB B ON A.SourceSystemAlt_Key=B.SourceAlt_Key
					 And B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
						   AND A.BusinessRule In (
						   
						   'AadharCard','ACCOUNTSTATUS_FCC_181','ACCOUNTSTATUS_FCC_366'
					,'ACCOUNTSTATUS_FCR_181','ACCOUNTSTATUS_FCR_366','AcParam1','AcParam2'
					,'AcParam3','CustParam1','CustParam2','DB1_Days','DB1_Months','DB2_Days'
					,'DB2_Months','DebitSinceDate','FacilityType','FINNONE365','FINNONE366'
					,'FINNONE730','FINNONE90','FINNONE91','FLGLCBG_FCC_91','FLGLCBG_FCR_91'
					,'Individual Farmer','InttServicingModel','Joint Account','Joint Liability Group-Member'
					,'Joint Liability Group-Representative','LineCode_FCC_181','LineCode_FCC_366','LineCode_FCR_181'
					,'LineCode_FCR_366','LookBackPeriod','MoveToDB1','MoveToLoss','Other than Individuals OTC'
					,'Other than Individuals','PanCardNO','PROC_CONDITION','PROC_FREQ','PROV_FREQ','QtrFirstMonth'
					,'RecoveryAdjustment','RefPeriodAgr366','RefPeriodAgr456','RefPeriodAgr731','RefPeriodIntService'
					,'RefPeriodIntServiceUpg','RefPeriodNoCredit','RefPeriodNoCreditUpg','RefPeriodOverDrawn','RefPeriodOverDrawnUpg'
					,'RefPeriodOverdue','RefPeriodOverdueUpg','RefPeriodReview','RefPeriodReviewUpg','RefPeriodStkStatement'
					,'RefPeriodStkStatementUpg','SUB_Days','SUB_Months','UCFIC','UPG_FREQ'
						   )

                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Pro.RefPeriod_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY RuleAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceAlt_Key,
							A.SourceSysName,
							A.IRACParameter,
							A.DPD,
							A.ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							A.AuthorisationStatus,
							A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
      A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changefields

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RuleAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ReperidMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			 IF(@OperationFlag in (16,17))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceAlt_Key,
							A.SourceSysName,
							A.IRACParameter,
							A.DPD,
							A.ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							A.AuthorisationStatus,
							A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changefields
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceSystemAlt_Key as SourceAlt_Key,
							B.SourceName as SourceSysName,
							A.IRACParameter,
							A.RefValue as DPD,
							A.RefUnit as ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
							Case when  isnull(A.AuthorisationStatus, 'A')='A' THen 'Authorized'
							when  isnull(A.AuthorisationStatus, 'A') in ('NP','MP','FM','1A') THen 'Pending Authorisation'
							--when  isnull(A.AuthorisationStatus, 'A')='MP' THen 'Modified Pending'
							--when  isnull(A.AuthorisationStatus, 'A')='FM' THen 'Further Modified'
							--when  isnull(A.AuthorisationStatus, 'A')='R' THen 'Reject'
							--when  isnull(A.AuthorisationStatus, 'A')='1A' THen 'First Authorized'
							ENd AS AuthorisationStatusName,
							A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
	                          ,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
	                          ,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
	                          ,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
	                          ,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate

									,a.Changefields
                     FROM Pro.RefPeriod_Mod A
					 Inner Join DimSourceDB B ON A.SourceSystemAlt_Key=B.SourceAlt_Key
					 And B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
						   AND A.BusinessRule In (
						   'AadharCard','ACCOUNTSTATUS_FCC_181','ACCOUNTSTATUS_FCC_366'
					,'ACCOUNTSTATUS_FCR_181','ACCOUNTSTATUS_FCR_366','AcParam1','AcParam2'
					,'AcParam3','CustParam1','CustParam2','DB1_Days','DB1_Months','DB2_Days'
					,'DB2_Months','DebitSinceDate','FacilityType','FINNONE365','FINNONE366'
					,'FINNONE730','FINNONE90','FINNONE91','FLGLCBG_FCC_91','FLGLCBG_FCR_91'
					,'Individual Farmer','InttServicingModel','Joint Account','Joint Liability Group-Member'
					,'Joint Liability Group-Representative','LineCode_FCC_181','LineCode_FCC_366','LineCode_FCR_181'
					,'LineCode_FCR_366','LookBackPeriod','MoveToDB1','MoveToLoss','Other than Individuals OTC'
					,'Other than Individuals','PanCardNO','PROC_CONDITION','PROC_FREQ','PROV_FREQ','QtrFirstMonth'
					,'RecoveryAdjustment','RefPeriodAgr366','RefPeriodAgr456','RefPeriodAgr731','RefPeriodIntService'
					,'RefPeriodIntServiceUpg','RefPeriodNoCredit','RefPeriodNoCreditUpg','RefPeriodOverDrawn','RefPeriodOverDrawnUpg'
					,'RefPeriodOverdue','RefPeriodOverdueUpg','RefPeriodReview','RefPeriodReviewUpg','RefPeriodStkStatement'
					,'RefPeriodStkStatementUpg','SUB_Days','SUB_Months','UCFIC','UPG_FREQ'
						   )

                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Pro.RefPeriod_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY RuleAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceAlt_Key,
							A.SourceSysName,
							A.IRACParameter,
							A.DPD,
							A.ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							A.AuthorisationStatus,
							A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changefields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RuleAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ReperidMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   ELSE
  
   IF(@OperationFlag in (20))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceAlt_Key,
							A.SourceSysName,
							A.IRACParameter,
							A.DPD,
							A.ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							A.AuthorisationStatus,
							A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changefields
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceSystemAlt_Key as SourceAlt_Key,
							B.SourceName as SourceSysName,
							A.IRACParameter,
							A.RefValue as DPD,
							A.RefUnit as ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
							Case when  isnull(A.AuthorisationStatus, 'A')='A' THen 'Authorized'
							when  isnull(A.AuthorisationStatus, 'A') in ('NP','MP','FM','1A') THen 'Pending Authorisation'
							--when  isnull(A.AuthorisationStatus, 'A')='MP' THen 'Modified Pending'
							--when  isnull(A.AuthorisationStatus, 'A')='FM' THen 'Further Modified'
							--when  isnull(A.AuthorisationStatus, 'A')='R' THen 'Reject'
							--when  isnull(A.AuthorisationStatus, 'A')='1A' THen 'First Authorized'
							ENd AS AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
	                          ,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
	                          ,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
	                          ,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
	                          ,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
									,a.Changefields
                     FROM Pro.RefPeriod_Mod A
					 Inner Join DimSourceDB B ON A.SourceSystemAlt_Key=B.SourceAlt_Key
					 And B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
						   AND A.BusinessRule In (
						   
						   'AadharCard','ACCOUNTSTATUS_FCC_181','ACCOUNTSTATUS_FCC_366'
					,'ACCOUNTSTATUS_FCR_181','ACCOUNTSTATUS_FCR_366','AcParam1','AcParam2'
					,'AcParam3','CustParam1','CustParam2','DB1_Days','DB1_Months','DB2_Days'
					,'DB2_Months','DebitSinceDate','FacilityType','FINNONE365','FINNONE366'
					,'FINNONE730','FINNONE90','FINNONE91','FLGLCBG_FCC_91','FLGLCBG_FCR_91'
					,'Individual Farmer','InttServicingModel','Joint Account','Joint Liability Group-Member'
					,'Joint Liability Group-Representative','LineCode_FCC_181','LineCode_FCC_366','LineCode_FCR_181'
					,'LineCode_FCR_366','LookBackPeriod','MoveToDB1','MoveToLoss','Other than Individuals OTC'
					,'Other than Individuals','PanCardNO','PROC_CONDITION','PROC_FREQ','PROV_FREQ','QtrFirstMonth'
					,'RecoveryAdjustment','RefPeriodAgr366','RefPeriodAgr456','RefPeriodAgr731','RefPeriodIntService'
					,'RefPeriodIntServiceUpg','RefPeriodNoCredit','RefPeriodNoCreditUpg','RefPeriodOverDrawn','RefPeriodOverDrawnUpg'
					,'RefPeriodOverdue','RefPeriodOverdueUpg','RefPeriodReview','RefPeriodReviewUpg','RefPeriodStkStatement'
					,'RefPeriodStkStatementUpg','SUB_Days','SUB_Months','UCFIC','UPG_FREQ'
						   )

                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Pro.RefPeriod_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               --AND ISNULL(AuthorisationStatus, 'A') IN('1A')
							 AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY RuleAlt_Key
                    )
                 ) A 
                      
                 
                 GROUP BY A.Rule_Key,
							A.RuleAlt_Key,
							A.BusinessRule,
							A.SourceAlt_Key,
							A.SourceSysName,
							A.IRACParameter,
							A.DPD,
							A.ReferenceUnit,
							A.Grade,
							A.RuleType,
							A.BusienssRuleName,
							A.ColumnName,
							A.LogicSql,
							A.AuthorisationStatus,
							A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changefields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RuleAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ReperidMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)
END

   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH

	--SELECT *, 'DimSourceSysMaster' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='ReperidMaster' and  MenuId=24736
  
  
    END;


GO