-- 5

USE roadmapDb;

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Delete_Child_Groups]'))
	DROP TRIGGER [dbo].[Delete_Child_Groups]
GO

DBCC CHECKIDENT ('[Groups]', RESEED, 0);
DELETE FROM GROUPS

INSERT INTO Groups(ParentGroupId, Name)
VALUES
	(NULL, 'BaseGroup'),
	(1, 'ChildOf_Base_1'),
	(1, 'ChildOf_Base_2'),
	(2, 'ChildOf_1_3'),
	(4, 'ChildOf_3_4'),
	(NULL, 'AnotherBase')
GO



CREATE TRIGGER Delete_Child_Groups ON Groups INSTEAD OF DELETE
AS
	CREATE TABLE #GroupsToDelete(
        Id    INT
    )
    INSERT INTO #GroupsToDelete (Id)
    SELECT  Id
    FROM    deleted

	DECLARE @c INT
    SET @c = (SELECT COUNT(*) FROM Groups WHERE ParentGroupId IN (Select Id FROM deleted))

	WHILE @c<>0 BEGIN
		INSERT INTO #GroupsToDelete
		SELECT Groups.Id
		FROM Groups
		WHERE Groups.ParentGroupId IS NOT NULL
			AND Groups.ParentGroupId IN (SeLECT Id FROM #GroupsToDelete)
			AND Groups.Id NOT IN (SeLECT Id FROM #GroupsToDelete)
		;
		SELECT @c = (SELECT COUNT(*) FROM Groups WHERE ParentGroupId IN (Select Id FROM #GroupsToDelete) 
			AND Groups.Id NOT IN (SeLECT Id FROM #GroupsToDelete))
	END

	DELETE FROM Groups
	WHERE Groups.Id in (SELECT Id FROM #GroupsToDelete)
GO

DELETE FROM Groups
	WHERE Id = 1