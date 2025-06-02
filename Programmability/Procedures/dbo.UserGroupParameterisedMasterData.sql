SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[UserGroupParameterisedMasterData] 
	@timekey INT
AS
BEGIN
	PRINT 'START'
		Update SysCRisMacMenu Set Visible=1 where MenuId in (401) 
			SELECT CtrlName
					,FldName
					,FldCaption
					,FldDataType
					,FldLength
					,ErrorCheck
					,DataSeq
					,CriticalErrorType
					,MsgFlag
					,MsgDescription
					,ReportFieldNo
					,ScreenFieldNo
					,ViableForSCD2
				FROM metaUserFieldDetail WHERE FrmName ='frmUserGroup'
					  
				 Select  EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,MenuCaption, ActionName,BusFld
					From SysCRisMacMenu WHERE Visible=1
					Order by MenuTitleID, DataSeq

  	Update SysCRisMacMenu Set Visible=0 where MenuId in (401) 

END







GO