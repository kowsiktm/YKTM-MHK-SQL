DO (
    IN IP_MATNR NVARCHAR(5000) => 'K',
    IN IP_PRCTR NVARCHAR(5000) => '',
    IN IP_DATE NVARCHAR(8) => '20211201',
    IN IP_TIME NVARCHAR(6) => '000000'
) BEGIN
DECLARE FILTER VARCHAR(5000);
SELECT CASE
        WHEN IP_MATNR = ''
        AND IP_PRCTR = '' THEN 'CPUDT <= ''' || :IP_DATE || ''' AND CPUTM <= ''' || :IP_TIME || ''''
        WHEN IP_MATNR <> ''
        AND IP_PRCTR = '' THEN '  MATNR IN (' || :IP_MATNR || ') AND CPUDT <= ''' || :IP_DATE || ''' AND CPUTM <= ''' || :IP_TIME || ''''
        WHEN IP_MATNR = ''
        AND IP_PRCTR <> '' THEN ' PRCTR IN (' || :IP_PRCTR || ')  AND CPUDT <= ''' || :IP_DATE || ''' AND CPUTM <= ''' || :IP_TIME || ''''
        ELSE ' MATNR IN (' || :IP_MATNR || ') AND PRCTR IN (' || :IP_PRCTR || ')  AND CPUDT <= ''' || :IP_DATE || ''' AND CPUTM <= ''' || :IP_TIME || ''''
    END INTO FILTER
FROM DUMMY;
SELECT FILTER
FROM DUMMY;
END