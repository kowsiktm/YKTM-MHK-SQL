DO BEGIN T_BOM =
SELECT "WERKS",
    "INVENTORY_PKG_SKU",
    "SELLING_PKG_SKU",
    "INVENTORY_COMP_SKU",
    "SELLING_COMP_SKU",
    "MEINS",
    "MENGE"
FROM "_SYS_BIC"."Work.inventory.POC/DEL_MHK_IM_BOM";
T_BOM_SUM =
SELECT "WERKS",
    "INVENTORY_PKG_SKU",
    "MEINS",
    SUM("MENGE") PKG_SUM
FROM "_SYS_BIC"."Work.inventory.POC/DEL_MHK_IM_BOM"
GROUP BY "WERKS",
    "INVENTORY_PKG_SKU",
    "MEINS";
T_INV =
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
    "PLANT_DESC";
V_OUT =
SELECT MATNR,
    A."WERKS",
    A."INVENTORY_PKG_SKU",
    "SELLING_PKG_SKU",
    "INVENTORY_COMP_SKU",
    "SELLING_COMP_SKU",
    A."MEINS",
    "MENGE",
    PKG_SUM,
    TOTAL_INV_QUAN_SUM
FROM :T_BOM A
    LEFT JOIN :T_INV B ON A."INVENTORY_COMP_SKU" = B.MATNR
    AND A.WERKS = B.WERKS
    LEFT JOIN :T_BOM_SUM C ON A.WERKS = C.WERKS
    AND A.INVENTORY_PKG_SKU = C.INVENTORY_PKG_SKU;
SELECT *
FROM :V_OUT;
SELECT "WERKS",
    "INVENTORY_PKG_SKU",
    "SELLING_PKG_SKU",
    "INVENTORY_COMP_SKU",
    "SELLING_COMP_SKU",
    "MEINS",
    "MENGE",
    PKG_SUM,
    TOTAL_INV_QUAN_SUM
FROM :V_OUT
WHERE MATNR IS NOT NULL
ORDER BY "INVENTORY_PKG_SKU",
    "SELLING_PKG_SKU",
    "INVENTORY_COMP_SKU",
    "SELLING_COMP_SKU";
END