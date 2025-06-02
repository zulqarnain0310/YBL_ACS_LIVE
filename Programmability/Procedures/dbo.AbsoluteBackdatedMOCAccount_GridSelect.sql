SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Shubham Mankame>
-- Create date: <23022024>
-- Description:	<Get Account ids>
-- =============================================
Create PROCEDURE [dbo].[AbsoluteBackdatedMOCAccount_GridSelect]
--Declare
@AccountID VARCHAR(50),
@OperationFlag int,
@Timekey int

AS

BEGIN

declare @LastMonthDateKey int = (Select LastMonthDateKey From YBL_ACS.DBO.SysDayMatrix Where TimeKey = @Timekey)
declare @LastMonthDate date = (Select LastMonthDate From YBL_ACS.DBO.SysDayMatrix Where TimeKey = @Timekey)

--Declare @YEAR VARCHAR(4) =(Select DATEPART(YEAR,@LastMonthDate))
--Declare @Month VARCHAR(3) = (Select CASE WHEN DATEPART(MONTH,@LastMonthDate) = 1 THEN 'JAN'
--            WHEN DATEPART(MONTH,@LastMonthDate) = 2 THEN 'FEB'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 3 THEN 'MAR'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 4 THEN 'APR'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 5 THEN 'MAY'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 6 THEN 'JUN'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 7 THEN 'JUL'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 8 THEN 'AUG'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 9 THEN 'SEP'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 10 THEN 'OCT'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 11 THEN 'NOV'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 12 THEN 'DEC'
--      END )


--IF OBJECT_ID('TEMPDB..##AccountCal_HIST') IS NOT NULL
--DROP TABLE ##AccountCal_HIST
--CREATE Table ##AccountCal_HIST(CustomerACID varchar(30),
--                               AccountEntityID int,
--							   BranchCode VARCHAR(20),
--							   TotalProvision DECIMAL(22,2),
--							   RefCustomerID VARCHAR(50),
--							   SourceSystemCustomerID VARCHAR(50),
--							   UCIF_ID VARCHAR(50),
--							   EffectiveFromTimeKey int,
--							   NetBalance DECIMAL(22,2))
--Declare @SQL Varchar(1000) = 'Select CustomerAcID,AccountEntityID,BranchCode,TotalProvision,RefCustomerID,SourceSystemCustomerID,UCIF_ID,EffectiveFromTimeKey,NetBalance From YBL_ACS_'+@Year+'.DBO.AccountCal_Main_'+@YEAR+'_'+@Month+' Where EffectiveFromTimeKey = '+CAST(@LastMonthDateKey as varchar(5))--+'AND FinalAssetClassAlt_Key <> 1' --Commented by shubham on 2024-04-11 since bank will pass provision for all accounts

