SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [pro].[Reference_Period_Calculation_test] 
@TIMEKEY INT
AS
BEGIN
    SET NOCOUNT ON
  BEGIN TRY
	--declare @timekey int =49999
	declare @LogicSql varchar(2000)
	select * from  #a
UPDATE PRO.aa111 SET LogicSql='UPDATE A SET A.RefPeriodIntService='+CAST(RefValue AS varchar)+' FROM PRO.ACCOUNTCAL A WHERE SourceAlt_Key='+CAST(SourceSystemAlt_Key AS CHAR(2))
+' AND ProductCode NOT IN(''660'',''661'',''889'',''681'',''682'',''693'',''694'',''695'',''696'',''715'',''716'',''717'',''718'',''755'',''756'',''758'',''763'',''764'',''765'',''766'',''787'',''788'',''789'',''795'',''796'',''797'',''798'',''799'',''220'',''237'',''869'',''219'',''819'',''891'',''703'',''704'',''705'',''209'',''605'',''740'',''778'',''235'')'
WHERE BusinessRule='LookBackPeriod' and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
AND SourceSystemAlt_Key=1


select @LogicSql=LogicSql from PRO.RefPeriod WHERE BusinessRule='LookBackPeriod'
exec(@LogicSql)
END TRY
BEGIN CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Reference_Period_Calculation'
	select 1
END CATCH
 SET NOCOUNT OFF

END


EXEC [PRO].[Reference_Period_Calculation_test] 49999


--Msg 208, Level 16, State 1, Procedure Reference_Period_Calculation_test, Line 9 [Batch Start Line 28]
--Invalid object name 'PRO.RefPeriod_123'.
--Msg 208, Level 16, State 1, Procedure Reference_Period_Calculation_test, Line 9 [Batch Start Line 28]
--Invalid object name 'PRO.RefPeriod_123'.

--Msg 208, Level 16, State 1, Line 29
--Invalid object name 'PRO.ACCOUNTCAL_123'.
GO