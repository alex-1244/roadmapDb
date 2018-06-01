DELETE FROM UserCredentials;

DBCC CHECKIDENT ('[Users]', RESEED, 0);
DELETE FROM Users

INSERT INTO Users(Firstname, Lastname, Phone, Email)
VALUES
	('Alex1', '', '', ''),
	('Alex2', '', '', ''),
	('Alex3', '', '', ''),
	('Alex4', '', '', ''),
	('Alex5', '', '', '')

IF object_id('CreateorUpdateUserCredentials') IS NOT NULL
    DROP PROC CreateorUpdateUserCredentials
GO

DROP TYPE IF EXISTS dbo.users

CREATE TYPE users AS TABLE
(
      UserId VARCHAR(50) NULL,
      LoginName VARCHAR(50),
      Password VARCHAR(50)
)
GO

CREATE PROCEDURE dbo.CreateorUpdateUserCredentials 
	@Users users readonly
AS
	MERGE UserCredentials AS TARGET
	USING @Users AS SOURCE
		ON (TARGET.UserId = SOURCE.UserId)
	WHEN MATCHED THEN
		UPDATE SET 
			TARGET.LoginName = SOURCE.LoginName,
			TARGET.Password = CONVERT(VARCHAR(32),HashBytes('SHA2_512', SOURCE.Password),2)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (UserId, LoginName, Password)
		VALUES (SOURCE.UserId, SOURCE.LoginName, CONVERT(VARCHAR(32),HashBytes('SHA2_512', SOURCE.Password),2));
GO

DECLARE @users users

--insert records into typeEmplyee type variable 

INSERT INTO @users(UserId,LoginName,Password)
VALUES  (1, 'log1','pass1'),
        (2, 'log2','pass2'),
		(3, 'log3','pass3'),
		(4, 'log4','pass4')

EXEC CreateorUpdateUserCredentials  @users

DECLARE @usersNew users

--insert records into typeEmplyee type variable 

INSERT INTO @usersNew(UserId,LoginName,Password)
VALUES  (4, 'log4_new','pass41'),
        (5, 'log5','pass5')

EXEC CreateorUpdateUserCredentials  @usersNew

SELECT * FROM UserCredentials
