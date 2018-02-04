USE roadmapDb;

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


DECLARE @GroupId INT
SET @GroupId = 5
;WITH GetParentGroups(GroupId)
AS
(
	SELECT 
		ParentGroupId 
	FROM 
		Groups
	WHERE 
		ParentGroupId IN (SELECT ParentGroupId FROM Groups WHERE Id = @GroupId)
	UNION ALL
		
	SELECT
		ParentGroupId
	FROM
		Groups
	INNER JOIN GetParentGroups
	ON Id = GetParentGroups.GroupId
)

Select * FROM GetParentGroups;
SELECT * FROM Groups;

GO

DECLARE @BaseGroupId INT
SET @BaseGroupId = 2

;WITH GetChildGroups(GroupId)
AS
(
	SELECT 
		Id 
	FROM 
		Groups
	WHERE 
		ParentGroupId = @BaseGroupId
	UNION ALL
		
	SELECT
		Id
	FROM
		Groups
	INNER JOIN GetChildGroups
	ON ParentGroupId = GetChildGroups.GroupId
)

Select * FROM GetChildGroups;
SELECT * FROM Groups;