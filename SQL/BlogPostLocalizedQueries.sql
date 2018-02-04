USE roadmapDb;

DELETE FROM BlogPostsLocalized;
DELETE FROM BlogPosts;
DELETE FROM Users;
DELETE FROM Languages;

DBCC CHECKIDENT ('[BlogPosts]', RESEED, 0);
DBCC CHECKIDENT ('[Users]', RESEED, 0);
GO

INSERT INTO Languages(
	LanguageCode)
VALUES
	('en-US'),
	('ru-RU')

INSERT INTO Users(
	Firstname,
	Lastname,
	Email,
	Phone)
VALUES 
	('Alex', 'Tert', 'alex112244@gmail.com', '+380665804855'),
	('Sergey', 'Migun', 'sergfreest@smth.com', '+380112233444'),
	('Kate', 'Lips', 'kate@gmail.com', '+380112233445')

INSERT INTO BlogPosts(
	AuthorId,
	Date,
	Rating)
VALUES
	(1, '2018-01-01', 5),
	(2, '2018-01-05', 4),
	(3, '2018-01-10', 4)

INSERT INTO BlogPostsLocalized(
	BlogPostId,
	LanguageCode,
	Title,
	Body)
VALUES
	(1, 'en-US', 'English title for first post', 'English body of post number 1'),
	(1, 'ru-RU', 'Рашн тайтл фор ферст пост', 'Рашин боди для первого поста'),
	(2, 'en-US', 'English title for second post', 'English body of post number 2'),
	(1, 'ru-RU', 'Рашн тайтл фор второй пост', 'Рашин боди для второго поста')
GO

IF object_id('GetBlogPostLocalized') IS NOT NULL
    DROP PROC GetBlogPostLocalized
GO

CREATE PROCEDURE dbo.GetBlogPostLocalized 
	@BlogId int,
	@Language nvarchar(6)
AS
	SELECT bpl.Title, bpl.Body
		FROM BlogPosts as bp
			JOIN BlogPostsLocalized as bpl
			ON bp.Id = bpl.BlogPostId
	WHERE bpl.BlogPostId = @BlogId AND bpl.LanguageCode = @Language
GO

IF object_id('GetBlogPostsLocalized') IS NOT NULL
    DROP PROC GetBlogPostsLocalized
GO

CREATE PROCEDURE dbo.GetBlogPostsLocalized
	@Language nvarchar(6),
	@Skip int = 0,
	@Take int = 0
AS
	IF @Take = 0
	BEGIN
		select @Take = Count(*) + 1 FROM BlogPosts
	END

	DECLARE @MaxNumber int
	select @MaxNumber = Count(*) FROM BlogPosts
	SELECT bpl.Title, bpl.Body
		FROM BlogPosts as bp
			JOIN BlogPostsLocalized as bpl
			ON bp.Id = bpl.BlogPostId
	WHERE bpl.LanguageCode = @Language
	ORDER BY bp.Id
	OFFSET     @Skip ROWS      
	FETCH NEXT @Take ROWS ONLY
GO

EXEC GetBlogPostLocalized 1, 'en-US';
EXEC dbo.GetBlogPostsLocalized 'en-US';