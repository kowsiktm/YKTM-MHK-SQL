select A.*,
    B.BSART,
    CASE
        WHEN WERKS LIKE '61%'
        AND BWART = '101' THEN 'OPO-101'
        WHEN BSART = 'ZMNB'
        AND BWART = '101' THEN 'SPO-101'
        WHEN BSART = 'ZMNB'
        AND BWART = '102' THEN 'RCPO-102' --WHEN BSART = 'ZMNB' AND BWART = '101' 
        --THEN
        WHEN (
            BSART = 'ZUD'
            OR BSART = 'ZUMI'
        )
        AND BWART = '101' THEN 'STO-101'
        WHEN (
            BSART = 'ZUD'
            OR BSART = 'ZUMI'
        )
        AND BWART = '102' THEN 'RCSTO-102'
        ELSE BWART
    END AS SP_BWART
FROM (
        SELECT GJPER,
            "EBELN",
            BWART,
            "WERKS",
            COUNT(*) AS "BWART_COUNT"
        FROM "QS5_TO_AIQ"."MATDOC"
        WHERE "BWART" IN ('101', '102')
            AND "GJPER" >= '2023006'
        GROUP BY "EBELN",
            "WERKS",
            BWART,
            GJPER
        ORDER BY "EBELN" ASC,
            "WERKS" ASC
    ) A
    INNER JOIN "QS5_TO_AIQ".EKKO B ON A.EBELN = B.EBELN
ORDER BY 1;
SELECT "GJPER",
    "BWART",
    sum("PREVIOUS_BAL_QTY") AS "PREVIOUS_BAL_QTY",
    sum("TOTAL_QTY") AS "TOTAL_QTY",
    sum("END_BALANCE_QTY") AS "END_BALANCE_QTY",
    sum("PREVIOUS_BAL_VAL") AS "PREVIOUS_BAL_VAL",
    sum("TOTAL_VAL") AS "TOTAL_VAL",
    sum("END_BALANCE_VAL") AS "END_BALANCE_VAL"
FROM "_SYS_BIC"."Work.inventory.POC.RF/EXP_INV_RF_SUM_V1"(
        'PLACEHOLDER' = ('$$IP_DATE$$', '20240701'),
        -- 'PLACEHOLDER' = ('$$IP_PRCTR$$',
        -- '''0000000010'',''0000000021'''),
        'PLACEHOLDER' = ('$$IP_MATNR$$', '''67851.222.0960V.VT'''),
        'PLACEHOLDER' = ('$$IP_TIME$$', '120000'),
        'PLACEHOLDER' = ('$$IP_WERKS$$', '''6211''')
    )
GROUP BY "GJPER",
    "BWART"