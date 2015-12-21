/*

	1.) Make all the dashboards context setters be in this order:
		Campus, Group, Service, and then Date

	2.) Set group type for each dashboard's group context setter

	3.) Arrange the blocks on each dashboard in a preset order

*/

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
DECLARE @metricBlockTypeId AS INT = (SELECT Id FROM BlockType WHERE Name = 'Ministry Metrics' AND Category = 'NewSpring');

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

/*

	Guest Services Dashboard

	Order	Name
	0		# Vols Roles Filled
	1		Roster #
	2		% of Roster Serving
	3		Unique Vols Attended
	4		Goal #
	5		% of Goal

*/
SELECT @pageId = Id FROM [Page] WHERE InternalName = 'Guest Services Dashboard';
IF OBJECT_ID('tempdb..#tempPageBlocks') IS NOT NULL DROP TABLE #tempPageBlocks;
SELECT * INTO #tempPageBlocks FROM Block WHERE PageId = @pageId AND BlockTypeId = @metricBlockTypeId ORDER BY [Order];

UPDATE b SET b.[Order] = 0 FROM [Block] b JOIN #tempPageBlocks t ON t.Id = b.Id WHERE b.Name = '# Vols Roles Filled';
UPDATE b SET b.[Order] = 1 FROM [Block] b JOIN #tempPageBlocks t ON t.Id = b.Id WHERE b.Name = 'Roster #';
UPDATE b SET b.[Order] = 2 FROM [Block] b JOIN #tempPageBlocks t ON t.Id = b.Id WHERE b.Name = '% of Roster Serving';
UPDATE b SET b.[Order] = 3 FROM [Block] b JOIN #tempPageBlocks t ON t.Id = b.Id WHERE b.Name = 'Unique Vols Attended';
UPDATE b SET b.[Order] = 4 FROM [Block] b JOIN #tempPageBlocks t ON t.Id = b.Id WHERE b.Name = 'Goal #';
UPDATE b SET b.[Order] = 5 FROM [Block] b JOIN #tempPageBlocks t ON t.Id = b.Id WHERE b.Name = '% of Goal';