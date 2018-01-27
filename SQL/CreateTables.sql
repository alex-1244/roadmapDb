USE master;

DECLARE @dbname nvarchar(128)
SET @dbname = N'roadmapDb'

IF (
	NOT EXISTS (
		SELECT 
			name 
		FROM 
			master.dbo.sysdatabases 
		WHERE 
			('[' + name + ']' = @dbname OR name = @dbname)))
	EXEC('CREATE DATABASE ' + @dbname);
GO

USE roadmapDb;

IF OBJECT_ID(N'dbo.[UserCredentials]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[UserCredentials]
		DROP CONSTRAINT Fk_UserId_User
END

IF OBJECT_ID(N'dbo.[BlogPosts]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[BlogPosts]
		DROP CONSTRAINT Fk_Users
END

IF OBJECT_ID(N'dbo.[UserRoles]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[UserRoles]
		DROP CONSTRAINT Fk_UserRoles_User
END

IF OBJECT_ID(N'dbo.[UserGroups]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[UserGroups]
		DROP CONSTRAINT Fk_UserGroups_User
END

DROP TABLE IF EXISTS dbo.Users;

CREATE TABLE [Users](
	Id int NOT NULL IDENTITY(1,1),
	Firstname nvarchar(50) NOT NULL,
	Lastname nvarchar(50) NOT NULL,
	Email nvarchar(50) NOT NULL,
	Phone nvarchar(20) NOT NULL,
	CONSTRAINT Pk_Users PRIMARY KEY (Id)
)

IF OBJECT_ID(N'dbo.[BlogPostsLocalized]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[BlogPostsLocalized]
		DROP CONSTRAINT Fk_Languages
END

DROP TABLE IF EXISTS dbo.[Languages];

CREATE TABLE [Languages](
	LanguageCode nvarchar(6) NOT NULL,
	CONSTRAINT Pk_Languages PRIMARY KEY(LanguageCode)
)

IF OBJECT_ID(N'dbo.[BlogPostsLocalized]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[BlogPostsLocalized]
		DROP CONSTRAINT Fk_BlogPosts
END

DROP TABLE IF EXISTS dbo.[BlogPosts]; 

CREATE TABLE [BlogPosts](
	Id int NOT NULL IDENTITY(1,1),
	AuthorId int NOT NULL,
	Date DateTime2 NOT NULL,
	Rating int NOT NULL,
	CONSTRAINT PK_BlogPosts PRIMARY KEY (Id),
	CONSTRAINT Fk_Users FOREIGN KEY (AuthorId) REFERENCES Users(Id)
);

DROP TABLE IF EXISTS dbo.[BlogPostsLocalized]

CREATE TABLE [BlogPostsLocalized](
	BlogPostId int NOT NULL,
	LanguageCode nvarchar(6) NOT NULL,
	Title nvarchar(MAX) NOT NULL,
	Body nvarchar(MAX) NOT NULL,
	CONSTRAINT Fk_BlogPosts FOREIGN KEY (BlogPostId) REFERENCES BlogPosts(Id) ON DELETE CASCADE,
	CONSTRAINT Fk_Languages FOREIGN KEY (LanguageCode) REFERENCES Languages(LanguageCode) ON DELETE CASCADE
)

IF OBJECT_ID(N'dbo.[GroupRoles]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[GroupRoles]
		DROP CONSTRAINT fk_Groups
END

IF OBJECT_ID(N'dbo.[UserGroups]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[UserGroups]
		DROP CONSTRAINT Fk_UserGroups_Group
END

DROP TABLE IF EXISTS dbo.Groups;

CREATE TABLE [Groups](
	Id int NOT NULL IDENTITY(1,1),
	ParentGroupId int,
	Name nvarchar(50) NOT NULL,
	CONSTRAINT Pk_Groups PRIMARY KEY (Id),
	CONSTRAINT Fk_Groups_ParentGroup FOREIGN KEY (ParentGroupId) REFERENCES Groups(Id)
)

DROP TABLE IF EXISTS dbo.UserCredentials;

CREATE TABLE [UserCredentials](
	UserId int NOT NULL,
	LoginName nvarchar(50) NOT NULL,
	Password nvarchar(50) NOT NULL,
	CONSTRAINT Fk_UserId_User FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
)

IF OBJECT_ID(N'dbo.RolesPermissions', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.RolesPermissions
		DROP CONSTRAINT Fk_Roles
END

IF OBJECT_ID(N'dbo.[GroupRoles]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[GroupRoles]
		DROP CONSTRAINT Fk_GroupRoles
END

IF OBJECT_ID(N'dbo.[UserRoles]', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.[UserRoles]
		DROP CONSTRAINT Fk_UserRoles_Role
END

DROP TABLE IF EXISTS dbo.Roles;

CREATE TABLE [Roles](
	Id int NOT NULL IDENTITY(1,1),
	Name nvarchar(50) NOT NULL,
	CONSTRAINT Pk_Roles PRIMARY KEY (Id)
)

IF OBJECT_ID(N'dbo.RolesPermissions', N'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.RolesPermissions
		DROP CONSTRAINT Fk_Permissions
END

DROP TABLE IF EXISTS dbo.[Permissions]

CREATE TABLE [Permissions](
	Id int NOT NULL IDENTITY(1,1),
	Name nvarchar(50) NOT NULL,
	CONSTRAINT Pk_Permissions PRIMARY KEY (Id)
)

DROP TABLE IF EXISTS dbo.RolesPermissions

CREATE TABLE [RolesPermissions](
	RoleId int NOT NULL,
	PermissionId int NOT NULL,
	IsAllowed bit NOT NULL,
	CONSTRAINT Fk_Roles FOREIGN KEY (RoleId) REFERENCES Roles(Id),
	CONSTRAINT Fk_Permissions FOREIGN KEY (PermissionId) REFERENCES [Permissions](Id),
)

DROP TABLE IF EXISTS dbo.GroupRoles

CREATE TABLE [GroupRoles](
	GroupId int NOT NULL,
	RoleId int NOT NULL,
	CONSTRAINT Fk_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id),
	CONSTRAINT Fk_GroupRoles FOREIGN KEY (RoleId) REFERENCES Roles(Id),
)

DROP TABLE IF EXISTS dbo.UserRoles;

CREATE TABLE [UserRoles](
	UserId int NOT NULL,
	RoleId int NOT NULL,
	CONSTRAINT Fk_UserRoles_User FOREIGN KEY (UserId) REFERENCES Users(Id),
	CONSTRAINT Fk_UserRoles_Role FOREIGN KEY (RoleId) REFERENCES Roles(Id)
)

DROP TABLE IF EXISTS dbo.UserGroups;

CREATE TABLE [UserGroups](
	UserId int NOT NULL,
	GroupId int NOT NULL,
	CONSTRAINT Fk_UserGroups_User FOREIGN KEY (UserId) REFERENCES Users(Id),
	CONSTRAINT Fk_UserGroups_Group FOREIGN KEY (GroupId) REFERENCES Groups(Id)
)