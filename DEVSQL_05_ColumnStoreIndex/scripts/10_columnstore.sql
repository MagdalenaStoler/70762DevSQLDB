USE [AdventureworksDW2016CTP3]
GO

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
GO

SET STATISTICS IO	OFF;
SET STATISTICS TIME OFF;
GO

--------------------------------------------------

	--IF INDEXPROPERTY(OBJECT_ID('dbo.FactFinance_Indeksy'), 'CIX_FactFinance', 'IndexId') IS NOT NULL 
	--DROP INDEX CIX_FactFinance ON [dbo].[FactFinance_Indeksy]

	--IF INDEXPROPERTY(OBJECT_ID('dbo.FactFinance_Indeksy'), 'IX_FactFinance', 'IndexId') IS NOT NULL 
	--DROP INDEX IX_FactFinance ON [dbo].[FactFinance_Indeksy]

	--IF INDEXPROPERTY(OBJECT_ID('dbo.FactFinance_Indeksy'), 'NIX_FactFinance', 'IndexId') IS NOT NULL 
	--DROP INDEX NIX_FactFinance ON [dbo].[FactFinance_Indeksy]

	--IF INDEXPROPERTY(OBJECT_ID('dbo.FactFinance_Indeksy'), 'NIX_FactFinance2', 'IndexId') IS NOT NULL 
	--DROP INDEX NIX_FactFinance2 ON [dbo].[FactFinance_Indeksy]

--------------------------------------------------

	--CREATE CLUSTERED INDEX IX_FactFinance
	--ON [dbo].[FactFinance_Indeksy](	[AccountKey]		,
	--						[OrganizationKey]
	--						)
	--SELECT i.*
	--FROM	
	--			sys.[tables]	AS t
	--INNER JOIN	sys.[schemas]	AS s	ON [s].[schema_id] = [t].[schema_id]
	--INNER JOIN	sys.[indexes]	AS i	ON	[i].[object_id] = [t].[object_id]
	--WHERE
	--	s.name =	'dbo'
	--AND t.name =	'FactFinance_Indeksy'

	SELECT
		[a].[AccountDescription]
	,   [a].[AccountType]
	,	COUNT(*)			AS [RowNum]
	,   SUM([f].[Amount])	AS [Amount]

	FROM
				[dbo].[FactFinance_Indeksy]	AS [f]
	INNER JOIN	[dbo].[DimAccount]			AS [a]	ON	[a].[AccountKey]			= [f].[AccountKey]
	GROUP BY
		[a].[AccountDescription]
	,   [a].[AccountType]

	
--------------------------------------------------


	--CREATE CLUSTERED COLUMNSTORE INDEX CIX_FactFinance
	--ON [dbo].[FactFinance_Indeksy]

	--SELECT i.*
	--FROM	
	--			sys.[tables]	AS t
	--INNER JOIN	sys.[schemas]	AS s	ON [s].[schema_id] = [t].[schema_id]
	--INNER JOIN	sys.[indexes]	AS i	ON	[i].[object_id] = [t].[object_id]
	--WHERE
	--	s.name =	'dbo'
	--AND t.name =	'FactFinance_Indeksy'

--------------------------------------------------

	SELECT
		[TableName]		=	[t].[name]
	,   [SchemaName]	=	[s].[name]
	,   [RowCounts]		=	SUM([p].[rows])
	,   [TotalSpaceMB]	=	CAST(ROUND(( ( SUM([a].[total_pages]) * 8 ) / 1024.00 ), 2) AS NUMERIC(36, 2))
	,   [UsedSpaceMB]	=	CAST(ROUND(( ( SUM([a].[used_pages]) * 8 ) / 1024.00 ), 2) AS NUMERIC(36, 2))
	FROM
				[sys].[tables]				AS [t]
	INNER JOIN	[sys].[schemas]				AS [s]    ON [t].[schema_id]	= [s].[schema_id]
	INNER JOIN	[sys].[indexes]				AS [i]    ON [t].[object_id]	= [i].[object_id]
	INNER JOIN	[sys].[partitions]			AS [p]    ON [i].[object_id]	= [p].[object_id]       AND [i].[index_id] = [p].[index_id]
	INNER JOIN	[sys].[allocation_units]	AS [a]    ON [p].[partition_id] = [a].[container_id]

	WHERE 1=1
		AND [t].[name] LIKE 'FactFinance_Indeksy'
		AND [s].[name] =	'dbo'
	GROUP BY
		[t].[name]
	,   [s].[name]
	ORDER BY
		[t].[name];

--------------------------------------------------

	SET STATISTICS IO ON;
	SET STATISTICS TIME ON;
	GO

	SELECT
		[a].[AccountDescription]
	,   [a].[AccountType]
	,   [o].[OrganizationName]
	,	[d].[DepartmentGroupName]
	,	COUNT(*)			AS [RowNum]
	,   SUM([f].[Amount])	AS [Amount]

	FROM
				[dbo].[FactFinance_Indeksy]		AS [f]
	INNER JOIN	[dbo].[DimAccount]				AS [a]	ON	[a].[AccountKey]			= [f].[AccountKey]
	INNER JOIN	[dbo].[DimDepartmentGroup]		AS [d]	ON	[d].[DepartmentGroupKey]	= [f].[DepartmentGroupKey]
	INNER JOIN	[dbo].[DimOrganization]			AS [o]	ON	[o].[OrganizationKey]		= [f].[OrganizationKey]
	WHERE
		[a].[AccountDescription]	= 'Cash'
	AND [d].[DepartmentGroupName]	= 'Sales and Marketing'
	AND [o].[OrganizationName]		= 'France'
	GROUP BY
		[a].[AccountDescription]
	,   [a].[AccountType]
	,   [o].[OrganizationName]
	,	[d].[DepartmentGroupName]
	OPTION (MAXDOP 1)

--------------------------------------------------

	SELECT
		[a].[AccountDescription]
	,   [a].[AccountType]
	,	COUNT(*)			AS [RowNum]
	,   SUM([f].[Amount])	AS [Amount]

	FROM
				[dbo].[FactFinance_Indeksy]		AS [f]
	INNER JOIN	[dbo].[DimAccount]				AS [a]	ON	[a].[AccountKey]			= [f].[AccountKey]
	GROUP BY
		[a].[AccountDescription]
	,   [a].[AccountType]