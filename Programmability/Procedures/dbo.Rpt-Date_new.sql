SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Rpt-Date_new]
@Year INT,
@Month Varchar(20)

AS
BEGIN

if @Year ='2021' 

begin
select top 5 *  from pro.AccountCal
end

else
begin

select top 5 * from pro.customercal
end

 
END




GO