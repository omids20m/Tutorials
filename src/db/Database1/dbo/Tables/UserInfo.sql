CREATE TABLE [dbo].[UserInfo] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (50)   NOT NULL,
    [LastName]    NVARCHAR (50)   NOT NULL,
    [Title]       NVARCHAR (50)   NULL,
    [Description] NVARCHAR (4000) NULL,
    CONSTRAINT [PK_UserInfo] PRIMARY KEY CLUSTERED ([Id] ASC)
);

