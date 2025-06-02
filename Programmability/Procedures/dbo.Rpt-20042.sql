SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 Create PROCEDURE [dbo].[Rpt-20042]
   @RangeFrom varchar(15),
   @RangeTo   varchar(15),
   @Cost      AS FLOAT
   AS 
	
	 --DECLARE 
 	--  @RangeFrom varchar(15)='24/01/2024'--'01/01/2015'---
	 --,@RangeTo   varchar(15)='29/06/2024'---
	 --,@Cost      AS FLOAT=1   

	  declare @From1 date,@to1 date 
SET @From1=(SELECT * FROM dbo.DateConvert(@RangeFrom))
SET @to1=(SELECT * FROM dbo.DateConvert(@RangeTo))

--select @From1,@to1
  Declare @V1 As int=(select TimeKey from SysDayMatrix where date=@from1)
  Declare @v2 as int=(select TimeKey from SysDayMatrix where date=@to1) 
   

--declare @Date date=(select date from SysDayMatrix  where TimeKey=@TimeKey)

			select 
			A.CustomerID AS CustomerID,
	        B.UCIFID AS UCIC,
            A.SourceSystemCustomerID AS SourceSystemCustomerID,
		   	A.CustomerName AS CustomerName,
	        A.AssetClassification AS AssetClassification,--
			CONVERT(VARCHAR(20),A.NPADate,103) AS NPADate,
			A.SecurityValue AS SecurityValue,
			A.AdditionalProvision AS AdditionalProvision,
			A.MOCReason AS MOCReason,
			A.AuthorisationStatus AS AuthorisationStatus,
	        A.CreatedBy AS CreatedBy,
			A.ModifiedBy AS	ModifiedBy,
			A.ApprovedBy AS ApprovedBy,
			CONVERT(VARCHAR(20),A.DateCreated,103) AS DateCreated, 
			CONVERT(VARCHAR(20),A.DateApproved,103)As DateApproved,
			A.ScreenFlag	AS ScreenFlag
			,A.MOCTYPE AS MOCTYPE 
			,1 as flag
			,CONVERT(VARCHAR(20),a.DateModified,103)DateModified
			from  DataUpload.MocCustomerDataUpload_Mod A
			left outer join DataUpload.MocCustomerDataUpload C on C.MocCustomerDataEntityId=A.MocCustomerDataEntityId
			and a.EffectiveFromTimeKey=C.EffectiveFromTimeKey
			LEFT JOIN pro.UcifidMaster B  ON  C.UCIFEntityID=B.UCIFEntityID
			 							

	        WHERE  CONVERT(date,A.DateApproved) between @From1  and @to1
			and a.AuthorisationStatus='A'  















GO