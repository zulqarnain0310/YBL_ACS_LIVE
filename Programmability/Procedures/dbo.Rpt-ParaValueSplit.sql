SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[Rpt-ParaValueSplit]
	  @ExceptionCode AS VARCHAR(500)
AS



SELECT * FROM[Split](@ExceptionCode,',')   
              
GO