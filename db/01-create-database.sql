-- =============================================
-- RevisionTracker : création de la base
-- Exécution : SSMS (F5) ou sqlcmd -S localhost -E -i db\01-create-database.sql
-- Script ré-exécutable (idempotent)
-- =============================================

IF DB_ID(N'RevisionTracker') IS NULL
    CREATE DATABASE RevisionTracker;
GO

USE RevisionTracker;
GO

-- ---------- Topics ----------
IF OBJECT_ID(N'dbo.Topics', N'U') IS NULL
CREATE TABLE dbo.Topics
(
    Id      INT IDENTITY(1,1) NOT NULL,
    Name    NVARCHAR(100)     NOT NULL,
    Block   NVARCHAR(20)      NOT NULL,
    Status  NVARCHAR(20)      NOT NULL CONSTRAINT DF_Topics_Status DEFAULT N'TODO',

    CONSTRAINT PK_Topics        PRIMARY KEY (Id),
    CONSTRAINT UQ_Topics_Name   UNIQUE (Name),
    CONSTRAINT CK_Topics_Block  CHECK (Block  IN (N'CICD', N'DOTNET', N'SQL', N'REACT')),
    CONSTRAINT CK_Topics_Status CHECK (Status IN (N'TODO', N'IN_PROGRESS', N'DONE'))
);
GO

-- ---------- Sessions ----------
IF OBJECT_ID(N'dbo.Sessions', N'U') IS NULL
CREATE TABLE dbo.Sessions
(
    Id              INT IDENTITY(1,1) NOT NULL,
    TopicId         INT               NOT NULL,
    SessionDate     DATE              NOT NULL,
    DurationMinutes INT               NOT NULL,
    Notes           NVARCHAR(MAX)     NULL,

    CONSTRAINT PK_Sessions          PRIMARY KEY (Id),
    CONSTRAINT FK_Sessions_Topics   FOREIGN KEY (TopicId) REFERENCES dbo.Topics (Id) ON DELETE CASCADE,
    CONSTRAINT CK_Sessions_Duration CHECK (DurationMinutes > 0)
);
GO

-- ---------- Katas ----------
IF OBJECT_ID(N'dbo.Katas', N'U') IS NULL
CREATE TABLE dbo.Katas
(
    Id          INT IDENTITY(1,1) NOT NULL,
    TopicId     INT               NOT NULL,
    Title       NVARCHAR(150)     NOT NULL,
    Difficulty  TINYINT           NOT NULL,
    IsDone      BIT               NOT NULL CONSTRAINT DF_Katas_IsDone DEFAULT 0,

    CONSTRAINT PK_Katas            PRIMARY KEY (Id),
    CONSTRAINT FK_Katas_Topics     FOREIGN KEY (TopicId) REFERENCES dbo.Topics (Id) ON DELETE CASCADE,
    CONSTRAINT CK_Katas_Difficulty CHECK (Difficulty BETWEEN 1 AND 5)
);
GO

-- Index sur les clés étrangères (SQL Server ne les crée pas automatiquement)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Sessions_TopicId')
    CREATE INDEX IX_Sessions_TopicId ON dbo.Sessions (TopicId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Katas_TopicId')
    CREATE INDEX IX_Katas_TopicId ON dbo.Katas (TopicId);
GO
