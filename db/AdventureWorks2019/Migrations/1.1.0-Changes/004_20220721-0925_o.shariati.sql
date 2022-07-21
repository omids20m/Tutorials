-- <Migration ID="73861a65-bd20-4289-8ee9-33fed28b6eaf" />
GO

PRINT N'Creating [dbo].[Temp_Table2]'
GO
CREATE TABLE [dbo].[Temp_Table2]
(
[Id] [int] NOT NULL,
[Field1] [nchar] (10) NULL
)
GO
PRINT N'Creating primary key [PK_Temp_Table2] on [dbo].[Temp_Table2]'
GO
ALTER TABLE [dbo].[Temp_Table2] ADD CONSTRAINT [PK_Temp_Table2] PRIMARY KEY CLUSTERED ([Id])
GO
