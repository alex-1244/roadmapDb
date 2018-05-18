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

;WITH GetChildGroups(GroupId)
AS
(
	SELECT Id 
		FROM Groups
		WHERE ParentGroupId IN (SELECT Id FROM deleted)
	UNION ALL
	SELECT Id
		FROM Groups
			INNER JOIN GetChildGroups
			ON ParentGroupId = GetChildGroups.GroupId
)

	DELETE FROM Groups
	WHERE (Groups.Id in (SELECT GroupId FROM GetChildGroups)) OR (Groups.Id IN (SELECT Id FROM deleted))

GO

	DELETE FROM Groups
	WHERE Id = 1
