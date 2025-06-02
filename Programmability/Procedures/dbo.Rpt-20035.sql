SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
 Created by   : Baijayanti
 Created date : 12/09/2022
 Report Name  : Provision Parameter Master Report As On
*/

CREATE Proc [dbo].[Rpt-20035]
 @TimeKey AS INT 
AS

--DECLARE
--@TimeKey AS  INT = 49999


SELECT 
--DISTINCT 	
ProvisionRule                  AS ProvisionRule	,
 CASE WHEN ProvisionName like '%Ab initio Unsecured%'
      THEN 'AB INITIO UN SECURED'
      WHEN ProvisionName like '%FITL%'
      THEN 'FITL'
      WHEN ProvisionName like '%Infrastructure%'
      THEN 'INFRASTRUCTURE'
	  WHEN ProvisionName like 'KCC____%'
      THEN 'KCC NON PROPERTY'
	  WHEN ProvisionName like 'KCC%'
      THEN 'KCC'
	  WHEN ProvisionName like 'PropertyBacked%'
      THEN 'PROPERTY BACKED'
	  WHEN ProvisionName like 'NON_Property_Backed%'
      THEN 'NON PROPERTY BACKED'
	  WHEN ProvisionName like 'UNSECUERED%'
      THEN 'UNSECUERED'
	  WHEN ProvisionName like 'VisionPlus%'
      THEN 'VisionPlus'
	  ELSE 'NORMAL ASSET CLASS'
	  END						 AS FacilityType
--,ProvisionShortNameEnum        AS FacilityType	
,ProvisionName                 AS ProvisionName	
,ProvisionSecured              AS ProvisionSecured	
,ProvisionUnSecured            AS ProvisionUnSecured	
,LowerDPD                      AS LowerDPD	
,UpperDPD                      AS UpperDPD	
,RBIProvisionSecured           AS RBIProvisionSecured	
,RBIProvisionUnSecured         AS RBIProvisionUnSecured

FROM DimProvision_Seg
WHERE EffectiveFromTimeKey<=@Timekey AND	 EffectiveToTimeKey>=@Timekey
order by ProvisionRule ,FacilityType ,ProvisionAlt_Key 
															
OPTION(RECOMPILE)
GO