Generated SQL:
SELECT TOP 2000 DISTINCT "WERKS",
    "MATNR",
    "STYLE_CD",
    "SIZE_CD",
    "COLOR_CD",
    "BACKING_CD",
    "ZF_QUALITY_CODE",
    "ZF_ORIG_LENGTH_IN",
    "ZF_BALANCE_WIDTH_IN",
    "WIDTH",
    "LENGTH",
    "ZC_FIBER_BRAND_CD",
    "ZC_FIBER_BRAND_DESC"
FROM "_SYS_BIC"."MHK_FNA.Reporting.Inventory/MHK_INV_CURRENT_INVENTORY"(
        'PLACEHOLDER' = ('$$IP_CPUDT$$', '20230604'),
        'PLACEHOLDER' = ('$$IP_UOM$$', 'LFT')
    )
WHERE ("STYLE_CD" = '28028')
ORDER BY "WERKS" ASC,
    "MATNR" ASC,
    "STYLE_CD" ASC,
    "SIZE_CD" ASC,
    "COLOR_CD" ASC,
    "BACKING_CD" ASC,
    "ZF_QUALITY_CODE" ASC,
    "ZF_ORIG_LENGTH_IN" ASC,
    "ZF_BALANCE_WIDTH_IN" ASC,
    "WIDTH" ASC,
    "LENGTH" ASC,
    "ZC_FIBER_BRAND_CD" ASC,
    "ZC_FIBER_BRAND_DESC" ASC