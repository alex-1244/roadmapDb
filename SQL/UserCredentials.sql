DELETE FROM UserCredentials;

IF object_id('CreateUserCredentials') IS NOT NULL
    DROP PROC CreateUserCredentials
GO

CREATE PROCEDURE dbo.CreateUserCredentials 
	@UserId int,
	@Login nvarchar(50),
	@Password nvarchar(50)
AS
	INSERT 
		INTO UserCredentials(UserId, LoginName, Password)
	VALUES
		(@UserId, @Login, CONVERT(VARCHAR(32),HashBytes('SHA2_512', @Password),2))
GO

IF object_id('ValidateUserCredentials') IS NOT NULL
    DROP PROC ValidateUserCredentials
GO

CREATE PROCEDURE dbo.ValidateUserCredentials
	@Login nvarchar(50),
	@Password nvarchar(50)
AS
	IF((SELECT COUNT(*) FROM	
			UserCredentials as uc
		WHERE
			uc.LoginName = @Login
			AND uc.Password = CONVERT(VARCHAR(32),HashBytes('SHA2_512', @Password),2)) = 1)
	BEGIN
		RETURN
	END ELSE BEGIN
		;THROW 50030, 'User does not exist', 1
	END
GO

EXEC dbo.CreateUserCredentials 1, 'Alex_T', 'password12';
-- uncomnt to get error (uer logi must be unique)
--EXEC dbo.CreateUserCredentials 1, 'Alex_T', 'password11';

EXEC dbo.ValidateUserCredentials 'Alex_T', 'password12';
-- ucommit to raise error about unexisting user
--EXEC dbo.ValidateUserCredentials 'Alex_T', 'password123';