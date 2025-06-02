SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Rpt-Report_Customer_Selection] 
   @TimeKey   AS INT,
   @RP_Plan AS VARCHAR(100)
AS

--DECLARE 
--   @TimeKey   AS INT=25781,
--   @RP_Plan AS VARCHAR(100)='ALL'


SELECT 
'0'   Value, '<ALL>'   Label

UNION ALL

SELECT 
RPPD.[CustomerID]  Value,RPPD.CustomerName  Label

  FROM RP_Portfolio_Details RPPD
											       
  INNER JOIN DimParameter DP                      ON RPPD.DefaultStatusAlt_Key=DP.ParameterAlt_Key
                                                      AND DP.EffectiveFromTimeKey<=@TimeKey 
												      AND DP.EffectiveToTimeKey>=@TimeKey
													  AND RPPD.EffectiveFromTimeKey<=@TimeKey 
												      AND RPPD.EffectiveToTimeKey>=@TimeKey
												      AND DP.DimParameterName='BorrowerDefaultStatus'   
													  
													  												   
  INNER JOIN DimParameter DPI                     ON RPPD.RP_ImplStatusAlt_Key=DPI.ParameterAlt_Key
                                                      AND DPI.EffectiveFromTimeKey<=@TimeKey 
												      AND DPI.EffectiveToTimeKey>=@TimeKey
													  AND DPI.DimParameterName='ImplementationStatus'
													  											       

 WHERE (@RP_Plan=(CASE WHEN (DP.ParameterName='In Default' AND DPI.ParameterName='In Progress') OR  DPI.ParameterName='Extended'
	                      THEN 'Active'
						  WHEN (DP.ParameterName='Out of Default' AND DPI.ParameterName='Implemented') OR  (DP.ParameterName='Out of Default' AND DPI.ParameterName='Implemented with Extension')
	                      THEN 'Expired'
						  END) OR @RP_Plan='ALL')

  OPTION(RECOMPILE)
GO