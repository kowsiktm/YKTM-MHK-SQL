SELECT *,
    Count_Projection + Count_Aggregation + Count_Join + Count_Union + Count_Rank AS Total
FROM (
        SELECT A.*,
            OBJECT_SUFFIX,
            OCCURRENCES_REGEXPR('ProjectionView' in TO_VARCHAR(CDATA)) Count_Projection,
            OCCURRENCES_REGEXPR('AggregationView' in TO_VARCHAR(CDATA)) Count_Aggregation,
            OCCURRENCES_REGEXPR('JoinView' in TO_VARCHAR(CDATA)) Count_Join,
            OCCURRENCES_REGEXPR('UnionView' in TO_VARCHAR(CDATA)) Count_Union,
            OCCURRENCES_REGEXPR('RankView' in TO_VARCHAR(CDATA)) Count_Rank,
            OCCURRENCES_REGEXPR(' expressionLanguage=' in TO_VARCHAR(CDATA)) Count_Calc_Cols,
            LENGTH(TO_VARCHAR(CDATA)) Count_Model_Lines
        FROM "E199551"."T_OBJECT_DETAILS" A
            LEFT JOIN _SYS_REPO.ACTIVE_OBJECT B ON A.PACKAGE = B.PACKAGE_ID
            AND A.OBJECT = B.OBJECT_NAME
        WHERE TYPE = 'VIEW'
    )
ORDER BY 11 DESC