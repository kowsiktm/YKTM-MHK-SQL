DO BEGIN T_MATDOC =
SELECT "BUKRS",
    "WERKS",
    "LGORT_SID",
    "PRCTR",
    "MATBF",
    "BWART",
    "GJPER",
    SUM("STOCK_QTY") AS "STOCK_QTY"
FROM "QS5_TO_AIQ"."MATDOC"
WHERE "BUKRS" = '8135'
    AND "WERKS" = '6211'
    AND "BWART" = '101'
    AND "MATBF" = '66420.4IN.RL.TP'
GROUP BY "BUKRS",
    "WERKS",
    "LGORT_SID",
    "PRCTR",
    "MATBF",
    "BWART",
    "GJPER"
ORDER BY "BUKRS" ASC,
    "WERKS" ASC,
    "LGORT_SID" ASC,
    "PRCTR" ASC,
    "MATBF" ASC,
    "BWART" ASC;
SELECT *
FROM :T_MATDOC;
SELECT *,
    SUM(STOCK_QTY) OVER(
        PARTITION BY "GJPER",
        "BUKRS",
        "WERKS",
        "LGORT_SID",
        "PRCTR",
        "MATBF",
        "BWART"
        ORDER BY "GJPER",
            "BUKRS",
            "WERKS",
            "LGORT_SID",
            "PRCTR",
            "MATBF",
            "BWART"
    ) RUN_TOTAL
FROM :T_MATDOC;
V_OUT =
SELECT *,
    LAG(RUN_TOTAL) OVER(
        PARTITION BY "GJPER",
        "BUKRS",
        "WERKS",
        "PRCTR",
        "BWART"
        ORDER BY "GJPER",
            "BUKRS",
            "WERKS",
            "LGORT_SID",
            "PRCTR",
            "MATBF",
            "BWART"
    ) PREV_RUN_TOTAL
FROM (
        SELECT *,
            SUM(STOCK_QTY) OVER(
                PARTITION BY "GJPER",
                "BUKRS",
                "WERKS",
                "PRCTR",
                "BWART"
                ORDER BY "GJPER",
                    "BUKRS",
                    "WERKS",
                    "LGORT_SID",
                    "PRCTR",
                    "MATBF",
                    "BWART"
            ) RUN_TOTAL
        FROM :T_MATDOC
        ORDER BY "GJPER",
            "BUKRS",
            "WERKS",
            "LGORT_SID",
            "PRCTR",
            "MATBF",
            "BWART"
    );
SELECT *
FROM :V_OUT;
SELECT
END ----------
DO BEGIN T_MATDOC =
SELECT "BWART",
    "GJPER",
    SUM("STOCK_QTY") AS "STOCK_QTY"
FROM "QS5_TO_AIQ"."MATDOC"
WHERE "BWART" <> '' --AND "GJAHR" >= '2023'
    AND "GJPER" >= '2023006'
    AND BUKRS = '8135' --AND BWART = '101'
GROUP BY "BWART",
    "GJPER"
ORDER BY "GJPER",
    "BWART";
SELECT "BWART",
    "GJPER",
    CASE
        WHEN SHKZG = 'H' THEN -1
        ELSE 1
    END AS FACTOR,
    SUM("STOCK_QTY") AS "STOCK_QTY"
FROM "QS5_TO_AIQ"."MATDOC"
WHERE "BWART" <> '' --AND "GJAHR" >= '2023'
    AND "GJPER" = '2023006'
    AND BUKRS = '8135' --AND BWART = '101'
GROUP BY "BWART",
    "GJPER",
    SHKZG;
SELECT *
FROM :T_MATDOC;
SELECT "BWART",
    "GJPER",
    CAST("STOCK_QTY" AS DECIMAL(13, 2)) AS TOTAL,
    CAST(
        SUM("STOCK_QTY") OVER(
            PARTITION BY "BWART"
            ORDER BY "GJPER"
        ) AS DECIMAL(13, 2)
    ) AS END_BALANCE
FROM :T_MATDOC
ORDER BY "BWART",
    "GJPER";
SELECT ROW_NUMBER() OVER(
        PARTITION BY GJPER
        ORDER BY GJPER,
            BWART
    ) RN,
    *
FROM (
        SELECT "BWART",
            "GJPER",
            CAST("STOCK_QTY" AS DECIMAL(13, 2)) AS TOTAL,
            CAST(
                SUM("STOCK_QTY") OVER(
                    PARTITION BY "GJPER"
                    ORDER BY "BWART"
                ) AS DECIMAL(13, 2)
            ) AS END_BALANCE
        FROM :T_MATDOC
    )
ORDER BY "GJPER",
    "BWART",
    RN;
END;