-- =============================================
-- RevisionTracker : données de départ (ton vrai plan)
-- Ré-exécutable : n'insère que ce qui manque
-- =============================================
USE RevisionTracker;
GO

MERGE dbo.Topics AS t
USING (VALUES
    (N'Git',               N'CICD',   N'DONE'),
    (N'GitHub Actions',    N'CICD',   N'IN_PROGRESS'),
    (N'Docker',            N'CICD',   N'TODO'),
    (N'Jenkins',           N'CICD',   N'TODO'),
    (N'Kubernetes',        N'CICD',   N'TODO'),
    (N'C# / .NET',         N'DOTNET', N'TODO'),
    (N'API REST',          N'DOTNET', N'TODO'),
    (N'SQL Server',        N'SQL',    N'TODO'),
    (N'React',             N'REACT',  N'TODO')
) AS s (Name, Block, Status)
ON t.Name = s.Name
WHEN NOT MATCHED THEN
    INSERT (Name, Block, Status) VALUES (s.Name, s.Block, s.Status);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Sessions)
INSERT INTO dbo.Sessions (TopicId, SessionDate, DurationMinutes, Notes)
SELECT Id, '2026-11-05', 180, N'Mémo Git 2 pages A4' FROM dbo.Topics WHERE Name = N'Git'
UNION ALL
SELECT Id, '2026-11-08', 120, N'Création du projet RevisionTracker' FROM dbo.Topics WHERE Name = N'GitHub Actions';
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Katas)
INSERT INTO dbo.Katas (TopicId, Title, Difficulty, IsDone)
SELECT Id, N'Premier workflow CI : build + tests', 2, 0 FROM dbo.Topics WHERE Name = N'GitHub Actions'
UNION ALL
SELECT Id, N'Dockerfile multi-stage pour l''API', 3, 0 FROM dbo.Topics WHERE Name = N'Docker';
GO
