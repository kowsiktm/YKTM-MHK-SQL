do (
    IN P_MONTHS_BEFORE INTEGER => 1,
    IN P_LOAD_INITIAL_FLAG NVARCHAR(1) => 'N'
) begin
DECLARE V_MAX_DATE DATE;
DECLARE V_LAST_FISCAL_MONTH_END_DATE DATE;
DECLARE V_FISCAL_MONTH NVARCHAR(7);
DECLARE i INTEGER DEFAULT 0;
DECLARE V_COUNTER INTEGER;
DECLARE V_PLANT NVARCHAR(4);
DECLARE EX_MESSAGE NVARCHAR(2000);
DECLARE V_MANUAL_EXCP_FLAG NVARCHAR(1) DEFAULT 'N';
DECLARE V_TRIGGER_FLAG NVARCHAR(1) DEFAULT 'Y';
DECLARE V_EXP_UPDT_SKIP NVARCHAR(1) DEFAULT 'N';
DECLARE V_PASS_EXCEPTION NVARCHAR(2000);
--T_LOG
DECLARE LV_EXE_DATE NVARCHAR(8);
DECLARE LV_EXE_TIME NVARCHAR(8);
DECLARE LV_REC_CNT INTEGER;
--T_LOG
/* Begin Exit Handler for Job*/
/* End Exit Handler for Job*/
SELECT YEAR(ADD_MONTHS("DATE_SQL", -1 * P_MONTHS_BEFORE)) || LPAD(
        MONTH(ADD_MONTHS("DATE_SQL", -1 * P_MONTHS_BEFORE)),
        3,
        '0'
    ) INTO V_FISCAL_MONTH
FROM (
        SELECT CAST(FISCYEAR_MONTH || '01' AS DATE) AS DATE_SQL
        FROM "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_BUSINESS_UNIT_DATE"
        WHERE "DATE_SQL" = CURRENT_DATE
    );
SELECT DISTINCT "LAST_DATE_OF_FISCPER" INTO V_LAST_FISCAL_MONTH_END_DATE
FROM "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_BUSINESS_UNIT_DATE"
WHERE "FISCYEAR_PERIOD" = :V_FISCAL_MONTH;
--GET BATCH ATTRIBUTES
T_BTCH_HIST =
SELECT "START_DATE",
    "END_DATE",
    "MATNR",
    "CHARG",
    "OBJEK",
    T1."ATINN",
    "ATNAM",
    "ATWRT",
    "UPDATED_TIMESTAMP"
FROM "MHK_EDW_MART"."MHK_FNA.Reuse.Inventory::T_BATCH_ATTR_TYPE2" T1
    INNER JOIN "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_CABN" T2 ON T1."ATINN" = T2."ATINN"
WHERE "ATNAM" IN (
        'ZF_OBSOLESCENCE_CATEGORY',
        'ZF_COLOR_QUALITY_CODE',
        'ZF_2ND_QUALITY_REASON_CODE',
        'ZF_QUALITY_REASON_CD',
        'ZF_QUALITY_CODE',
        'ZF_AGE_IN_MONTHS',
        'ZF_ROLL_FLAG'
    );
-- PIVOT BATCH ATTRIBUTES
T_BTCH_HIST_PVT =
SELECT "START_DATE",
    "END_DATE",
    "MATNR",
    "CHARG",
    MAX(
        COALESCE(
            CASE
                WHEN "ATNAM" = 'ZF_COLOR_QUALITY_CODE' THEN "ATWRT"
            END,
            ''
        )
    ) AS "ZF_COLOR_QUALITY_CODE",
    MAX(
        COALESCE(
            CASE
                WHEN "ATNAM" = 'ZF_2ND_QUALITY_REASON_CODE' THEN "ATWRT"
            END,
            ''
        )
    ) AS "ZF_2ND_QUALITY_REASON_CODE",
    MAX(
        COALESCE(
            CASE
                WHEN "ATNAM" = 'ZF_QUALITY_REASON_CD' THEN "ATWRT"
            END,
            ''
        )
    ) AS "ZF_QUALITY_REASON_CD",
    MAX(
        COALESCE(
            CASE
                WHEN "ATNAM" = 'ZF_QUALITY_CODE' THEN "ATWRT"
            END,
            ''
        )
    ) AS "ZF_QUALITY_CODE",
    MAX(
        COALESCE(
            CASE
                WHEN "ATNAM" = 'ZF_AGE_IN_MONTHS' THEN "ATWRT"
            END,
            ''
        )
    ) AS "ZF_AGE_IN_MONTHS",
    MAX(
        COALESCE(
            CASE
                WHEN "ATNAM" = 'ZF_ROLL_FLAG' THEN "ATWRT"
            END,
            ''
        )
    ) AS "ZF_ROLL_FLAG"
