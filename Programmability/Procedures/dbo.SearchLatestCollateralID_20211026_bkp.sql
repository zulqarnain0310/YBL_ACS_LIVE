SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


    
CREATE PROC [dbo].[SearchLatestCollateralID_20211026_bkp]    
As

Declare @CollateralID Varchar(30)
		 Select @CollateralID=Convert(Int,CollateralID)+1 from
		 (

		 Select Distinct CollateralID from DBO.AdvSecurityDetail_MOD
			Where SecurityEntityID IN(Select Max(SecurityEntityID) from DBO.AdvSecurityDetail_MOD)
)X

Select @CollateralID

GO