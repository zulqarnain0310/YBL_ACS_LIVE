SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROC [dbo].[ValuationSourceDropDown]
@CollateralID Varchar(30)='',
@CollateralSubTypeAlt_Key INT=0
AS
	BEGIN

Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

--Declare @CollateralSubTypeAlt_Key INT=0
IF @CollateralID=''
    BEGIN
	    SET  @CollateralID=NULL
	END
IF @CollateralID=''
BEGIN
	Select @CollateralSubTypeAlt_Key=CollateralSubTypeAlt_Key from Curdat.AdvSecurityDetail
	Where CollateralID=@CollateralID

	If @CollateralSubTypeAlt_Key=0 

	BEGIN
		Select @CollateralSubTypeAlt_Key=CollateralSubTypeAlt_Key from dbo.AdvSecurityDetail_MOD
	Where CollateralID=@CollateralID
	END
END


 PRINT '@CollateralSubTypeAlt_Key'
  PRINT @CollateralSubTypeAlt_Key
BEGIN

		Select ValueExpirationAltKey as SourceAlt_Key
		,Documents as SourceName
		,ExpirationPeriod as PeriodInMonth
		,'ValuationSource' TableName
		from DimValueExpiration
		where EffectiveFromTimeKey<=@Timekey
		AND EffectiveToTimeKey>=@Timekey AND SecuritySubTypeAlt_Key=@CollateralSubTypeAlt_Key


		Select A.[SecurityTypeAlt_Key] AS CollateralType_AltKey ,B.CollateralTypeDescription as CollateralType,
A.SecuritySubTypeAlt_Key as SecuritySubTypeAlt_Key, C.CollateralSubTypeDescription AS ParameterName,A.[ExpirationPeriod] As PeriodInMonth,
	'ValuationSourceData' TableName
From [DimValueExpiration] A INNER JOIN DimCollateralType B ON A.[SecurityTypeAlt_Key]= B.CollateralTypeAltKey
INNER JOIN DimCollateralSubType C ON A.SecuritySubTypeAlt_Key=C.CollateralSubTypeAltKey

END				

	END

GO