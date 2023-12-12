DO BEGIN
DECLARE V_CHAR NVARCHAR(100);
V_CHAR := '%FIBER%';
X =
SELECT DISTINCT A.ATINN,
    ATNAM,
    ATWRT,
    KLART
FROM "QS5_TO_AIQ"."AUSP" A
    inner JOIN (
        SELECT DISTINCT A."ATINN",
            ATNAM,
            "ATBEZ"
        FROM "QS5_TO_AIQ"."CABN" A
            inner JOIN (
                SELECT DISTINCT "ATINN",
                    '' AS "ATBEZ"
                FROM "QS5_TO_AIQ"."CABN"
                WHERE UPPER("ATNAM") LIKE UPPER(:V_CHAR)
                UNION
                SELECT DISTINCT "ATINN",
                    "ATBEZ"
                FROM "QS5_TO_AIQ"."CABNT"
                WHERE UPPER("ATBEZ") LIKE UPPER(:V_CHAR)
            ) B ON A.ATINN = B.ATINN
    ) B ON A.ATINN = B.ATINN
ORDER BY ATINN;
D =
SELECT *
FROM (
        SELECT A.*,
            ATZHL,
            ATWTB
        FROM :X A
            LEFT JOIN (
                SELECT DISTINCT *
                FROM "_SYS_BIC"."MHK_FNA.Reuse.MasterData/MHK_RVDM_MD_CLASS_CHAR_TEXT"
            ) B ON A.ATNAM = B.ATNAM
            AND A.ATWRT = B.ATWRT
    ) --WHERE ATZHL IS NOT NULL
ORDER BY ATNAM,
    KLART;
SELECT *
FROM :D;
SELECT DISTINCT ATNAM
FROM :D;
END;