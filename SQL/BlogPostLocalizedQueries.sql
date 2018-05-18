-- 1, 2

USE roadmapDB;

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
	('ru-RU'),
	('sp-SP')

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
	(2, 'ru-RU', 'Рашн тайтл фор второй пост', 'Рашин боди для второго поста')
GO

IF object_id('GetBlogPostsLocalized') IS NOT NULL
    DROP PROC GetBlogPostsLocalized
GO

CREATE PROCEDURE dbo.GetBlogPostsLocalized
	@Language nvarchar(6),
	@Skip int = 0,
	@Take int = 100
AS
	SELECT bp.Id, bpl.Title, bpl.Body
		FROM BlogPosts as bp
			LEFT JOIN BlogPostsLocalized as bpl
			ON bp.Id = bpl.BlogPostId
	WHERE bpl.LanguageCode = @Language OR bpl.LanguageCode IS NULL
	ORDER BY bp.Id
	OFFSET     @Skip ROWS      
	FETCH NEXT @Take ROWS ONLY
GO

IF object_id('GetBlogPostLocalized') IS NOT NULL
    DROP PROC GetBlogPostLocalized
GO

CREATE PROCEDURE dbo.GetBlogPostLocalized 
	@BlogId int
AS
	SELECT bp.Id, ln.LanguageCode, bpl.Title, bpl.Body
		FROM BlogPosts as bp
			CROSS JOIN Languages as ln
			LEFT JOIN BlogPostsLocalized as bpl 
				ON bpl.BlogPostId = bp.Id AND bpl.LanguageCode = ln.LanguageCode
	WHERE bp.Id = @BlogId
GO

EXEC dbo.GetBlogPostsLocalized 'en-US';
EXEC GetBlogPostLocalized 1;