-- <Migration ID="314b9cae-a0bb-491b-989c-e4888446f743" />
GO

PRINT N'Creating [dbo].[_Temp_Table1]'
GO
CREATE TABLE [dbo].[_Temp_Table1]
(
[Id] [int] NOT NULL,
[Title] [nvarchar] (50) NOT NULL
)
GO
PRINT N'Creating primary key [PK__Temp_Table1] on [dbo].[_Temp_Table1]'
GO
ALTER TABLE [dbo].[_Temp_Table1] ADD CONSTRAINT [PK__Temp_Table1] PRIMARY KEY CLUSTERED ([Id])
GO

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;

SET DATEFORMAT YMD;


GO
PRINT (N'Add 1 row to [Person].[PhoneNumberType]');

SET IDENTITY_INSERT [Person].[PhoneNumberType] ON;

INSERT  INTO [Person].[PhoneNumberType] ([PhoneNumberTypeID], [Name], [ModifiedDate])
VALUES                                 (4, N'WorkCell', '2022-07-19 00:00:00.000');

SET IDENTITY_INSERT [Person].[PhoneNumberType] OFF;


GO