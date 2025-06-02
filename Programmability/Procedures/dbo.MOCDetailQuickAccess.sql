SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [YES_MISDB]
--GO
--/****** Object:  StoredProcedure [dbo].[MOCDetailQuickAccess]    Script Date: 5/11/2019 2:22:33 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE PROC [dbo].[MOCDetailQuickAccess]
--DECLARE
	@CustomerID			varchar(30)='', 
	@CustomerName		varchar(225)='',
	@BranchCode			varchar(20)='',
	@BranchName			varchar(50)='',
	@CustomerAcID		varchar(30)='',
	@CaseNo				varchar(30)='',
	----
	@TimeKey			int=25292,
	@UserLoginID		varchar(10)='',
	@Mode				TINYINT=0 ,
	@CustType			VARCHAR(20)=''

	AS

--DECLARE @LocatationCode VARCHAR(10)='', @Location char(2)='HO', @CustomerEntityID INT=0
IF @Mode = 16
BEGIN
	SELECT CustomerEntityID
		,RefCustomerID		CustomerID
		,A.CustomerName			
		,ISNULL(BR.BranchCode,'')	BranchCode
		,BranchName 
		,ISNULL(A.ModifiedBy,A.CreatedBy) AS CrModApBy
		FROM DataUpload.MocCustomerDataUpload_Mod A
	INNER JOIN 
	(
	SELECT CustomerID, MAX(Entitykey)Entitykey FROM DataUpload.MocCustomerDataUpload_Mod
	WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey > =@TimeKey
		AND AuthorisationStatus in('NP','MP','DP','RM')
		AND CustomerID	LIKE '%'+CASE WHEN ISNULL(@CustomerID,'')<>''		THEN @CustomerID	ELSE CustomerID	END+'%'
		AND CustomerName	LIKE '%'+CASE WHEN ISNULL(@CustomerName,'')<>''	THEN @CustomerName	ELSE  @CustomerName	END+'%'
	GROUP BY CustomerID
	)B
	ON A.Entitykey = B.Entitykey
	INNER JOIN PRO.CustomerCal_hist HIST
		on HIST.EffectiveFromTimeKey<= @TimeKey AND HIST.EffectiveToTimeKey >= @TimeKey
		AND HIST.RefCustomerID = A.CustomerID
	LEFT OUTER JOIN DimBranch BR
		ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
		AND BR.BranchCode = HIST.BranchCode

END
ELSE
BEGIN
SELECT	 CustomerEntityID
		,RefCustomerID		CustomerID
		,CustomerName			
		,ISNULL(BR.BranchCode,'')	BranchCode
		,BranchName
FROM PRO.CustomerCal_hist HIST
LEFT OUTER JOIN DimBranch BR
	ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
	AND HIST.BranchCode = BR.BranchCode
WHERE HIST.EffectiveFromTimeKey <= @TimeKey AND HIST.EffectiveToTimeKey >= @TimeKey
	--AND BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
	AND RefCustomerID	LIKE '%'+CASE WHEN ISNULL(@CustomerID,'')<>''	THEN @CustomerID	ELSE RefCustomerID	END+'%'
	AND CustomerName	LIKE '%'+CASE WHEN ISNULL(@CustomerName,'')<>''	THEN @CustomerName	ELSE  @CustomerName	END+'%'
END
GO