SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*
 Created by   : KALIK DEV
 Created date : 15/02/2022
 Report Name  : Borrower Not in outstanding data  As On 
*/

CREATE Proc [dbo].[Rpt-20032_B]
 @TimeKey AS INT ,
 @SelectReport   AS INT
AS


--DECLARE
--@TimeKey AS  INT = 25705, 
--@SelectReport   AS INT = 3


SELECT 
PDTSID,
ICRABorrowerID,
A.RefCustomerID,
Segment,
PS.CustomerName,
PS.CovenantType,
PS.CovenantDescription,
CONVERT(VARCHAR(20),PS.DueDate,103)					AS DueDate,
PS.Frequency,
CAST(PS.NoofGraceDays AS VARCHAR(20))               AS NoofGraceDays,
CAST(PS.DPD AS VARCHAR(20))                         AS DPD

FROM PRO.CustomerCal_Hist A

INNER JOIN PRO.StockStDate PS								ON   A.IMAXID_CCUBE = PS.ICRABorrowerID
															AND  A.EffectiveFromTimeKey<=@Timekey
															AND	 A.EffectiveToTimeKey>=@Timekey
															AND  PS.EffectiveFromTimeKey<=@TimeKey
															AND  PS.EffectiveToTimeKey>=@TimeKey


WHERE (ISNULL(A.TotOsCust,0) = 0 AND @SelectReport=2)  OR (ISNULL(A.TotOsCust,0) = 0 AND @SelectReport=3) AND A.IMAXID_CCube IS NOT NULL

OPTION(RECOMPILE)
GO