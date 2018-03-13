USE roadmapDb;

DELETE FROM RolesPermissions
DELETE FROM Permissions
DELETE FROM UserGroups
DELETE FROM UserRoles
DELETE FROM GroupRoles
DELETE FROM Roles

DBCC CHECKIDENT ('[Permissions]', RESEED, 0);

DBCC CHECKIDENT ('[Roles]', RESEED, 0);
DELETE FROM Roles

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

INSERT INTO Roles(Name)
VALUES
	('Administrate'),
	('CreatePosts'),
	('DeletePosts'),
	('BlockUsers'),
	('DontGiveAFuck')

INSERT INTO Permissions(Name)
VALUES
	('Permission1'),
	('Permission2'),
	('Permission3'),
	('Permission4')

INSERT INTO RolesPermissions(RoleId, PermissionId, IsAllowed)
VALUES
	(1, 1, 1),
	(1, 2, 0),
	(2, 2, 1),
	(2, 4, 1)

IF object_id('GetUserGroups') IS NULL
    PRINT 'GetUserGroups procedure was not found, please open file GetGroupsForUserQuery.sql to create it.'
GO

INSERT INTO UserRoles(UserId, RoleId)
VALUES
	(1, 5)

INSERT INTO GroupRoles(GroupId, RoleId)
VALUES
	(1, 1),
	(3, 2),
	(6, 3)
GO

IF object_id('GetUserPermissions') IS NOT NULL
    DROP PROC GetUserPermissions
GO

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[GetUserRoles]') AND type IN (N'IF')) 
BEGIN 
   DROP FUNCTION dbo.GetUserRoles 
END 
GO

CREATE FUNCTION dbo.GetUserRoles(@UserId AS INT)  
RETURNS TABLE 
AS 
RETURN (
	SELECT 
		DISTINCT RolesForUser.RoleId 
	FROM (
		SELECT * FROM dbo.GetUserGroupRoles(@UserId)
	UNION ALL
		SELECT 
			UserRoles.RoleId 
		FROM 
			UserRoles 
		JOIN Roles 
		ON UserRoles.UserId = @UserId
	)
	as RolesForUser
)
GO

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[GetUserGroupRoles]') AND type IN (N'IF')) 
BEGIN 
   DROP FUNCTION dbo.GetUserGroupRoles 
END 
GO

CREATE FUNCTION dbo.GetUserGroupRoles(@UserId AS INT)  
RETURNS TABLE 
AS 
RETURN (	
	WITH GetParentGroups(GroupId)
		AS (
			SELECT UserGroups.GroupId FROM UserGroups WHERE UserGroups.UserId = @UserId
			UNION ALL
			SELECT 
				ParentGroupId 
			FROM 
				Groups
			WHERE 
				ParentGroupId IN (SELECT ParentGroupId FROM Groups WHERE Id IN (SELECT UserGroups.GroupId FROM UserGroups WHERE UserGroups.UserId = @UserId))
			UNION ALL
				
			SELECT
				ParentGroupId
			FROM
				Groups
			INNER JOIN GetParentGroups
			ON Id = GetParentGroups.GroupId
		)

		SELECT 
			GroupRoles.RoleId 
		FROM 
			GroupRoles 
		INNER JOIN 
			(SELECT 
				DISTINCT GetParentGroups.GroupId 
			FROM 
				GetParentGroups 
			JOIN Groups ON GetParentGroups.GroupId = Groups.Id) as GroupsForUser 
		ON GroupRoles.GroupId = GroupsForUser.GroupId
)
GO

CREATE PROCEDURE dbo.GetUserPermissions
	@UserId int
AS
	SELECT 
		DISTINCT Permissions.Id, Permissions.Name 
	FROM
		Permissions 
	INNER JOIN 
		RolesPermissions 
	ON Permissions.Id = RolesPermissions.PermissionId
	WHERE 
		RolesPermissions.IsAllowed = 1
		AND 
			RolesPermissions.RoleId 
		IN (
			SELECT * FROM GetUserGroupRoles(@UserId)
		)
GO

GetUserPermissions 1