FROM :T_BTCH_HIST
WHERE "ATNAM" <> 'ZF_OBSOLESCENCE_CATEGORY'
GROUP BY "START_DATE",
    "END_DATE",
    "MATNR",
    "CHARG";
--GET MATERIAL ATTRIBUTES
T_MAT_HIST =
SELECT "START_DATE",
    "END_DATE",
    "MATNR",
    "FIELD",
    "VALUE",
    "UPDATED_TIMESTAMP"
FROM "MHK_EDW_MART"."MHK_FNA.Reuse.Inventory::T_MATERIAL_ATTR_TYPE2";
--PIVOT MATERIAL ATTIBUTES
T_MAT_HIST_PVT =
SELECT "START_DATE",
    "END_DATE",
    "MATNR",
    MAX(
        COALESCE(
            CASE
                WHEN "FIELD" = 'MAABC' THEN "VALUE"
            END,
            ''
        )
    ) AS "MAABC",
    MAX(
        COALESCE(
            CASE
                WHEN "FIELD" = 'MSTAE' THEN "VALUE"
            END,
            ''
        )
    ) AS "MSTAE",
    MAX(
        COALESCE(
            CASE
                WHEN "FIELD" = 'MSTDE' THEN "VALUE"
            END,
            ''
        )
    ) AS "MSTDE",
    MAX(
        COALESCE(
            CASE
                WHEN "FIELD" = 'ZOWNER_CODE' THEN "VALUE"
            END,
            ''
        )
    ) AS "ZOWNER_CODE",
    MAX(
        COALESCE(
            CASE
                WHEN "FIELD" = 'STPRS' THEN "VALUE"
            END,
            ''
        )
    ) AS "STPRS",
    MAX(
        COALESCE(
            CASE
                WHEN "FIELD" = 'UNIT_PRICE' THEN "VALUE"
            END,
            ''
        )
    ) AS "UNIT_PRICE"
FROM :T_MAT_HIST
GROUP BY "START_DATE",
    "END_DATE",
    "MATNR";
T_PLANTS =
SELECT ROW_NUMBER() OVER(
        ORDER BY CNT ASC
    ) AS ROW_NUM,
    *
FROM(
        SELECT DISTINCT WERKS,
            COUNT(*) CNT
        FROM "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_MARC"
        WHERE WERKS <> '' --WHERE  WERKS IN( '6211' ,'6212','6215')
            --WHERE  WERKS IN( '6216')
        GROUP BY WERKS
    );
V_COUNTER :=::ROWCOUNT;
-- NEEDS TO BE IMMEIDATLEY AFTER LIST OF PLANTS
FOR i IN 1..V_COUNTER DO V_EXP_UPDT_SKIP := 'N';
SELECT WERKS INTO V_PLANT
FROM :T_PLANTS
WHERE ROW_NUM = :i;
DELETE FROM YKTM_INV_BUCKET_TEST_ONE
WHERE WERKS = V_PLANT
    AND DATE_SQL >= :V_LAST_FISCAL_MONTH_END_DATE;
V_COUNTER :=::ROWCOUNT;
COMMIT;
INSERT INTO YKTM_BUCKETS_LOG
values (V_PLANT, V_COUNTER);
COMMIT;
SELECT TO_CHAR(CURRENT_DATE, 'YYYYMMDD'),
    TO_CHAR(CURRENT_TIME, 'HH24MISS') INTO LV_EXE_DATE,
    LV_EXE_TIME
