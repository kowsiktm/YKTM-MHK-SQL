DO BEGIN T_MARA =
SELECT DISTINCT MATNR,
    MSTAE
FROM "QS5_TO_AIQ".MARA;
T_MARC =
SELECT DISTINCT MATNR,
    MAABC,
    MMSTA,
    A."WERKS",
    NAME1 PLANT_NAME,
    F.BUKRS,
    BUTXT COMP_DESC
FROM "QS5_TO_AIQ".MARC A
    LEFT JOIN "QS5_TO_AIQ".T001K F ON A.WERKS = BWKEY
    LEFT JOIN "QS5_TO_AIQ".T001 D ON F.BUKRS = D.BUKRS
    LEFT JOIN "QS5_TO_AIQ".T001W E ON A.WERKS = E.WERKS
WHERE F.BUKRS = 5860;
--SELECT * FROM :T_MARA;
--
--SELECT * FROM :T_MARC;
SELECT DISTINCT WERKS,
    PLANT_NAME,
    BUKRS,
    COMP_DESC,
    MAABC,
    A.MMSTA,
    MSTAE,
    MTSTB SKU_RANK_DESC
FROM :T_MARC A
    LEFT JOIN :T_MARA B ON A.MATNR = B.MATNR
    LEFT JOIN "QS5_TO_AIQ".T141T C ON B.MSTAE = C.MMSTA
    AND SPRAS = 'E';
END