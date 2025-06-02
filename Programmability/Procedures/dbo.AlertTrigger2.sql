SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create PROC [dbo].[AlertTrigger2]
AS

BEGIN


Declare @Timekey Int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

Declare @Date Date
SET @Date =(Select CAST(B.Date as Date)Date1 from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')


	BEGIN TRY		
		select 
		Alert_Date
		,B.ParameterName as AlertName
		,C.ParameterName as AlertScope
		,D.ParameterName as AlertFrequency
		,PrimaryRecipientEmailID
		,SecondaryRecipientEmailID 
		from AlertTriggerDetails A
		Inner Join (Select ParameterAlt_Key,ParameterName,'Alert Name' as Tablename 
				from DimParameter where DimParameterName='Alert Name'
				And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) B
				ON A.AlertNameAlt_Key=B.ParameterAlt_Key
				Inner Join (Select ParameterAlt_Key,ParameterName,'Alert Scope' as Tablename 
				from DimParameter where DimParameterName='Alert Scope'
				And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) C
				ON A.AlertScopeAlt_Key=C.ParameterAlt_Key
				Inner Join (Select ParameterAlt_Key,ParameterName,'Alert Frequency' as Tablename 
				from DimParameter where DimParameterName='Alert Frequency'
				And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) D
				ON A.AlertFrequencyAlt_Key=D.ParameterAlt_Key
				where A.EffectiveFromTimeKey<=@Timekey and A.EffectiveToTimeKey>=@Timekey
		and A.Alert_Date=@Date
		and AlertNameAlt_Key=2
		
		select 
		 B.ParameterName as Alertname
		,AlertDate
		,Borrower_PAN
		,UCIC_ID
		,Customer_ID
		,Borrower_Name
		,Name_of_reporting_Bank
		,Banking_arrangement
		,Name_of_lead_bank
		,Revised_RP_deadline_to_track_reversal_of_provisions 
		from AlertTriggerDataDetails A
		Inner Join (Select ParameterAlt_Key,ParameterName,'Alert Name' as Tablename 
				from DimParameter where DimParameterName='Alert Name'
				And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) B
		ON A.AlertNameAlt_Key=B.ParameterAlt_Key
		where A.EffectiveFromTimeKey<=@Timekey and A.EffectiveToTimeKey>=@Timekey
		and AlertDate=@Date
		and AlertNameAlt_Key=2

END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	END CATCH

END


GO