SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- ====================================================================================================================
-- Author:			<Amar>
-- Create Date:		<30-11-2014>
-- Loading Master Data for Common Master Screen>
-- ====================================================================================================================
--- [MetaDynamicScreenSelectControl]  @MenuId =480, @TimeKey =24528, @Mode =1, @BaseColumnValue  = 0
--alter table [BOB_LEGAL_PLUS_TEST].[dbo].[MetaDynamicMasterFilter] ADD FilterBySelectValue varchar(100),FilterByRemoveValue varchar(100), MenuId smallint

CREATE PROCEDURE [dbo].[MetaDynamicScreenSelectControl]
	 @MenuId Int=6668,
	 @TimeKey INT=24528,
	 @Mode TINYINT=2,
	 @BaseColumnValue varchar(50) = 1,
	 @TabId int=0
 AS 
BEGIN

	IF @Mode=1 SET @BaseColumnValue=0
	
	DECLARE  @TabApplicable BIT=0
	SELECT @TabApplicable=1  FROM dbo.MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0 AND ValidCode='Y'
	
	IF @TabApplicable=1 and @TabId=0
		BEGIN
			SELECT @TabId=MIN(ParentcontrolID)  FROM MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0 AND ValidCode='Y'
		END

	
			/*  fetch data from SysCrisMacMenu Table*/
			--DECLARE @Gridapplicable BIT= 0
			--SELECT @Gridapplicable=	1 FROM MetaDynamicScreenField A 
			--		INNER JOIN MetaDynamicGrid B
			--			ON A.ControlId=B.ControlId
			--	WHERE MENUID=@MENUID
			--		AND ISNULL(A.ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(A.ParentcontrolID,0) END 
			--		AND ISNULL(ValidCode,'N')='Y' 


			/*	FETCH META DATA  CONTROLS*/		

			print @MenuId
			SELECT  'ScreenDetail' TableName,MenuCaption ,MenuId,NonAllowOperation,DeptGroupCode,EnableMakerChecker,ResponseTimeDisplay,AccessLevel
				,CASE WHEN ISNULL(GridApplicable,'N')='Y' THEN 1 ELSE 0 END GridApplicable
				,CASE WHEN ISNULL(Accordian,'N')='Y' THEN 1 ELSE 0 END Accordian
				, @TabApplicable TabApplicable
				, convert(varchar(10),getdate(),103) [CURDATE]
			FROM dbo.SysCRisMacMenu WHERE MenuId= @MenuId
			
			
				SELECT	'Meta' AS TableName
						,ControlID
						,ParentcontrolID
						,Label
						,'DynamicMaster_'+REPLACE(Label,' ','') + '_Msg'  AS FieldMessage
						,ControlName ColumnName
						,ControlType
						,AutoCmpltMinLength
						,Col_sm
						,Col_lg
						,Col_md
						,SourceTable
						,DisplayRowOrder
						,DisplayColumnOrder
						,SourceColumn
						,ReferenceTableFilter
						,ISNULL(ReferenceTable,'NA') AS ReferenceTable, ISNULL(ReferenceColumn,'NA') AS ReferenceColumn
						,RefColumnValue
						,ReferenceTableCond
						,BaseColumnType
						,[DataType]
						,ISNULL(DataMinLength,0) as DataMinLength
						,ISNULL(DataMaxLength,0) as DataMaxLength
						,ControlName
						,ISNULL(IsMandatory,0) as IsMandatory
						,ISNULL(IsVisible,0) as IsVisible
						,ISNULL(IsEditable,0) as IsEditable
						,ISNULL(IsUpper,0) as IsUpper
						,ISNULL(IsLower,0) as IsLower
						,ISNULL(ISDBPull,0) as ISDBPull
						,ISNULL(IsF2Button,0) as IsF2Button
						,ISNULL(IsCloseButton,0) as IsCloseButton
						,ISNULL(IsParentToChild,0) as IsParentToChild
						,ISNULL(IsChildToParent,0) as IsChildToParent
						,ISNULL(IsAlwaysDisable,0) as IsAlwaysDisable			--Added by Amol 05 12 2017
						,DisAllowedChar
						,AllowedChar
						,OnBlur
						,OnBlurParameter
						,OnClick
						,OnClickParameter
						,OnChange
						,OnChangeParameter
						,OnKeyPress
						,OnKeyPressParameter
						,OnFormLoad
						,OnFormLoadParameter
						,DefaultValue
						,ISNULL(SkipColumnInQuery,'N') SkipColumnInQuery
						,isnull(Class,'') Class
						,isnull(Style,'') Style
						--,CASE WHEN @Gridapplicable=1 THEN 'Y' ELSE 'N' END AS GridApplicable
						,ISNULL(ApplicableForWorkFlow,'N')ApplicableForWorkFlow
						,ISNULL(EditprevStageData,'N') as EditprevStageData
						,ISNULL(ScreenFieldNo,0) as ScreenFieldNo
						,OnSaveValidate
						,OnSaveParameter
				FROM dbo.MetaDynamicScreenField B
					WHERE MenuId=@MenuId --B.SourceTable=@TableName
						AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
						AND ISNULL(ValidCode,'N')='Y' 
						ORDER BY DisplayRowOrder, DisplayColumnOrder
					
			----select * from ##TmpDataSelect
					
		/* Dynamic Validation Data Fetch Logic */
	
				
				SELECT 	
					'Validation' AS TableName			
				   ,ValidationGrpKey
				   ,ValidationKey
				   --,VAL.ControlID
				   ,FLD.ControlName ControlID
				   ,CurrExpectedValue
				   ,CurrExpectedKey
				   , ExpControlID
				   ,ExpKey
				   ,ExpControlValue
				   ,Operator 
				   ,[Message]
				FROM dbo.MetaDynamicValidation VAL
				   INNER JOIN dbo.MetaDynamicScreenField FLD
					 ON VAL.ControlID = FLD.ControlID AND FLD.MenuID = @MenuId
				--   WHERE ISNUMERIC(VAL.ExpControlID) = 0
				order by ValidationGrpKey, ValidationKey 

		/* Dynamic Validation Data Fetch Logic END */
		
		/* Dynamic Master Data Fetch Logic */

		IF	OBJECT_ID('TEMPBD..#MASTERTMP') IS NOT NULL
			DROP TABLE #MASTERTMP

			SELECT 'Master'  AS TableName ,A.ControlId,MasterTable
			INTO #MASTERTMP
				FROM dbo.MetaDynamicScreenField A 
						INNER JOIN dbo.METADYNAMICMASTER B
					ON A.CONTROLID=B.CONTROLID
				WHERE MENUID=@MENUID 
			
		--	/*FOR UPDATING SUIT MASTER RUN TIME*/
			
			SELECT * FROM #MASTERTMP

		/*Dynamic Data for fetching resource file.*/	
				
			SELECT  'ResourceDetail'		TableName,
			REPLACE(MenuCaption,' ','')		ResourceName
			FROM SysCRisMacMenu 
			WHERE MenuId= @MenuId
			

			SELECT 	'StaticSP' AS TableName,			
					SSP.ControlID,SPName,ClientSideParams,ServerSideParams
				FROM [dbo].[MetaDynamicCallStaticSP] SSP
				   INNER JOIN dbo.MetaDynamicScreenField FLD
					 ON SSP.ControlID = FLD.ControlID AND FLD.MenuID = @MenuId
					 order by SSP.Entitykey

		SELECT MasterFilterGrpKey,MasterFilterKey,FilterMasterControlName,RefColumnName,FilterByColumnName,ExpectedValue,FilterBySelectValue,FilterByRemoveValue,M.MenuID,'MasterFilter' TableName
		FROM [dbo].[MetaDynamicMasterFilter] M
		INNER JOIN dbo.MetaDynamicScreenField S ON M.ControlId= S.ControlID  AND S.MenuID = @MenuId AND M.MenuID= @MenuId

		/*Dynamic Grid meta Fetch */	
		IF EXISTS (SELECT 1 FROM SysCRisMacMenu WHERE MenuId=@MenuId AND (ISNULL(GridApplicable,'N')='Y' OR ISNULL(Accordian,'N')='Y'))
			BEGIN
				SELECT 'MetaGrid'  AS TableName,A.ControlName, B.*
					FROM dbo.MetaDynamicScreenField A 
						INNER JOIN dbo.MetaDynamicGrid B
							ON A.ControlId=B.ControlId
					WHERE MENUID=@MENUID
						AND ISNULL(A.ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(A.ParentcontrolID,0) END 
						AND ISNULL(ValidCode,'N')='Y' order by B.EntityKey
			END

															
		/* Dynamic Master Data Fetch Logic END*/
END

GO