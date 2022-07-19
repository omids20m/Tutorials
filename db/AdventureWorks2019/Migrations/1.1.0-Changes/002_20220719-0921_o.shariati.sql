-- <Migration ID="19f325a6-6426-46e0-b48f-1c775dcc7fa3" />
GO

PRINT N'Dropping constraints from [Production].[Document]'
GO
ALTER TABLE [Production].[Document] DROP CONSTRAINT [UQ__Document__F73921F70D6A716A]
GO
PRINT N'Adding constraints to [Production].[Document]'
GO
ALTER TABLE [Production].[Document] ADD CONSTRAINT [UQ__Document__F73921F7C5112C2E] UNIQUE NONCLUSTERED ([rowguid])
GO

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;

SET DATEFORMAT YMD;


GO
IF (SELECT COUNT(*)
    FROM   [Person].[ContactType]) = 0
    BEGIN
        PRINT (N'Add 20 rows to [Person].[ContactType]');
        SET IDENTITY_INSERT [Person].[ContactType] ON;
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (1, N'Accounting Manager', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (2, N'Assistant Sales Agent', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (3, N'Assistant Sales Representative', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (4, N'Coordinator Foreign Markets', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (5, N'Export Administrator', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (6, N'International Marketing Manager', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (7, N'Marketing Assistant', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (8, N'Marketing Manager', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (9, N'Marketing Representative', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (10, N'Order Administrator', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (11, N'Owner', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (12, N'Owner/Marketing Assistant', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (13, N'Product Manager', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (14, N'Purchasing Agent', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (15, N'Purchasing Manager', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (16, N'Regional Account Representative', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (17, N'Sales Agent', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (18, N'Sales Associate', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (19, N'Sales Manager', '2008-04-30 00:00:00.000');
        INSERT  INTO [Person].[ContactType] ([ContactTypeID], [Name], [ModifiedDate])
        VALUES                             (20, N'Sales Representative', '2008-04-30 00:00:00.000');
        SET IDENTITY_INSERT [Person].[ContactType] OFF;
    END


GO
IF (SELECT COUNT(*)
    FROM   [Person].[PhoneNumberType]) = 0
    BEGIN
        PRINT (N'Add 3 rows to [Person].[PhoneNumberType]');
        SET IDENTITY_INSERT [Person].[PhoneNumberType] ON;
        INSERT  INTO [Person].[PhoneNumberType] ([PhoneNumberTypeID], [Name], [ModifiedDate])
        VALUES                                 (1, N'Cell', '2017-12-13 13:19:22.273');
        INSERT  INTO [Person].[PhoneNumberType] ([PhoneNumberTypeID], [Name], [ModifiedDate])
        VALUES                                 (2, N'Home', '2017-12-13 13:19:22.273');
        INSERT  INTO [Person].[PhoneNumberType] ([PhoneNumberTypeID], [Name], [ModifiedDate])
        VALUES                                 (3, N'Work', '2017-12-13 13:19:22.273');
        SET IDENTITY_INSERT [Person].[PhoneNumberType] OFF;
    END


GO