﻿/*
    This script was generated by SQL Change Automation to help provide object-level history. This script should never be edited manually.
    For more information see: https://www.red-gate.com/sca/dev/offline-schema-model
*/

IF TYPE_ID('[dbo].[OrderNumber]') IS NOT NULL
	DROP TYPE [dbo].[OrderNumber];

GO
CREATE TYPE [dbo].[OrderNumber] FROM nvarchar (25) NULL
GO