--Select @SQL
--Insert into  ##AccountCal_HIST
--EXEC (@SQL) -- To be changed to DYNAMIC View Partioning
		 
        ---Added For Checker Initially Selecting NEW/MODIFED/DELETE Pending Records To be Authorized or Rejected
        If @OperationFlag in (16,17) 
        
        Begin 
        
             Select Convert(varchar,MOC_Date,103),a.CustomerACID,A.Branchcode,CustomerID,ExistingProvision,AdditionalProvision,FinalProvision,MOCREASON,NetBalance,CreatedBy,ModifyBy,ApprovedByLevel1,AuthorisationStatus,'AbsoluteProvisionList' as TableName --Added by Shubham on 2024-04-15 for addition of MOCREASON
             From YBL_ACS.DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
			 Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
             And ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
             --aND A.CustomerACID is not null
			 --left JOIN ##AccountCal_HIST b ON A.CustomerACID=B.CustomerACID
			 --aND b.EffectiveFromTimeKey<=@Timekey 

			 --Select Convert(varchar,MOC_Date,103),a.CustomerACID,a.Branchcode,CustomerID,ExistingProvision,AdditionalProvision,FinalProvision,MOCREASON,NetBalance,CreatedBy,ModifyBy,ApprovedByLevel1,AuthorisationStatus --Added by Shubham on 2024-04-15 for addition of MOCREASON --Commented by shubham on 2024-04-29 as changes made on frontend agasint single set of records required
    --         From YBL_ACS.DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
			 --Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
    --         And ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
			 --AND a.CustomerACID = @AccountID
             --aND A.CustomerACID is not null
			 --left JOIN ##AccountCal_HIST b ON A.CustomerACID=B.CustomerACID
			 --aND b.EffectiveFromTimeKey<=@Timekey 

        End
             
             ---Added For Maker Initially Selecting NEW/MODIFED/DELETE Pending Records From MOD and Authorized data from MAIN for CREATE/UPDATE/DELETE Operations
        ELSE 
        
        Begin 
             --Selecting NP/MP/DP Records From mod Table
             
             Select Convert(varchar,MOC_Date,103),a.CustomerACID,a.Branchcode,CustomerID,ExistingProvision,AdditionalProvision,FinalProvision,MOCREASON,NetBalance,CreatedBy,ModifyBy,ApprovedByLevel1,AuthorisationStatus,'AbsoluteProvisionList' as TableName  --Added by Shubham on 2024-04-15 for addition of MOCREASON
             From YBL_ACS.DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
			 Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
             And ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
			 --left JOIN ##AccountCal_HIST b ON A.CustomerACID=B.CustomerACID
             --aND A.CustomerACID is not null
			 --aND b.EffectiveFromTimeKey<=@Timekey 

             UNION 
             
             Select Convert(varchar,MOC_Date,103),a.CustomerACID,a.Branchcode,CustomerID,ExistingProvision,AdditionalProvision,FinalProvision,MOCREASON,NetBalance,CreatedBy,ModifyBy,ApprovedByLevel1,AuthorisationStatus,'AbsoluteProvisionList' as TableName --Added by Shubham on 2024-04-15 for addition of MOCREASON
			 From YBL_ACS.DATAUPLOAD.AbsoluteBackdatedMOC A
			 Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
             AND ISNULL(AuthorisationStatus,'A') IN ('A')
			 --left JOIN ##AccountCal_HIST b ON A.CustomerACID=B.CustomerACID
             --aND b.CustomerACID is not null
			 --aND b.EffectiveFromTimeKey<=@Timekey 
			 
			 --Select Convert(varchar,MOC_Date,103),a.CustomerACID,a.Branchcode,CustomerID,ExistingProvision,AdditionalProvision,FinalProvision,MOCREASON,NetBalance,CreatedBy,ModifyBy,ApprovedByLevel1,AuthorisationStatus  --Added by Shubham on 2024-04-15 for addition of MOCREASON --Commented by shubham on 2024-04-29 as changes made on frontend agasint single set of records required
    --         From YBL_ACS.DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
			 --where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
    --         And ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
			 --AND a.CustomerACID = @AccountID
			 ----left JOIN ##AccountCal_HIST b ON A.CustomerACID=B.CustomerACID
    --         --aND b.CustomerACID is not null
			 ----aND b.EffectiveFromTimeKey<=@Timekey 

    --         UNION 
             
    --         Select Convert(varchar,MOC_Date,103),a.CustomerACID,a.Branchcode,CustomerID,ExistingProvision,AdditionalProvision,FinalProvision,MOCREASON,NetBalance,CreatedBy,ModifyBy,ApprovedByLevel1,AuthorisationStatus --Added by Shubham on 2024-04-15 for addition of MOCREASON --Commented by shubham on 2024-04-29 as changes made on frontend agasint single set of records required
			 --From YBL_ACS.DATAUPLOAD.AbsoluteBackdatedMOC A
			 --Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
    --         AND ISNULL(AuthorisationStatus,'A') IN ('A')
			 --AND a.CustomerACID = @AccountID
			 --left JOIN ##AccountCal_HIST b ON A.CustomerACID=B.CustomerACID
             --aND b.CustomerACID is not null
			 --aND b.EffectiveFromTimeKey<=@Timekey 
        
        End

		
END
GO