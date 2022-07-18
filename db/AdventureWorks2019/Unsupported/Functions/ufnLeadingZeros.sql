IF OBJECT_ID('[dbo].[ufnLeadingZeros]') IS NOT NULL
	DROP FUNCTION [dbo].[ufnLeadingZeros];

GO
/*
	Unsupported Programmable Object
	-------------------------------
	This script was placed in the Unsupported folder during the initial import process as it
	contains a type of object that requires special handling. This has been done to prevent
	the script from failing during the script-generation and database deployment processes.

	In order to include the script within the Programmable Objects folder, some modifications
	will need to be made to ensure that it executes successfully. For more information,
	please refer to the documentation:
	https://www.red-gate.com/sca/dev/unsupported-programmable-objects
*/

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ufnLeadingZeros](
    @Value int
) 
RETURNS varchar(8) 
WITH SCHEMABINDING 
AS 
BEGIN
    DECLARE @ReturnValue varchar(8);

    SET @ReturnValue = CONVERT(varchar(8), @Value);
    SET @ReturnValue = REPLICATE('0', 8 - DATALENGTH(@ReturnValue)) + @ReturnValue;

    RETURN (@ReturnValue);
END;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Scalar function used by the Sales.Customer table to help set the account number.', 'SCHEMA', N'dbo', 'FUNCTION', N'ufnLeadingZeros', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Input parameter for the scalar function ufnLeadingZeros. Enter a valid integer.', 'SCHEMA', N'dbo', 'FUNCTION', N'ufnLeadingZeros', 'PARAMETER', N'@Value'
GO
