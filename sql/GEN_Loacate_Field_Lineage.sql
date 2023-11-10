SELECT SUBSTRING(
        TO_VARCHAR(CDATA),
        CAST(STRT -200 AS INTEGER),
        1000
    )
FROM (
        SELECT LOCATE(TO_VARCHAR(CDATA), 'BKLAS', 0, 1) AS STRT,
            VAL,
            CDATA
        from (
                SELECT CDATA,
                    OCCURRENCES_REGEXPR('BKLAS' in TO_VARCHAR(CDATA)) VAL
                FROM _SYS_REPO.ACTIVE_OBJECT
                WHERE CDATA LIKE '%BKLAS%'
                    AND PACKAGE_ID || '/' || OBJECT_NAME = 'MHK_FNA.Reuse.Inventory/MHK_RVCU_IM_INV_SNAPSHOT'
            )
    )