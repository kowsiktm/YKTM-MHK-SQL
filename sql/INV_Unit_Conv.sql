SELECT HARD_SOFT,
    MATNR,
    PRODUCT_CLASS_DESC,
    BASE_UOM,
    BASE_UOM_DESC,
    MEINH,
    ALT_UOM,
    ALT_UOM_DESC,
    "UMREZ",
    "UMREN",
    "UMREN" / "UMREZ" CONV_BA,
    "UMREZ" / "UMREN" CONV_AB
FROM (
        SELECT HARD_SOFT,
            PRODUCT_CLASS_DESC,
            X."MATNR",
            X.MEINS,
            C.MSEH3 AS BASE_UOM,
            C.MSEHT AS BASE_UOM_DESC,
            A."MEINH",
            B."MSEH3" AS ALT_UOM,
            B."MSEHT" AS ALT_UOM_DESC,
            "UMREN",
            "UMREZ" --FROM "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_MARA" X
        FROM "_SYS_BIC"."MHK_FNA.Reuse.MasterData/MHK_RVDM_MD_MATERIAL" X
            INNER JOIN "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_MARM" A ON X.MATNR = A.MATNR
            INNER JOIN "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_T006A" B ON A.MEINH = B.MSEHI
            AND A.MANDT = B.MANDT
            AND SPRAS = 'E'
            LEFT JOIN (
                SELECT DISTINCT "MSEHI",
                    "MSEH3",
                    "MSEH6",
                    "MSEHT",
                    "MSEHL",
                    MANDT
                FROM "_SYS_BIC"."MHK_FNA.Base.MasterData/MHK_BVDM_MD_T006A"
                WHERE SPRAS = 'E'
            ) C ON X.MEINS = C.MSEHI
            AND X.MANDT = C.MANDT --AND SPRAS = 'E'
            --WHERE MTART  = 'ZFIN'
    )
WHERE PRODUCT_CLASS_DESC IN (
        'SHEET VINYL',
        'VINYL MOLDINGS',
        'CARPET TILE',
        'LVT',
        'LAMNATE MODLINGS'
    )
    /*
     "MATNR" IN ('VU39.1.RL.LU',
     '21032.7310.1200.J',
     '63129.04.4WB.WB',
     '67759.880.07B48.VT'
     ) --and  MATNR LIKE '%.%' AND HARD_SOFT IN ('HARD'--,'SOFT'
     --)
     --and BASE_UOM = 'YD2'
     */
ORDER BY MATNR