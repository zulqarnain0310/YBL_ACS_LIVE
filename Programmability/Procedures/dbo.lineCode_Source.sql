SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[lineCode_Source]
as
Declare @TimeKey AS INT
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

select SourceAlt_Key,SourceName, 'SourceTable' Tablename from DimSourceDB
where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
and SourceAlt_Key IN (1,2,4)





GO