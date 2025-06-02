SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[NPAProvisionHistory_beforeUatDeployment_bkp]

						@ProvisionName varchar(255)

AS

Declare @TimeKey as Int  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  


	BEGIN

	         	Select	ProvisionAlt_Key,
					'NPAProvisionHistory' as TableName,
					ProvisionName,
					ProvisionSecured,
					ProvisionUnSecured,
					RBIProvisionSecured,
					RBIProvisionUnSecured,
					AdditionalprovisionRBINORMS,
					LowerDPD,
					UpperDPD,
					CreatedBy, 
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModified,103) DateModified,
					convert(varchar(20),S1.date ,103) as EffectiveFromDate,
					convert(varchar(20),S2.date ,103) as EffectiveToDate,
					Segment
					,ProvisionRule
					,RBIProvisionSecured
					,RBIProvisionUnSecured
					,ProvisionShortNameEnum AS FacilityType
					
					FROM DimProvision_Seg P
					inner join sysdaymatrix S1 ON S1.Timekey=P.EffectiveFromTimekey
					inner join sysdaymatrix S2 ON S2.Timekey=P.EffectiveToTimekey

					Where ProvisionName=@ProvisionName
					and P.EffectiveToTimekey<>49999
					and ISNULL(P.AuthorisationStatus,'A')='A'

					UNION

			        Select	ProvisionAlt_Key,
					'NPAProvisionHistory' as TableName,
					ProvisionName,
					ProvisionSecured,
					ProvisionUnSecured,
					RBIProvisionSecured,
					RBIProvisionUnSecured,
					AdditionalprovisionRBINORMS,
					LowerDPD,
					UpperDPD,
					CreatedBy, 
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModified,103) DateModified,
					convert(varchar(20),S1.date ,103) as EffectiveFromDate,
					convert(varchar(20),S2.date ,103) as EffectiveToDate,
					Segment
					,ProvisionRule
					,RBIProvisionSecured
					,RBIProvisionUnSecured
					,ProvisionShortNameEnum AS FacilityType
					
					FROM DimNPAProvision_Mod P
					inner join sysdaymatrix S1 ON S1.Timekey=P.EffectiveFromTimekey
					inner join sysdaymatrix S2 ON S2.Timekey=P.EffectiveToTimekey

					Where ProvisionName=@ProvisionName
					and P.EffectiveToTimekey<>49999
					and ISNULL(P.AuthorisationStatus,'A')='A'

					

				

	END
	--select * from DimProvision_Seg
	--select * from sysdaymatrix where timekey=24928--2018-04-01 00:00:00.000
GO