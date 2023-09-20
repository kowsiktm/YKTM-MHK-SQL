SELECT DISTINCT OBJECT_NAME
FROM (
        SELECT DISTINCT BASE_OBJECT_NAME AS OBJECT_NAME
        FROM(
                SELECT A.*,
                    BASE_OBJECT_NAME
                FROM "E199551"."T_OBJECT_DETAILS" A
                    LEFT JOIN OBJECT_DEPENDENCIES B ON A.OBJECT_NAME = B.DEPENDENT_OBJECT_NAME
                    AND BASE_OBJECT_TYPE = 'VIEW'
                    AND BASE_OBJECT_NAME not like '%/hier/%'
                    AND BASE_OBJECT_NAME not like '%/olap%'
                WHERE TYPE = 'VIEW'
                order by BASE_OBJECT_NAME
            )
        union
        SELECT DISTINCT OBJECT_NAME
        FROM "E199551"."T_OBJECT_DETAILS"
        WHERE TYPE = 'VIEW'
    )
ORDER BY 1