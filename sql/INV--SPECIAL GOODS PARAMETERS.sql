--SPECIAL GOODS PARAMETERS
Generated SQL:
SELECT TOP 5000 DISTINCT "WERKS",
    "ZZMSTBRAND_DESC",
    "PRODUCT_LINE_DESC",
    "PRODUCT_GROUP_DESC",
    "PRODUCT_TYPE_DESC",
    "STYLE_DESC",
    "BACKING_DESC",
    "ZF_QUALITY_DESC",
    "ZF_QUALITY_CODE",
    "ZF_QUALITY_REASON_CD",
    "ZF_2ND_QUALITY_REASON_CODE",
    "LENGTH",
    "MSTAE",
    "CROSS_PLANT_MATERIAL_STATUS_DESC",
    "ZF_AGE_IN_MONTHS",
    "MAABC",
    "ZC_FIBER_BRAND_CD",
    "ZC_FIBER_BRAND_DESC",
    "BUYING_GROUP"
FROM "_SYS_BIC"."MHK_FNA.Reuse.Inventory/MHK_RVCU_IM_CURRENT_INVENTORY"(
        'PLACEHOLDER' = ('$$IP_CPUDT$$', '20221101'),
        'PLACEHOLDER' = ('$$IP_UOM$$', 'LFT')
    )
WHERE ("WERKS" = '6211')
ORDER BY "WERKS" ASC,
    "ZZMSTBRAND_DESC" ASC,
    "PRODUCT_LINE_DESC" ASC,
    "PRODUCT_GROUP_DESC" ASC,
    "PRODUCT_TYPE_DESC" ASC,
    "STYLE_DESC" ASC,
    "BACKING_DESC" ASC,
    "ZF_QUALITY_DESC" ASC,
    "ZF_QUALITY_CODE" ASC,
    "ZF_QUALITY_REASON_CD" ASC,
    "ZF_2ND_QUALITY_REASON_CODE" ASC,
    "LENGTH" ASC,
    "MSTAE" ASC,
    "CROSS_PLANT_MATERIAL_STATUS_DESC" ASC,
    "ZF_AGE_IN_MONTHS" ASC,
    "MAABC" ASC,
    "ZC_FIBER_BRAND_CD" ASC,
    "ZC_FIBER_BRAND_DESC" ASC,
    "BUYING_GROUP" ASC