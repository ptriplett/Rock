/*

	1.) Make all the dashboards context setters be in this order:
		Campus, Group, Service, and then Date

	2.) Set group type for each dashboard's group context setter

	3.) Arrange the blocks on each dashboard in a preset order

*/

-- Declare functions
IF OBJECT_ID('clearPageOfMetrics') IS NOT NULL DROP PROCEDURE clearPageOfMetrics;
GO

CREATE PROCEDURE clearPageOfMetrics (
	@pageName NVARCHAR(100)
) AS
	DECLARE @metricBlockTypeId AS INT = (SELECT Id FROM BlockType WHERE Name = 'Ministry Metrics' AND Category = 'NewSpring');
	DECLARE @blockEntityTypeId AS INT = (SELECT Id FROM EntityType WHERE Name = 'Rock.Model.Block');

	IF OBJECT_ID('tempdb..#tempMetricBlockAttributes') IS NOT NULL DROP TABLE #tempMetricBlockAttributes;
	SELECT 
		* 
	INTO
		#tempMetricBlockAttributes
	FROM 
		Attribute
	WHERE 
		EntityTypeId = @blockEntityTypeId 
		AND EntityTypeQualifierColumn = 'BlockTypeId'
		AND EntityTypeQualifierValue = @metricBlockTypeId;

	DECLARE @pageId AS INT = (SELECT Id FROM [Page] WHERE InternalName = @pageName);

	DELETE FROM AttributeValue WHERE Id IN (
		SELECT 
			av.Id 
		FROM 
			AttributeValue av
			JOIN #tempMetricBlockAttributes a ON av.AttributeId = a.Id
			JOIN [Block] b ON b.Id = av.EntityId
		WHERE
			b.PageId = @pageId
	);

	DELETE FROM Block WHERE PageId = @pageId AND Zone = 'SectionB';
	DROP TABLE #tempMetricBlockAttributes;
	RETURN @pageId;
GO

IF OBJECT_ID('insertMetricBlockAttributeValues') IS NOT NULL DROP PROCEDURE insertMetricBlockAttributeValues;
GO

CREATE PROCEDURE insertMetricBlockAttributeValues (
    @attributeId INT, 
    @blockId INT,
	@value NVARCHAR(100)
) AS
	INSERT INTO AttributeValue (
		IsSystem,
		AttributeId,
		EntityId,
		Value,
		[Guid]
	)
	VALUES (0, @attributeId, @blockId, @value, NEWID());
	RETURN SCOPE_IDENTITY();
GO

IF OBJECT_ID('insertMetricBlock') IS NOT NULL DROP PROCEDURE insertMetricBlock;
GO

CREATE PROCEDURE insertMetricBlock (
    @pageId INT, 
    @order INT,
	@name NVARCHAR(100),
	@cols NVARCHAR(100),
	@type NVARCHAR(100),
	@key NVARCHAR(100),
	@metricTitle NVARCHAR(100),
	@catName NVARCHAR(100),
	@compKey NVARCHAR(100),
	@compMetricTitle NVARCHAR(100),
	@compCatName NVARCHAR(100),
	@compType NVARCHAR(100)
) AS
	DECLARE @source AS NVARCHAR(100) = '';
	DECLARE @compSource AS NVARCHAR(100) = '';
	DECLARE @attributeId AS INT;
	DECLARE @metricBlockTypeId AS INT = (SELECT Id FROM BlockType WHERE Name = 'Ministry Metrics' AND Category = 'NewSpring');
	DECLARE @blockEntityTypeId AS INT = (SELECT Id FROM EntityType WHERE Name = 'Rock.Model.Block');

	SELECT
		@source = CONCAT(m.[Guid], '|', c.[Guid])
	FROM
		Metric m
		JOIN MetricCategory mc ON m.Id = mc.MetricId
		JOIN Category c ON mc.CategoryId = c.Id
	WHERE
		c.Name = @catName
		AND m.Title = @metricTitle;

	SELECT
		@compSource = CONCAT(m.[Guid], '|', c.[Guid])
	FROM
		Metric m
		JOIN MetricCategory mc ON m.Id = mc.MetricId
		JOIN Category c ON mc.CategoryId = c.Id
	WHERE
		c.Name = @compCatName
		AND m.Title = @compMetricTitle;

	IF OBJECT_ID('tempdb..#tempMetricBlockAttributes') IS NOT NULL DROP TABLE #tempMetricBlockAttributes;
	SELECT 
		* 
	INTO
		#tempMetricBlockAttributes
	FROM 
		Attribute
	WHERE 
		EntityTypeId = @blockEntityTypeId 
		AND EntityTypeQualifierColumn = 'BlockTypeId'
		AND EntityTypeQualifierValue = @metricBlockTypeId;

	INSERT INTO Block (
		IsSystem,
		PageId,
		BlockTypeId,
		Zone,
		[Order],
		Name,
		OutputCacheDuration,
		[Guid]
	)
	VALUES (0, @pageId, (SELECT Id FROM BlockType WHERE Name = 'Ministry Metrics' AND Category = 'NewSpring'), 'SectionB', @order, @name, 0, NEWID());
	DECLARE @blockId AS INT = SCOPE_IDENTITY();

	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 1;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, @cols;
	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 2;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, @type;
	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 3;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, @key;
	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 4;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, @source;
	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 5;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, @compKey;
	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 6;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, @compSource;
	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 7;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, @compType;
	SELECT @attributeId = Id FROM #tempMetricBlockAttributes WHERE [Order] = 8;
	EXEC insertMetricBlockAttributeValues @attributeId, @blockId, 'Page';

	DROP TABLE #tempMetricBlockAttributes;
