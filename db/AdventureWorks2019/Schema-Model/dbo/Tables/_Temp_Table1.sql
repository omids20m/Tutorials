﻿/*
    This script was generated by SQL Change Automation to help provide object-level history. This script should never be edited manually.
    For more information see: https://www.red-gate.com/sca/dev/offline-schema-model
*/

CREATE TABLE [dbo].[_Temp_Table1]
(
[Id] [int] NOT NULL,
[Title] [nvarchar] (50) NOT NULL
)
GO
ALTER TABLE [dbo].[_Temp_Table1] ADD CONSTRAINT [PK__Temp_Table1] PRIMARY KEY CLUSTERED ([Id])
GO
