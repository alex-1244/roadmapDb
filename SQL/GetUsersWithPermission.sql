USE roadmapDb;

DELETE FROM BlogPosts
DELETE FROM RolesPermissions
DELETE FROM Permissions
DELETE FROM UserGroups
DELETE FROM UserRoles
DELETE FROM GroupRoles

DBCC CHECKIDENT ('[Permissions]', RESEED, 0);

DBCC CHECKIDENT ('[Roles]', RESEED, 0);
DELETE FROM Roles

DBCC CHECKIDENT ('[Users]', RESEED, 0);
DELETE FROM Users

INSERT INTO Users(Firstname, Lastname, Phone, Email)
VALUES
	('Alex', '', '', ''),
	('Alex1', '', '', '')

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
	(2, 4)

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

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[GetUsersRoles]') AND type IN (N'IF')) 
BEGIN 
   DROP FUNCTION dbo.GetUsersRoles 
END 
GO

CREATE FUNCTION dbo.GetUsersRoles() 
RETURNS TABLE 
AS 
RETURN (
WITH GetParentGroups(GroupId, UserId)
	AS
	(
		SELECT UserGroups.GroupId, UserGroups.UserId FROM UserGroups
		UNION ALL
		SELECT 
			Groups.ParentGroupId, UserGroups.UserId 
		FROM 
			Groups JOIN UserGroups ON Groups.ParentGroupId = UserGroups.GroupId OR Groups.Id = UserGroups.GroupId
		WHERE 
			ParentGroupId IN (SELECT ParentGroupId FROM Groups WHERE Id IN (SELECT Id From UserGroups))
		UNION ALL
			
		SELECT
			ParentGroupId, GetParentGroups.UserId
		FROM
			Groups
		INNER JOIN GetParentGroups
		ON Id = GetParentGroups.GroupId
	)

SELECT 
	DISTINCT GetParentGroups.GroupId, GetParentGroups.UserId
FROM 
	GetParentGroups 
		JOIN Groups ON GetParentGroups.GroupId = Groups.Id
)
GO

SELECT 
	DISTINCT RolesForUser.UserId, RolesPermissions.PermissionId, RolesPermissions.IsAllowed
FROM 
	RolesPermissions
	INNER JOIN 
	(SELECT 
		GroupRoles.RoleId, GroupsForUser.UserId
	FROM 
		GroupRoles 
	INNER JOIN 
		GetUsersRoles() as GroupsForUser
	ON GroupRoles.GroupId = GroupsForUser.GroupId
UNION ALL
	SELECT 
		UserRoles.RoleId, UserRoles.UserId
	FROM 
		UserRoles) as RolesForUser
ON RolesPermissions.RoleId = RolesForUser.RoleId 
WHERE PermissionId = 1
AND IsAllowed = 1