GO

-- Vars
DECLARE @blockEntityTypeId AS INT = (SELECT Id FROM EntityType WHERE Name = 'Rock.Model.Block');

-- Re/create temp table that stores the context setter blocks on the dashboard pages
IF OBJECT_ID('tempdb..#tempContextSetters') IS NOT NULL DROP TABLE #tempContextSetters;

SELECT 
	p.Id as PageId,
	b.Id as BlockId
INTO 
	#tempContextSetters
FROM 
	Block b
	JOIN [Page] p ON p.Id = b.PageId 
	JOIN BlockType bt ON b.BlockTypeId = bt.Id
WHERE 
	p.InternalName LIKE '% Dashboard'
	AND p.InternalName <> 'My Dashboard'
	AND bt.Name LIKE '% Context Setter';

-- Update Campus context setter to be order 0
UPDATE
	b
SET
	b.[Order] = 0
FROM
	Block b
	JOIN #tempContextSetters t ON t.BlockId = b.Id
WHERE
	b.Name = 'Campus Context Setter';

-- Update group context setter to be order 1
UPDATE
	b
SET
	b.[Order] = 1
FROM
	Block b
	JOIN #tempContextSetters t ON t.BlockId = b.Id
WHERE
	b.Name = 'Group Context Setter';

-- Update service context setter to be order 2
UPDATE
	b
SET
	b.[Order] = 2
FROM
	Block b
	JOIN #tempContextSetters t ON t.BlockId = b.Id
WHERE
	b.Name = 'Schedule Context Setter';

-- Update date range context setter to be order 3
UPDATE
	b
SET
	b.[Order] = 3
FROM
	Block b
	JOIN #tempContextSetters t ON t.BlockId = b.Id
WHERE
	b.Name = 'Date Range Context Setter';

-- Set group context group type for each dashboard
IF OBJECT_ID('tempdb..#tempGroupContextInfo') IS NOT NULL DROP TABLE #tempGroupContextInfo;

SELECT
	av.Id as AttributeValueId,
	b.Name AS BlockId,
	p.InternalName AS PageName
INTO
	#tempGroupContextInfo
FROM 
	AttributeValue av 
	JOIN Attribute a ON av.AttributeId = a.Id
	JOIN BlockType bt ON a.EntityTypeQualifierValue = bt.Id
	JOIN Block b ON b.Id = av.EntityId
	JOIN [Page] p ON p.Id = b.PageId
WHERE 
	a.EntityTypeId = @blockEntityTypeId
	AND a.Name = 'Group Filter'
	AND a.EntityTypeQualifierColumn = 'BlockTypeId'
	AND bt.Name = 'Group Context Setter';

-- Guest services dashboard group type context
UPDATE
	av
SET
	av.Value = CONCAT((SELECT [Guid] FROM GroupType WHERE Name = 'Guest Services Attendee'),  '|')
FROM
	AttributeValue av
	JOIN #tempGroupContextInfo t ON av.Id = t.AttributeValueId
WHERE
	t.PageName = 'Guest Services Dashboard';

-- Next Steps dashboard group type context
UPDATE
	av
SET
	av.Value = CONCAT((SELECT [Guid] FROM GroupType WHERE Name = 'Next Steps Attendee'),  '|')
FROM
	AttributeValue av
	JOIN #tempGroupContextInfo t ON av.Id = t.AttributeValueId
WHERE
	t.PageName = 'Next Steps Dashboard';

-- Fuse dashboard group type context
UPDATE
	av
SET
	av.Value = CONCAT((SELECT [Guid] FROM GroupType WHERE Name = 'Fuse Attendee'),  '|')
FROM
	AttributeValue av
	JOIN #tempGroupContextInfo t ON av.Id = t.AttributeValueId
WHERE
	t.PageName = 'Fuse Dashboard';

/*******

	Recreate metric block structure of metrics on the dashboard pages

*******/
DECLARE @pageId AS INT;

