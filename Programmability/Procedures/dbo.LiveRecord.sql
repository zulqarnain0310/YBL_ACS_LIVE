SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE Proc [dbo].[LiveRecord]
As


Declare @SecurityEntityID          INT =NULL 

Declare @SecurityEntityID1          INT =NULL 
      Select @SecurityEntityID=  MAX(ISNULL(SecurityEntityID,0))+1  
      from(  
      select max(SecurityEntityID) SecurityEntityID from DBO.AdvSecurityDetail_Mod  
        UNION  
        select max(SecurityEntityID) SecurityEntityID from Curdat.AdvSecurityDetail  
        )A  
  
         IF (@SecurityEntityID IS NULL)  
  
        SET   @SecurityEntityID=1  

		------------------------------------------
		--SET @SecurityEntityID1=0

		 Select @SecurityEntityID1=  MAX(ISNULL(SecurityEntityID,0))+1  
      from(  
      select max(SecurityEntityID) SecurityEntityID from DBO.AdvSecurityValueDetail_Mod  
        UNION  
        select max(SecurityEntityID) SecurityEntityID from Curdat.AdvSecurityValueDetail  
        )A  
  

  
			
         IF (@SecurityEntityID1 IS NULL)  
  
        SET   @SecurityEntityID1=1  

		PRINT '@SecurityEntityID'
		PRINT @SecurityEntityID

				PRINT '@SecurityEntityID1'
		PRINT @SecurityEntityID1

	 IF OBJECT_ID('TempDB..#TEMP') IS NOT NULL DROP TABLE  #TEMP;

	 	 IF OBJECT_ID('TempDB..#TEMP1') IS NOT NULL DROP TABLE  #TEMP1;

	 Select EffectiveFromTimeKey,EffectiveToTimeKey,EntryType,ModifiedBy,CollateralID,SecurityEntityID,@SecurityEntityID+Row_Number()Over(order by (Select 1)) NewSecurityEntityID 
	 into #TEMP from Curdat.AdvSecurityDetail  
	where ModifiedBy='SSISUSER'
And EntryType='Corporate'
And EffectiveToTimeKey<>49999


	 Select EffectiveFromTimeKey,EffectiveToTimeKey,ModifiedBy,CollateralID,SecurityEntityID,@SecurityEntityID1+Row_Number()Over(order by (Select 1)) NewSecurityEntityID 
	 into #TEMP1 from Curdat.AdvSecurityValueDetail  
	where CollateralID In(Select CollateralID from #TEMP)


--Select '#TEMP', * from #TEMP
--Select '#TEMP1', * from #TEMP1

Update A
Set A.SecurityEntityID=B.NewSecurityEntityID
From Curdat.AdvSecurityDetail A
INNER JOIN #TEMP B ON
A.SecurityEntityID=B.SecurityEntityID
where A.ModifiedBy='SSISUSER'
And A.EntryType='Corporate'
And A.EffectiveToTimeKey<>49999


Update Curdat.AdvSecurityDetail  
SET EffectiveToTimeKey=49999
where ModifiedBy='SSISUSER'
And EntryType='Corporate'
And EffectiveToTimeKey<>49999

--Update A
--Set A.SecurityEntityID=B.NewSecurityEntityID
--From Curdat.AdvSecurityValueDetail A
--INNER JOIN #TEMP1 B ON
--A.SecurityEntityID=B.SecurityEntityID

--where B.CollateralID In(Select CollateralID from #TEMP1)

--Update Curdat.AdvSecurityValueDetail 
--SET EffectiveToTimeKey=49999
--where CollateralID In(Select CollateralID from #TEMP1)


--Select 'Curdat.AdvSecurityDetail',EffectiveFromTimeKey,EffectiveToTimeKey,EntryType,ModifiedBy,CollateralID,SecurityEntityID,@SecurityEntityID+Row_Number()Over(order by (Select 1)) NewSecurityEntityID 
--	  from Curdat.AdvSecurityDetail  
--	where ModifiedBy='SSISUSER'
--And EntryType='Corporate'

--AND CollateralID IN('1000393',
--'1000328',
--'1000329')


--Select 'Curdat.AdvSecurityValueDetail',EffectiveFromTimeKey,EffectiveToTimeKey,ModifiedBy,CollateralID,SecurityEntityID,@SecurityEntityID1+Row_Number()Over(order by (Select 1)) NewSecurityEntityID 
--	  from Curdat.AdvSecurityValueDetail  
--	where ModifiedBy='SSISUSER'
--AND CollateralID IN('1000393',
--'1000328',
--'1000329')



GO