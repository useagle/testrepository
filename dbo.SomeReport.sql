USE [USEagle]
GO
/****** Object:  StoredProcedure [dbo].[USEagle_rpt_BRN0010_ProventIDTheftDataFile]    Script Date: 1/13/2020 10:55:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

   
-- =============================================
-- Author:		<Nilam Keval>
-- Create date: <10/16/2015>    
-- Modify Date: 12/03/2015 nkeval - Updated to remove duplicate records.
--				12/16/2016 nkeval - exclude account #390711
-- Description:	<Provent ID Theft Data File> 
-- =============================================

ALTER PROCEDURE [dbo].[USEagle_rpt_BRN0010_ProventIDTheftDataFile]
	
	AS BEGIN

SELECT 
	BankCode
	,UniqueCustomerID
	,LAST4SS 
	,FirstName
	,LastName
	,Address1
	,Address2
	,City
	,[State]
	,Zip
	,Email 
	,Phone
	,BusninessName_CompanyName
	,TaxID_EIN
	,DateOfBirth
	,BillingBranch	
	,BillToAccountNumber		
	,BillToAccountNumberType
	,DeluxeProductCode
FROM
(
SELECT 
	ROW_NUMBER() OVER(Partition by an.NameSSN Order by an.NameSSN) RowNum,
	CAST('307083652' As INT)		BankCode
	,RIGHT(an.NameSSN,6) + REPLACE(CAST(an.NameBirthdate As DATE), '-','')  UniqueCustomerID
	,RIGHT(an.NameSSN,4)			LAST4SS 
	,an.NameFirst					FirstName
	,an.NameLast					LastName
	,an.NameStreet					Address1
	,''								Address2
	,an.NameCity					City
	,an.NameState					[State]
	,an.NameZipcode					Zip
	,CASE WHEN an.NameEmail LIKE '%@%' AND RIGHT(an.NameEmail,4) LIKE '.%' THEN an.NameEmail 
	  ELSE NULL END 				Email 
	,CAST(CASE WHEN an.NameHomePhone IS NOT NULL THEN an.NameHomePhone
		WHEN an.NameHomePhone IS NULL AND an.NameMobilePhone IS NOT NULL THEN an.NameMobilePhone
		WHEN an.NameHomePhone IS NULL AND an.NameMobilePhone IS NULL THEN an.NameWorkPhone
	  ELSE NULL END AS VARCHAR(12))				Phone
	,''								BusninessName_CompanyName
	,''								TaxID_EIN
	,CAST(CAST(an.NameBirthdate As DATE) As VARCHAR(10)) 	DateOfBirth
	,''								BillingBranch			--RIGHT(CONCAT('00000',aa.AccountBranch),5)
	,''								BillToAccountNumber		
	,''								BillToAccountNumberType
	,'IDR'	As 	DeluxeProductCode
FROM ARCUSYM000.arcu.vwARCUName an 
	INNER JOIN ARCUSYM000.arcu.vwARCUAccount aa ON an.AccountNumber = aa.AccountNumber  AND an.ProcessDate = aa.ProcessDate
WHERE --an.NameType = 0	AND 
	an.ProcessDate = (SELECT processdate FROM ARCUSYM000.dbo.ufnARCUGetLatestProcessDate())
	AND an.AccountNumber NOT IN ('0000390711')
	AND aa.AccountCloseDate IS NULL    
	AND an.NameUserDate1 IS NOT NULL    	
	AND an.NameBirthdate IS NOT NULL
) T1
WHERE T1.RowNum = 1

END