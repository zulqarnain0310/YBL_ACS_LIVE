SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE trigger [TraceDbChanges]
on database
for  
create_procedure, alter_procedure, drop_procedure,
create_table, alter_table, drop_table,
create_function, alter_function, drop_function , 
create_trigger , alter_trigger , drop_trigger  ,
Create_Index,ALter_Index,Drop_Index,
Create_PARTITION_FUNCTION,ALTER_PARTITION_FUNCTION,Drop_PARTITION_FUNCTION,
Create_PARTITION_Scheme,ALTER_PARTITION_Scheme,Drop_PARTITION_Scheme,
CREATE_STATISTICS,DROP_STATISTICS,UPDATE_STATISTICS,
CREATE_SYNONYM,DROP_SYNONYM,
CREATE_USER ,Alter_USER ,Drop_USER

as

set nocount on

declare @data xml
set @data = EVENTDATA()
declare @DbVersion varchar(20)
set @DbVersion ='1.0.0'--(select ga.GetDbVersion())
declare @DbType varchar(50)
set @DbType ='Local'--(select ga.GetDbType())
declare @DbName varchar(256)
set @DbName =@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)')
declare @LoginName varchar(256) 
set @LoginName = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
declare @EventType varchar(Max)
set @EventType =@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)')
declare @ObjectName varchar(256)
set @ObjectName  = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)')
declare @ObjectType varchar(25)
set @ObjectType = @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)')
declare @TSQLCommand varchar(max)
set @TSQLCommand = @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)')
Declare @PostTime DateTime
set @PostTime = Convert(DateTime,@data.value('(/EVENT_INSTANCE/PostTime)[1]', 'varchar(50)'))
Declare @ServerName Varchar(50)
set @ServerName = @data.value('(/EVENT_INSTANCE/ServerName)[1]', 'varchar(50)')
Declare @SPID Varchar(10)
set @SPID = @data.value('(/EVENT_INSTANCE/SPID)[1]', 'varchar(50)')
Declare @HostName Varchar(100)
set @HostName = (Select HOSTName From sys.sysprocesses Where spid=@SPID And loginame=@LoginName)


declare @opentag varchar(4)
set @opentag= '&lt;'
declare @closetag varchar(4) 
set @closetag= '&gt;'
declare @newDataTxt varchar(max) 
set @newDataTxt= cast(@data as varchar(max))
set @newDataTxt = REPLACE ( REPLACE(@newDataTxt , @opentag , '<') , @closetag , '>')


declare @UserName varchar(50)
set @UserName= Right(@LoginName,LEn(@LoginName)-PATINDEX('%[_]%',@LoginName)) 
declare @SchemaName sysname 
set @SchemaName = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');


-- select column_name from information_schema.columns where table_name ='DbObjChangeLog'
insert into [dbo].[DbObjChangeLog]
(
[DatabaseName] ,
[SchemaName],
[DbType],
[EventType],
[ObjectName],
[ObjectType] ,
[SqlCommand] ,
[LoginName] ,
[HostName],
[TSql],
[PostTime],
[ServerName],
[SPID]
)

Values(

@DbName,
@SchemaName,
@DbType,
@EventType, 
@ObjectName, 
@ObjectType , 
@newDataTxt, 
@LoginName , 
@HostName,
@TSQLCommand,
@PostTime,
@ServerName,
@SPID
)

--DROP TABLE IF EXISTS #SPList

IF OBJECT_ID('TEMPDB..#SPList')IS NOT NULL 
		DROP TABLE #SPList


SELECT  object_id,schema_id,SCHEMA_NAME(schema_id)+'.'+NAME AS SPName INTO #SPList FROM SYS.OBJECTS 

UPDATE D
SET ObjectID=S.object_id,SchemaID=S.schema_id
FROM [dbo].[DbObjChangeLog] D
JOIN #SPList S ON S.SPName=D.SchemaName+'.'+D.ObjectName
WHERE D.ObjectID IS NULL

--DROP TABLE IF EXISTS #SPList
IF OBJECT_ID('TEMPDB..##SPList')IS NOT NULL 
		DROP TABLE #SPList

GO