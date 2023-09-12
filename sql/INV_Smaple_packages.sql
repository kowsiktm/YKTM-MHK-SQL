SELECT A.MATNR,
    A.WERKS,
    D.MFRPN,
    A.STLNR,
    IDNRK,
    C."MTART",
    C.MATNR,
    C.BISMT,
    C."MFRPN",
    TOTAL_INV_QUAN_SUM
FROM "QS5_TO_AIQ"."MAST" A
    LEFT JOIN "QS5_TO_AIQ"."STPO" B ON A.STLNR = B.STLNR
    LEFT JOIN "_SYS_BIC"."MHK_FNA.Reuse.MasterData/MHK_RVDM_MD_MATERIAL" C ON B.IDNRK = C.MATNR
    LEFT JOIN "_SYS_BIC"."MHK_FNA.Reuse.MasterData/MHK_RVDM_MD_MATERIAL" D ON A.MATNR = D.MATNR
    LEFT JOIN (
        SELECT "MATNR",
            "WERKS",
            "PLANTTYPE",
            "PLANT_DESC",
            SUM("TOTAL_INV_QUAN") AS "TOTAL_INV_QUAN_SUM"
        FROM "_SYS_BIC"."MHK_FNA.Reporting.Inventory/MHK_INV_CURRENT_INVENTORY"(
                'PLACEHOLDER' = ('$$IP_CPUDT$$', '20221101'),
                'PLACEHOLDER' = ('$$IP_UOM$$', 'LFT')
            )
        GROUP BY "MATNR",
            "WERKS",
            "PLANTTYPE",
            "PLANT_DESC"
    ) E ON C.BISMT = E.MATNR
WHERE A."MATNR" = 'TW154.ALWIN.DISPLA.PK' --'SS126.CLR23.DISPLA.PK'