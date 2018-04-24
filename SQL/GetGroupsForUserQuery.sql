-- 8

USE roadmapDb;

DELETE FROM UserGroups

DBCC CHECKIDENT ('[Users]', RESEED, 0);
DELETE FROM Users

INSERT INTO Users(Firstname, Lastname, Phone, Email)
VALUES
	('Alex', '', '', '')

DBCC CHECKIDENT ('[Groups]', RESEED, 0);
DELETE FROM GROUPS

INSERT INTO Groups(ParentGroupId, Name)
VALUES
	(NULL, 'BaseGroup'),
	(1, 'ChildOf_Base_1'),
	(1, 'ChildOf_Base_2'),
	(2, 'ChildOf_1_3'),
	(4, 'ChildOf_3_4'),
	(NULL, 'AnotherBase'),
	(6, 'ChildOf_AnotherBase_1')
GO

INSERT INTO UserGroups(UserId, GroupId)
VALUES
	(1, 3),
	(1, 7)

IF object_id('GetUserGroups') IS NOT NULL
    DROP PROC GetUserGroups
GO

CREATE PROCEDURE dbo.GetUserGroups 
	@UserId int
AS
	Declare @GroupIds TABLE (Id INT);
	INSERT @GroupIds Select UserGroups.GroupId FROM UserGroups WHERE UserGroups.UserId = @UserId

	;WITH GetParentGroups(GroupId)
		AS
		(
			SELECT Id FROM @GroupIds
			UNION ALL
			SELECT 
				ParentGroupId 
			FROM 
				Groups
			WHERE 
				ParentGroupId IN (SELECT ParentGroupId FROM Groups WHERE Id IN (SELECT Id From @GroupIds))
			UNION ALL
				
			SELECT
				ParentGroupId
			FROM
				Groups
			INNER JOIN GetParentGroups
			ON Id = GetParentGroups.GroupId
		)

	SELECT DISTINCT GetParentGroups.GroupId, Groups.Name FROM GetParentGroups JOIN Groups ON GetParentGroups.GroupId = Groups.Id
GO

GetUserGroups 1
SELECT * FROM Groups