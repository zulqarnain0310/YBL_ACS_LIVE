SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*
 Created by   : Baijayanti
 Created date : 12/04/2021
 Report Name  : Automation of Submission of Stock Statement Process
*/

CREATE Proc [dbo].[Rpt-20026]
        @TimeKey AS INT
AS

--DECLARE   @TimeKey AS INT =25639


SELECT  
PDTSID,
ICRABorrowerID                       AS ICRABorrowerId,
ICRABorrowerID                       AS CustomerID,
SegmentID,
RMName,
''                                   AS TLName,
''                                   AS Branch,
CustomerName,
CovenantType,
CovenantDescription,
CONVERT(VARCHAR(20),ActualDueDate,103)     AS DueDate,---DueDate
Frequency,
ISNULL(NoofGraceDays,0)              AS NoofGraceDays,
ISNULL(ActualStockDPD,0)                        AS DPD,--DPD
''                                   AS WCLimits
FROM PRO.StockStDate 
              
WHERE EffectiveFromTimeKey<=@Timekey AND  EffectiveToTimeKey>=@Timekey 




OPTION(RECOMPILE)
  




GO