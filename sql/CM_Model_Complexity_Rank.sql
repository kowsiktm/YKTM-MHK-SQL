DO BEGIN T =
SELECT *,
    Count_Projection + Count_Aggregation + Count_Join + Count_Union + Count_Rank AS Count_Nodes
FROM (
        SELECT A.*,
            OBJECT_SUFFIX,
            OBJECT_STATUS,
            OCCURRENCES_REGEXPR('ProjectionView' in TO_VARCHAR(CDATA)) Count_Projection,
            OCCURRENCES_REGEXPR('AggregationView' in TO_VARCHAR(CDATA)) Count_Aggregation,
            OCCURRENCES_REGEXPR('JoinView' in TO_VARCHAR(CDATA)) Count_Join,
            OCCURRENCES_REGEXPR('UnionView' in TO_VARCHAR(CDATA)) Count_Union,
            OCCURRENCES_REGEXPR('RankView' in TO_VARCHAR(CDATA)) Count_Rank,
            LENGTH(TO_VARCHAR(CDATA)) Count_Model_Lines,
            OCCURRENCES_REGEXPR(' expressionLanguage=' in TO_VARCHAR(CDATA)) Count_Calc_Cols
        FROM "E199551"."T_OBJECT_DETAILS" A
            LEFT JOIN _SYS_REPO.ACTIVE_OBJECT B ON A.PACKAGE = B.PACKAGE_ID
            AND A.OBJECT = B.OBJECT_NAME
        WHERE TYPE = 'VIEW'
    )
ORDER BY 11 DESC;
J =
SELECT DISTINCT OBJECT_NAME,
    SUM(TABLE_COUNTS) TABLE_COUNTS,
    SUM(MODEL_COUNTS) MODEL_COUNTS
FROM(
        SELECT OBJECT_NAME,
            COUNT(BASE_OBJECT_NAME) AS TABLE_COUNTS,
            0 AS MODEL_COUNTS
        FROM(
                SELECT A.*,
                    BASE_OBJECT_NAME
                FROM "E199551"."T_OBJECT_DETAILS" A
                    LEFT JOIN OBJECT_DEPENDENCIES B ON A.OBJECT_NAME = B.DEPENDENT_OBJECT_NAME
                    AND BASE_OBJECT_TYPE = 'TABLE'
                    AND BASE_OBJECT_NAME not like '%/hier/%'
                    AND BASE_OBJECT_NAME not like '%/olap%'
                    AND DEPENDENCY_TYPE = 1
                WHERE TYPE = 'VIEW'
                order by BASE_OBJECT_NAME
            )
        GROUP BY OBJECT_NAME
        UNION
        SELECT OBJECT_NAME,
            0 AS TABLE_COUNTS,
            COUNT(BASE_OBJECT_NAME) AS MODEL_COUNTS
        FROM(
                SELECT A.*,
                    BASE_OBJECT_NAME
                FROM "E199551"."T_OBJECT_DETAILS" A
                    LEFT JOIN OBJECT_DEPENDENCIES B ON A.OBJECT_NAME = B.DEPENDENT_OBJECT_NAME
                    AND BASE_OBJECT_TYPE = 'VIEW'
                    AND BASE_OBJECT_NAME not like '%/hier/%'
                    AND BASE_OBJECT_NAME not like '%/olap%'
                    AND DEPENDENCY_TYPE = 1
                WHERE TYPE = 'VIEW'
                order by BASE_OBJECT_NAME
            )
        GROUP BY OBJECT_NAME
    )
GROUP BY OBJECT_NAME;
SELECT A.*,
    TABLE_COUNTS,
    MODEL_COUNTS
FROM :T A
    LEFT JOIN :J B ON A.OBJECT_NAME = B.OBJECT_NAME
ORDER BY TABLE_COUNTS;
END