FROM DUMMY;
IF :P_LOAD_INITIAL_FLAG = 'Y' THEN TRUNCATE TABLE YKTM_INV_BUCKET_TEST_ONE;
T_SNAPS_PREV_MONTHS =
SELECT T1."DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID",
    SUM("STOCK_QTY_L1") AS "STOCK_QTY_L1"
FROM "MHK_EDW_MART"."MHK_FNA.Reuse.Inventory::T_RAW_INV_SNAPSHOT" T1
    INNER JOIN "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_BUSINESS_UNIT_DATE" T2 ON T1.DATE_SQL = T2.DATE_SQL
WHERE T1.DATE_SQL < :V_LAST_FISCAL_MONTH_END_DATE
    AND T2."DAY_NAME" = 'Saturday'
    AND WERKS = V_PLANT
GROUP BY T1."DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID";
ELSE T_SNAPS_PREV_MONTHS =
SELECT T1."DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID",
    SUM("STOCK_QTY_L1") AS "STOCK_QTY_L1"
FROM "MHK_EDW_MART"."MHK_FNA.Reuse.Inventory::T_RAW_INV_SNAPSHOT" T1
    INNER JOIN "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_BUSINESS_UNIT_DATE" T2 ON T1.DATE_SQL = T2.DATE_SQL
WHERE 0 = 1
GROUP BY T1."DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID";
END IF;
T_SNAPS = --FETCH CURRENT MONTH DAILY
SELECT T1."DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID",
    SUM("STOCK_QTY_L1") AS "STOCK_QTY_L1"
FROM "MHK_EDW_MART"."MHK_FNA.Reuse.Inventory::T_RAW_INV_SNAPSHOT" T1
    INNER JOIN "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_BUSINESS_UNIT_DATE" T2 ON T1.DATE_SQL = T2.DATE_SQL
WHERE T1.DATE_SQL >= :V_LAST_FISCAL_MONTH_END_DATE
    AND WERKS = V_PLANT
