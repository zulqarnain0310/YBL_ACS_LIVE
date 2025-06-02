SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[Rpt-Source]
        @TimeKey AS INT ,
		@UserName AS VARCHAR(100)
AS

--DECLARE 
--        @TimeKey AS INT=26631 ,
--		@UserName AS VARCHAR(100)='dm585'

--added for report verification. remove this line while upload at UAT.
--set @UserName='mischecker'

IF(OBJECT_ID('tempdb..#Source') IS NOT NULL)
DROP TABLE #Source

SELECT * INTO #Source FROM(
SELECT Split.a.value('.', 'VARCHAR(100)') AS SourceAlt_Key
 FROM (
SELECT CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Code 
  FROM DimUserInfo 
  WHERE  EffectiveToTimeKey=49999 AND UserLoginID=@UserName
  ) D CROSS APPLY Code.nodes ('/M') AS Split(A) 
)DATA

OPTION(RECOMPILE)

SELECT  

DSDB.SourceAlt_Key        AS Code,
DSDB.Sourcename           AS Value


FROM DimSourceDB DSDB
              
INNER JOIN #Source  SC               ON DSDB.SourceAlt_Key=SC.SourceAlt_Key AND
										DSDB.EffectiveFromTimeKey<=@Timekey AND
										DSDB.EffectiveToTimeKey>=@Timekey 

OPTION(RECOMPILE)

DROP TABLE #Source
GO