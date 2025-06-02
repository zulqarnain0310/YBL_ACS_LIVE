SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


Create PROCEDURE [dbo].[SuspendUsersByDormancy_DailyActivity]
AS
BEGIN

DECLARE @TimeKey INT=(SELECT TimeKey FROM SysDayMatrix WHERE CAST(Date AS DATE)=CAST(GETDATE() AS DATE))  --@TimeKey for suspension on current date
DECLARE @TIMEKEY1 INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')  --@TIMEKEY1 to update in process moniter

DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY1)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for SuspendUsersByDormancy_DailyActivity','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SETID

IF OBJECT_ID('TEMPDB..#SuspendUserDetails') IS NOT NULL
  DROP TABLE #SuspendUserDetails

select * into #SuspendUserDetails 
from (
SELECT UserLoginID,CurrentLoginDate,DateCreated,
datediff(d,isnull(CurrentLoginDate,DateApproved),GETDATE()) AS 'Days',SuspendedUser
FROM DimUserInfo
WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey > = @TimeKey))B where b.Days>90 and b.SuspendedUser='N'

update b set b.SuspendedUser='Y' from #SuspendUserDetails A
inner join DimUserInfo B
on A.UserLoginID=B.UserLoginID
where EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey > = @TimeKey


UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND 
 TIMEKEY=@TIMEKEY1 AND DESCRIPTION='Work for SuspendUsersByDormancy_DailyActivity'



END



GO