GROUP BY T1."DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID"
UNION
SELECT *
FROM :T_SNAPS_PREV_MONTHS;
--IMPAIRED INVENTORY
T_IMP_INV =
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID",
    "ATINN",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 0 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "NON_IMPAIRED",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 1 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "1ST_CHANCE",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 2 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "1ST_MILL_ENDS",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 3 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "1ST_REMNANTS",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 4 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "COMMERCIAL_SHORT_ROLLS",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 5 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "DROPS",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 6 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "OFF_QUALITY",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 7 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "AGED_NON_E_F_G_RESIDENTIAL",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 8 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "AGED_NON_E_F_G_COMMERCIAL",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 9 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "AGED_E_F_G_RESIDENTIAL",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 10 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "AGED_E_F_G_COMMERCIAL",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 11 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "POTENTIAL_DROPS_RESIDENTIAL",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 12 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "POTENTIAL_DROPS_COMMERCIAL",
    COALESCE(
        SUM(
            CASE
                WHEN "ATWRT" = 13 THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "IMPAIRED_SPECIAL_GOODS",
    "ATWRT" AS "ZF_OBSOLESCENCE_CATEGORY",
    SUM("STOCK_QTY_L1") AS "STOCK_QTY_L1"
FROM :T_SNAPS T1
    INNER JOIN :T_BTCH_HIST T2 ON T1."MATBF" = T2."MATNR"
    AND T1."CHARG_SID" = T2."CHARG"
    AND "DATE_SQL" BETWEEN "START_DATE" AND "END_DATE"
WHERE "ATNAM" = 'ZF_OBSOLESCENCE_CATEGORY'
GROUP BY "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "SOBKZ",
    "LBBSA_SID",
    ATWRT,
    "ATINN"
ORDER BY "DATE_SQL" ASC,
    "BUKRS" ASC,
    "WERKS" ASC,
    "MATBF" ASC,
    "CHARG_SID" ASC,
    "LGORT_SID" ASC,
    "SOBKZ" ASC,
    "LBBSA_SID" ASC;
--OTHER INVENTORY BUCKETS
T_OTHER_INV =
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    -- "SOBKZ", "LBBSA_SID" ,
    COALESCE(
        SUM(
            CASE
                WHEN "SOBKZ" = 'T'
                AND "LBBSA_SID" = '07' THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "INTRANSIT_INVENTORY",
    COALESCE(
        SUM(
            CASE
                WHEN "SOBKZ" = 'O'
                AND "LBBSA_SID" = '01' THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "SUBCONTRACT_INVENTORY",
    COALESCE(
        SUM(
            CASE
                WHEN "SOBKZ" = ''
                AND "LBBSA_SID" = '10' THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "VENDOR_PO_INVENTORY",
    COALESCE(
        SUM(
            CASE
                WHEN "LBBSA_SID" = '07'
                AND "SOBKZ" <> 'T' THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "BLOCKED_INVENTORY",
    COALESCE(
        SUM(
            CASE
                WHEN "LBBSA_SID" = '02' THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "QI_INVENTORY",
    COALESCE(
        SUM(
            CASE
                WHEN "LBBSA_SID" = '01' THEN "STOCK_QTY_L1"
            END
        ),
        0
    ) AS "UNRES_INVENTORY",
    SUM("STOCK_QTY_L1") AS "TOTAL_INVENTORY"
FROM :T_SNAPS T1
GROUP BY "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID";
--SPECIAL GOODS
T_SPECIAL_GOODS =
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    SUM("STOCK_QTY_L1") AS "SPECIAL_GOODS_INVENTORY"
FROM :T_SNAPS T1
WHERE "LGORT_SID" IN ('5101', '5003')
GROUP BY "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID";
--BEGIN NOT USING THIS , KEEPING CODE
-- COMBINE
T_UNION_DNU =
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "NON_IMPAIRED",
    "1ST_CHANCE",
    "1ST_MILL_ENDS",
    "1ST_REMNANTS",
    "COMMERCIAL_SHORT_ROLLS",
    "DROPS",
    "OFF_QUALITY",
    "AGED_NON_E_F_G_RESIDENTIAL",
    "AGED_NON_E_F_G_COMMERCIAL",
    "AGED_E_F_G_RESIDENTIAL",
    "AGED_E_F_G_COMMERCIAL",
    "POTENTIAL_DROPS_RESIDENTIAL",
    "POTENTIAL_DROPS_COMMERCIAL",
    "IMPAIRED_SPECIAL_GOODS",
    0 AS "INTRANSIT_INVENTORY",
    0 AS "SUBCONTRACT_INVENTORY",
    0 AS "VENDOR_PO_INVENTORY",
    0 AS "TOTAL_INVENTORY",
    "STOCK_QTY_L1",
    0 AS "SPECIAL_GOODS_INVENTORY",
    0 AS "BLOCKED_INVENTORY",
    0 AS "QI_INVENTORY",
    0 AS "UNRES_INVENTORY",
    "ZF_OBSOLESCENCE_CATEGORY"
FROM :T_IMP_INV
UNION
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    "INTRANSIT_INVENTORY",
    "SUBCONTRACT_INVENTORY",
    "VENDOR_PO_INVENTORY",
    "TOTAL_INVENTORY",
    0 AS "STOCK_QTY_L1",
    0 AS "SPECIAL_GOODS_INVENTORY",
    "BLOCKED_INVENTORY",
    "QI_INVENTORY",
    "UNRES_INVENTORY",
    0 AS "ZF_OBSOLESCENCE_CATEGORY"
FROM :T_OTHER_INV
UNION
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0 AS "STOCK_QTY_L1_SUM",
    "SPECIAL_GOODS_INVENTORY",
    0 AS "BLOCKED_INVENTORY",
    0 AS "QI_INVENTORY",
    0 AS "UNRES_INVENTORY",
    0 AS "ZF_OBSOLESCENCE_CATEGORY"
FROM :T_SPECIAL_GOODS;
--END NOT USING THIS , KEEPING CODE
--JOIN
T_UNION =
SELECT A.*,
    "NON_IMPAIRED",
    "1ST_CHANCE",
    "1ST_MILL_ENDS",
    "1ST_REMNANTS",
    "COMMERCIAL_SHORT_ROLLS",
    "DROPS",
    "OFF_QUALITY",
    "AGED_NON_E_F_G_RESIDENTIAL",
    "AGED_NON_E_F_G_COMMERCIAL",
    "AGED_E_F_G_RESIDENTIAL",
    "AGED_E_F_G_COMMERCIAL",
    "POTENTIAL_DROPS_RESIDENTIAL",
    "POTENTIAL_DROPS_COMMERCIAL",
    "IMPAIRED_SPECIAL_GOODS",
    "ZF_OBSOLESCENCE_CATEGORY"
FROM(
        SELECT "DATE_SQL",
            "BUKRS",
            "WERKS",
            "MATBF",
            "CHARG_SID",
            "LGORT_SID",
            SUM("INTRANSIT_INVENTORY") AS "INTRANSIT_INVENTORY",
            SUM("SUBCONTRACT_INVENTORY") AS "SUBCONTRACT_INVENTORY",
            SUM("VENDOR_PO_INVENTORY") AS "VENDOR_PO_INVENTORY",
            SUM("TOTAL_INVENTORY") AS "TOTAL_INVENTORY",
            SUM("SPECIAL_GOODS_INVENTORY") AS "SPECIAL_GOODS_INVENTORY",
            SUM("BLOCKED_INVENTORY") AS "BLOCKED_INVENTORY",
            SUM("QI_INVENTORY") AS "QI_INVENTORY",
            SUM("UNRES_INVENTORY") AS "UNRES_INVENTORY"
        FROM (
                SELECT "DATE_SQL",
                    "BUKRS",
                    "WERKS",
                    "MATBF",
                    "CHARG_SID",
                    "LGORT_SID",
                    "INTRANSIT_INVENTORY",
                    "SUBCONTRACT_INVENTORY",
                    "VENDOR_PO_INVENTORY",
                    "TOTAL_INVENTORY",
                    "BLOCKED_INVENTORY",
                    "QI_INVENTORY",
                    "UNRES_INVENTORY",
                    0 AS "SPECIAL_GOODS_INVENTORY"
                FROM :T_OTHER_INV
                UNION
                SELECT "DATE_SQL",
                    "BUKRS",
                    "WERKS",
                    "MATBF",
                    "CHARG_SID",
                    "LGORT_SID",
                    0,
                    0,
                    0,
                    0,
                    0 AS "BLOCKED_INVENTORY",
                    0 AS "QI_INVENTORY",
                    0 AS "UNRES_INVENTORY",
                    "SPECIAL_GOODS_INVENTORY"
                FROM :T_SPECIAL_GOODS
            )
        GROUP BY "DATE_SQL",
            "BUKRS",
            "WERKS",
            "MATBF",
            "CHARG_SID",
            "LGORT_SID"
    ) A
    LEFT JOIN :T_IMP_INV B ON A."DATE_SQL" = B."DATE_SQL"
    AND A."BUKRS" = B."BUKRS"
    AND A."WERKS" = B."WERKS"
    AND A."MATBF" = B."MATBF"
    AND A."CHARG_SID" = B."CHARG_SID"
    AND A."LGORT_SID" = B."LGORT_SID";
---
T_UNION_SUM =
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "ZF_OBSOLESCENCE_CATEGORY",
    SUM("NON_IMPAIRED") AS "NON_IMPAIRED",
    SUM("1ST_CHANCE") AS "1ST_CHANCE",
    SUM("1ST_MILL_ENDS") AS "1ST_MILL_ENDS",
    SUM("1ST_REMNANTS") AS "1ST_REMNANTS",
    SUM("COMMERCIAL_SHORT_ROLLS") AS "COMMERCIAL_SHORT_ROLLS",
    SUM("DROPS") AS "DROPS",
    SUM("OFF_QUALITY") AS "OFF_QUALITY",
    SUM("AGED_NON_E_F_G_RESIDENTIAL") AS "AGED_NON_E_F_G_RESIDENTIAL",
    SUM("AGED_NON_E_F_G_COMMERCIAL") AS "AGED_NON_E_F_G_COMMERCIAL",
    SUM("AGED_E_F_G_RESIDENTIAL") AS "AGED_E_F_G_RESIDENTIAL",
    SUM("AGED_E_F_G_COMMERCIAL") AS "AGED_E_F_G_COMMERCIAL",
    SUM("POTENTIAL_DROPS_RESIDENTIAL") AS "POTENTIAL_DROPS_RESIDENTIAL",
    SUM("POTENTIAL_DROPS_COMMERCIAL") AS "POTENTIAL_DROPS_COMMERCIAL",
    SUM("IMPAIRED_SPECIAL_GOODS") AS "IMPAIRED_SPECIAL_GOODS",
    SUM("INTRANSIT_INVENTORY") AS "INTRANSIT_INVENTORY",
    SUM("SUBCONTRACT_INVENTORY") AS "SUBCONTRACT_INVENTORY",
    SUM("VENDOR_PO_INVENTORY") AS "VENDOR_PO_INVENTORY",
    SUM("TOTAL_INVENTORY") AS "TOTAL_INVENTORY",
    --SUM("STOCK_QTY_L1") AS "STOCK_QTY_L1",
    0 AS "STOCK_QTY_L1",
    SUM("SPECIAL_GOODS_INVENTORY") AS "SPECIAL_GOODS_INVENTORY",
    SUM("BLOCKED_INVENTORY") AS "BLOCKED_INVENTORY",
    SUM("QI_INVENTORY") AS "QI_INVENTORY",
    SUM("UNRES_INVENTORY") AS "UNRES_INVENTORY"
FROM :T_UNION
GROUP BY "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "ZF_OBSOLESCENCE_CATEGORY";
T_PRE_FINAL =
SELECT "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "ZF_OBSOLESCENCE_CATEGORY",
    MAX("ZF_COLOR_QUALITY_CODE") AS "ZF_COLOR_QUALITY_CODE",
    MAX("ZF_2ND_QUALITY_REASON_CODE") AS "ZF_2ND_QUALITY_REASON_CODE",
    MAX("ZF_QUALITY_REASON_CD") AS "ZF_QUALITY_REASON_CD",
    MAX("ZF_QUALITY_CODE") AS "ZF_QUALITY_CODE",
    MAX("ZF_AGE_IN_MONTHS") AS "ZF_AGE_IN_MONTHS",
    MAX("ZF_ROLL_FLAG") AS "ZF_ROLL_FLAG",
    MAX("MAABC") AS "MAABC",
    MAX("MSTAE") AS "MSTAE",
    MAX("MSTDE") AS "MSTDE",
    MAX("ZOWNER_CODE") AS "ZOWNER_CODE",
    MAX("STPRS") AS "STPRS",
    MAX("UNIT_PRICE") AS "UNIT_PRICE",
    "NON_IMPAIRED",
    "1ST_CHANCE",
    "1ST_MILL_ENDS",
    "1ST_REMNANTS",
    "COMMERCIAL_SHORT_ROLLS",
    "DROPS",
    "OFF_QUALITY",
    "AGED_NON_E_F_G_RESIDENTIAL",
    "AGED_NON_E_F_G_COMMERCIAL",
    "AGED_E_F_G_RESIDENTIAL",
    "AGED_E_F_G_COMMERCIAL",
    "POTENTIAL_DROPS_RESIDENTIAL",
    "POTENTIAL_DROPS_COMMERCIAL",
    "IMPAIRED_SPECIAL_GOODS",
    "INTRANSIT_INVENTORY",
    "SUBCONTRACT_INVENTORY",
    "VENDOR_PO_INVENTORY",
    "TOTAL_INVENTORY",
    "STOCK_QTY_L1",
    "SPECIAL_GOODS_INVENTORY",
    "BLOCKED_INVENTORY",
    "QI_INVENTORY",
    "UNRES_INVENTORY"
FROM :T_UNION_SUM T1
    LEFT JOIN :T_BTCH_HIST_PVT T2 ON T1."MATBF" = T2."MATNR"
    AND T1."CHARG_SID" = T2."CHARG"
    AND T1."DATE_SQL" BETWEEN T2."START_DATE" AND T2."END_DATE"
    LEFT JOIN :T_MAT_HIST_PVT T3 ON T1."MATBF" = T3."MATNR"
    AND T1."DATE_SQL" BETWEEN T3."START_DATE" AND T3."END_DATE"
GROUP BY "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    "ZF_OBSOLESCENCE_CATEGORY",
    "NON_IMPAIRED",
    "1ST_CHANCE",
    "1ST_MILL_ENDS",
    "1ST_REMNANTS",
    "COMMERCIAL_SHORT_ROLLS",
    "DROPS",
    "OFF_QUALITY",
    "AGED_NON_E_F_G_RESIDENTIAL",
    "AGED_NON_E_F_G_COMMERCIAL",
    "AGED_E_F_G_RESIDENTIAL",
    "AGED_E_F_G_COMMERCIAL",
    "POTENTIAL_DROPS_RESIDENTIAL",
    "POTENTIAL_DROPS_COMMERCIAL",
    "IMPAIRED_SPECIAL_GOODS",
    "INTRANSIT_INVENTORY",
    "SUBCONTRACT_INVENTORY",
    "VENDOR_PO_INVENTORY",
    "TOTAL_INVENTORY",
    "STOCK_QTY_L1",
    "SPECIAL_GOODS_INVENTORY",
    "BLOCKED_INVENTORY",
    "QI_INVENTORY",
    "UNRES_INVENTORY";
T_FINAL =
SELECT "FISCYEAR_MONTH",
    "WEEK_NO_IN_FISCPER",
    "WEEK_NO_IN_FISCYEAR",
    LAST_DAY_OF_FISC_MON_IND AS MONTH_LAST_DAY,
    DAY_NAME,
    T1.*
FROM :T_PRE_FINAL T1
    INNER JOIN "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_BUSINESS_UNIT_DATE" T2 ON T1.DATE_SQL = T2.DATE_SQL;
LV_REC_CNT =::ROWCOUNT;
INSERT INTO YKTM_INV_BUCKET_TEST_ONE
SELECT "FISCYEAR_MONTH",
    "WEEK_NO_IN_FISCPER",
    "WEEK_NO_IN_FISCYEAR",
    "MONTH_LAST_DAY",
    CASE
        WHEN "DAY_NAME" = 'Saturday' THEN 'Y'
        ELSE 'N'
    END AS "WEEK_LAST_DAY",
    "DAY_NAME",
    "DATE_SQL",
    "BUKRS",
    "WERKS",
    "MATBF",
    "CHARG_SID",
    "LGORT_SID",
    COALESCE("ZF_OBSOLESCENCE_CATEGORY", '0') AS "ZF_OBSOLESCENCE_CATEGORY",
    "ZF_COLOR_QUALITY_CODE",
    "ZF_2ND_QUALITY_REASON_CODE",
    "ZF_QUALITY_REASON_CD",
    "ZF_QUALITY_CODE",
    "ZF_AGE_IN_MONTHS",
    "ZF_ROLL_FLAG",
    "MAABC",
    "MSTAE",
    CAST("MSTDE" AS DATE) AS "MSTDE",
    "ZOWNER_CODE",
    "STPRS",
    "UNIT_PRICE",
    "NON_IMPAIRED",
    "1ST_CHANCE",
    "1ST_MILL_ENDS",
    "1ST_REMNANTS",
    "COMMERCIAL_SHORT_ROLLS",
    "DROPS",
    "OFF_QUALITY",
    "AGED_NON_E_F_G_RESIDENTIAL",
    "AGED_NON_E_F_G_COMMERCIAL",
    "AGED_E_F_G_RESIDENTIAL",
    "AGED_E_F_G_COMMERCIAL",
    "POTENTIAL_DROPS_RESIDENTIAL",
    "POTENTIAL_DROPS_COMMERCIAL",
    "IMPAIRED_SPECIAL_GOODS",
    "INTRANSIT_INVENTORY",
    "SUBCONTRACT_INVENTORY",
    "VENDOR_PO_INVENTORY",
    "TOTAL_INVENTORY",
    "STOCK_QTY_L1",
    "BLOCKED_INVENTORY",
    "QI_INVENTORY",
    "UNRES_INVENTORY"
FROM :T_FINAL;
COMMIT;
END FOR;
END