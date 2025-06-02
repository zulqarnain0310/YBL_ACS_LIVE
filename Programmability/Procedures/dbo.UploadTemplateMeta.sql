SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UploadTemplateMeta]
@UploadTemplate			   VARCHAR(50)=''
AS
BEGIN

	SELECT ParameterName as ColumnName from DimParameter where DimParameterName=@UploadTemplate and EffectiveToTimeKey=49999 order by ParameterAlt_Key
	

END


GO