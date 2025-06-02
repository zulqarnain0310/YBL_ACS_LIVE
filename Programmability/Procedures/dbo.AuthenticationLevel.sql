SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--sp_helptext CollateralValueSearchList 

create Procedure [dbo].[AuthenticationLevel]
AS
Select   ISNULL(A.MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,A.MenuCaption, ActionName,B.DateCreated,B.DateModified,
ISNULL(B.AuthorisationStatus,'') as AuthorisationStatus,ISNULL(B.[1stLevelApprovedBy],'') as [FirstLevelApprovedBy],
ISNULL(B.[2ndLevelApprovedBy],'') as [SecondLevelApprovedBy],
  Case  When ParentId in(0,9999) And (ISNULL(ActionName,'')='#' Or ISNULL(ActionName,'')='') Then NULL
				      When ParentId in(0,9999) And ISNULL(ActionName,'')<>'#' Then Case When Isnull(B.[NewAuthenticationLevelAlt_Key],0)=0 Then NULL
					  When Isnull(B.[NewAuthenticationLevelAlt_Key],0)=1 Then '1'
					  When Isnull(B.[NewAuthenticationLevelAlt_Key],0)=2 Then '2'
					  END
				      When Isnull(B.[NewAuthenticationLevelAlt_Key],0)=0 Then NULL
					  When Isnull(B.[NewAuthenticationLevelAlt_Key],0)=1 Then '1'
					  When Isnull(B.[NewAuthenticationLevelAlt_Key],0)=2 Then '2'
					 END as [NewAuthlevelType]
				 ,ROW_NUMBER() over (order by MenuTitleID, DataSeq) as srno
				 ,Case  When ParentId in(0,9999) And ISNULL(ActionName,'')<>'#' then 'Y'
				      when ISNULL(ParentId,0) IN (9999,0) then 'N' else 'Y' END as IsChild 
				 
				  ,  Case  When ParentId in(0,9999) And (ISNULL(ActionName,'')='#' Or ISNULL(ActionName,'')='') Then NULL
				      When ParentId in(0,9999) And ISNULL(ActionName,'')<>'#' Then Case When Isnull(A.Authlevel,0)=0 Then '0'
					  When Isnull(A.Authlevel,0)=1 Then '1'
					  When Isnull(A.Authlevel,0)=2 Then '2'
					  END
				      When Isnull(A.Authlevel,0)=0 Then '0'
					  When Isnull(A.Authlevel,0)=1 Then '1'
					  When Isnull(A.Authlevel,0)=2 Then '2'
					 END As Authlevel
			         ,  Case  When ParentId in(0,9999) And (ISNULL(ActionName,'')='#' Or ISNULL(ActionName,'')='') Then NULL
				      When ParentId in(0,9999) And ISNULL(ActionName,'')<>'#' Then Case When Isnull(A.Authlevel,0)=0 Then 'No Authorization Req.'
					  When Isnull(A.Authlevel,0)=1 Then '1st level Authorization'
					  When Isnull(A.Authlevel,0)=2 Then '2nd level Authorization'
					  END
				      When Isnull(A.Authlevel,0)=0 Then 'No Authorization Req.'
					  When Isnull(A.Authlevel,0)=1 Then '1st level Authorization'
					  When Isnull(A.Authlevel,0)=2 Then '2nd level Authorization'
					 END As AuthlevelDescription
				 ,  Case  When ParentId in(0,9999) And (ISNULL(ActionName,'')='#' Or ISNULL(ActionName,'')='') Then NULL
				      When ParentId in(0,9999) And ISNULL(ActionName,'')<>'#' Then Case When Isnull(A.Authlevel,0)=0 Then '1,2'
					  When Isnull(A.Authlevel,0)=1 Then '0,2'
					  When Isnull(A.Authlevel,0)=2 Then '0,1'
					  END
				      When Isnull(A.Authlevel,0)=0 Then '1,2'
					  When Isnull(A.Authlevel,0)=1 Then '0,2'
					  When Isnull(A.Authlevel,0)=2 Then '0,1'
					  
					 END As NewAuthlevel,
					
					 
					  'AuthenticationLevel' TableName
					From SysCRisMacMenu A
					Left Join [InterfaceAuthoLevel_Mod] B ON A.MenuId=B.MenuId
					WHERE Visible=1
					Order by MenuTitleID, DataSeq


		






GO