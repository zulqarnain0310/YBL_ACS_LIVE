SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


Create Proc [dbo].[Rpt-20042_FraudNewformat]
  @RangeFrom varchar(15),
   @RangeTo   varchar(15),
   @Cost      AS FLOAT
   AS 


----select * from SysDayMatrix where date='2024-05-21'														
														
 --DECLARE 
 	--  @RangeFrom varchar(15)='21/12/2021'--'01/01/2015'---
	 --,@RangeTo   varchar(15)='24/01/2024'---
	 --,@Cost      AS FLOAT=1   

declare @From1 date,@to1 date 
SET @From1=(SELECT * FROM dbo.DateConvert(@RangeFrom))
SET @to1=(SELECT * FROM dbo.DateConvert(@RangeTo))

--select @From1,@to1
  Declare @V1 As int=(select TimeKey from SysDayMatrix where date=@from1)
  Declare @v2 as int=(select TimeKey from SysDayMatrix where date=@to1) 
  
														
select ucif_id,
customerid,customername,
customeracid,
CONVERT(VARCHAR(20),dateoffraud,103)dateoffraud,
amountoffraud,
AuthorisationStatus,
CreatedBy,
CONVERT(VARCHAR(20),DateCreated,103)DateCreated,
ModifiedBy,
CONVERT(VARCHAR(20),DateModified,103)DateModified,
ApprovedBy,
CONVERT(VARCHAR(20),DateApproved,103)DateApproved,
CONVERT(VARCHAR(20),EffectiveNPADate,103)EffectiveNPADate
 
from DataUpload.FraudAccountsDataUpload
WHERE  CONVERT(date,DateApproved) between @From1  and @to1 	

Option (Recompile)
GO