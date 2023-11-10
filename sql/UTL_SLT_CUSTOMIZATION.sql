SELECT *
FROM (
        SELECT TABLE_NAME
        FROM TABLES
        WHERE SCHEMA_NAME = 'QS5_TO_AIQ'
            AND TABLE_NAME NOT LIKE '%/%'
    )
    LEFT JOIN (
        SELECT DISTINCT "TABNAME",
            STRING_AGG(FIELDNAME, ',') FIELD_LIST,
            COUNT(*) COUNT
        FROM (
                SELECT DISTINCT "TABNAME",
                    FIELDNAME
                FROM "QS5_TO_AIQ"."DD03L"
                WHERE TABNAME NOT LIKE '%/%'
                    AND (
                        "FIELDNAME" LIKE 'Z%'
                        OR "FIELDNAME" LIKE 'Y%'
                    )
            )
        GROUP BY "TABNAME"
    ) ON TABLE_NAME = TABNAME