/*

	Guest Services Dashboard

*/
EXEC @pageId = clearPageOfMetrics 'Guest Services Dashboard';
EXEC insertMetricBlock @pageId, 0, '# Vols Roles Filled', '4', 'Text', 'Unique Serving', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 1, '% of Roster Serving', '4', 'Text', 'Service Attendance', '', '', 'Service Roster', '', '', 'Percentage';
EXEC insertMetricBlock @pageId, 2, 'Roster #', '4', 'Text', 'Service Roster', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 3, 'Unique Vols Attended', '4', 'Text', 'Unique Serving', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 4, 'Goal #', '4', 'Text', 'test', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 5, '% of Goal', '4', 'Text', 'test', '', '', '', '', '', 'Integer';

EXEC @pageId = clearPageOfMetrics 'Next Steps Dashboard';
EXEC insertMetricBlock @pageId, 0, 'Roster #', '4', 'Text', 'Service Roster', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 1, '% of Roster Serving', '4', 'Text', 'Service Attendance', '', '', 'Service Roster', '', '', 'Percentage';
EXEC insertMetricBlock @pageId, 2, 'Unique Vols Attended', '4', 'Text', 'Unique Serving', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 3, 'Salv #', '4', 'Text', '', 'Total Numbers', 'Salvations', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 4, 'Bapt #', '4', 'Text', '', 'Total Numbers', 'Baptism', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 5, 'Care Room Visit #', '4', 'Text', '', 'Total Numbers', 'Care Room', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 6, 'Ownership Class #', '4', 'Text', '', 'Total Numbers', 'Ownership Class Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 7, 'Financial Coaching #', '4', 'Text', '', 'Total Numbers', 'Financial Coaching', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 8, 'Group Leader #', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 9, 'Group Participant #', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 10, 'Avg Group Attendance #', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 11, '% Group participation', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 12, 'Total Home Group Members', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 13, 'Salv Attributes', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 14, '% Roster # Changed', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 15, '% Unique Vols # Changed', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 16, 'Vol Assignments per Vol', '4', 'Text', 'Service Attendance', '', '', 'Unique Serving', '', '', 'Integer';

EXEC @pageId = clearPageOfMetrics 'KidSpring Dashboard';
EXEC insertMetricBlock @pageId, 0, '# Vols Roles Filled', '4', 'Text', 'Service Attendance', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 1, 'Roster #', '4', 'Text', 'Service Roster', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 2, '% of Roster Serving', '4', 'Text', 'Service Attendance', '', '', 'Service Roster', '', '', 'Percentage';
EXEC insertMetricBlock @pageId, 3, 'Unique Vols Attended', '4', 'Text', 'Unique Serving', '', '', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 4, 'Total Attendee #', '4', 'Text', '', 'Total Numbers', 'KidSpring Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 5, 'Sunday Attendance #', '4', 'Text', '', 'Total Numbers', 'KidSpring Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 6, '% of Attendee to Sunday #', '4', 'Text', '', 'Total Numbers', 'Adult Attendance', '', 'Total Numbers', 'KidSpring Attendance', 'Percentage';
EXEC insertMetricBlock @pageId, 7, '4 week Return %', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 8, '1st Serves', '4', 'Text', 'test', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 9, 'Ratio (%) of Vols to Attendees', '4', 'Text', 'Service Attendance', '', '', '', '', '', 'Percentage';
EXEC insertMetricBlock @pageId, 10, 'First Time Guests', '4', 'Text', '', 'First Time Guests', 'KidSpring Attendance', '', '', '', 'Integer';

EXEC @pageId = clearPageOfMetrics 'Fuse Dashboard';
EXEC insertMetricBlock @pageId, 0, 'MS Student #', '4', 'Text', '', 'Fuse MS Attendance', 'Fuse Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 1, 'HS Student #', '4', 'Text', '', 'Fuse HS Attendance', 'Fuse Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 2, 'Total Attendee #', '4', 'Text', '', 'Total Numbers', 'Fuse Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 3, 'Sunday Attendance #', '4', 'Text', '', 'Total Numbers', 'Adult Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 4, '% of Attendee to Sunday #', '4', 'Text', '', 'Total Numbers', 'Fuse Attendance', '', 'Total Numbers', 'Adult Attendance', 'Percentage';
EXEC insertMetricBlock @pageId, 5, 'Total Vol # (not limited to Fuse yet)', '4', 'Text', 'Total Roster', '', '', '', '', '', '';
EXEC insertMetricBlock @pageId, 6, '1st Time Attendee #', '4', 'Text', '', 'Fuse 1st Time Attendance', 'Fuse Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 7, '4 week Return %', '4', 'Text', '', 'Fuse 4 Week Percent of Return', 'Fuse Attendance', '', '', '', 'Integer';
EXEC insertMetricBlock @pageId, 8, 'Fuse Salvation #', '4', 'Text', '', 'Total Numbers', 'Fuse Salvations', '', '', '', 'Integer';

-- Clean up functions
GO
DROP PROCEDURE insertMetricBlockAttributeValues;
GO
DROP PROCEDURE insertMetricBlock;
GO
DROP PROCEDURE clearPageOfMetrics;
GO