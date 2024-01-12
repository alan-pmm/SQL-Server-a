
--EJERCIO 1 ----------------------------------------------------
/*
--POSSIBLE CASES
SELECT DISTINCT F.FACTURADO, P.COBRADO, R.ESTADO  FROM [dbo].[FINANZAS] F
LEFT JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
LEFT JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
-- C = 2 * 2 * 2 
-- C = 8 
*/


---EJERCIO 1 PROPOSICION SCRIPT 1 
--REPORT : ID COBRADO FACTURADO CERRADA TIENE LAS 3 CONDICIONES
WITH pte AS (
SELECT  P.ID 
FROM [dbo].[FINANZAS] F
INNER JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
INNER JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
WHERE FACTURADO = 'T' -- NO FACTURADA
AND R.ESTADO = 'CERRADA'
AND YEAR(R.TIMESTAMP_) = 2017 -- A�O 2017
AND P.COBRADO = 'T' --PAGADO
AND R.WEBSITE = 'ES' --ESPA�A
) --Y AQUI LOS EXCLUIMOS
SELECT P.ID AS PRODUCT_ID, F.RESERVA_ID,F.AGENTE_ASIGNADO , P.COBRADO, R.ESTADO, F.FACTURADO
, P.PRECIO_EN_EUR, R.TIMESTAMP_
FROM [dbo].[FINANZAS] F
INNER JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
INNER JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
WHERE P.ID NOT IN (SELECT ID FROM pte)
AND R.WEBSITE = 'ES' --ESPA�A
AND YEAR(R.TIMESTAMP_) = 2017 -- A�O 2017


--EJERCIO 1 PROPOSICION SCRIPT 2 
SELECT  P.ID INTO #A
FROM [dbo].[FINANZAS] F
INNER JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
INNER JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
WHERE FACTURADO = 'T' -- FACTURADA
AND R.ESTADO = 'CERRADA'
AND YEAR(R.TIMESTAMP_) = 2017 -- A�O 2017
AND P.COBRADO = 'T' --PAGADO
AND R.WEBSITE = 'ES' --ESPA�A
ORDER BY 1
;
CREATE CLUSTERED INDEX A ON #A(ID);

SELECT  P.ID AS PRODUCT_ID, F.RESERVA_ID,F.AGENTE_ASIGNADO , P.COBRADO, R.ESTADO, F.FACTURADO
, P.PRECIO_EN_EUR, R.TIMESTAMP_ 
FROM [dbo].[FINANZAS] F
INNER JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
INNER JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
LEFT JOIN #A ON P.ID = #A.ID
WHERE #A.ID IS NULL
AND R.WEBSITE = 'ES' --ESPA�A
AND YEAR(R.TIMESTAMP_) = 2017 -- A�O 2017
;
DROP TABLE #A;


--EJERCIO 1 PROPOSICION SCRIPT 3 
SELECT  P.ID INTO #A
FROM [dbo].[FINANZAS] F
INNER JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
INNER JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
WHERE FACTURADO = 'T' -- FACTURADA
AND R.ESTADO = 'CERRADA'
AND YEAR(R.TIMESTAMP_) = 2017 -- A�O 2017
AND P.COBRADO = 'T' --PAGADO
AND R.WEBSITE = 'ES' --ESPA�A
ORDER BY 1
;
CREATE CLUSTERED INDEX A ON #A(ID);

SELECT  P.ID AS PRODUCT_ID, F.RESERVA_ID,F.AGENTE_ASIGNADO , P.COBRADO, R.ESTADO, F.FACTURADO
, P.PRECIO_EN_EUR, R.TIMESTAMP_ 
FROM [dbo].[FINANZAS] F
INNER JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
INNER JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
--LEFT JOIN #A ON P.ID = #A.ID
WHERE NOT EXISTS (SELECT ID FROM #A WHERE #A.ID = P.ID) 
AND R.WEBSITE = 'ES' --ESPA�A
AND YEAR(R.TIMESTAMP_) = 2017 -- A�O 2017
;
DROP TABLE #A;



--EJERCIO 2 ----------------------------------------------------
--AGGREGACION POR WEBSITE Y A�O
SELECT YEAR(R.TIMESTAMP_) AS YEAR_, R.WEBSITE , P.COBRADO, R.ESTADO, F.FACTURADO 
, COUNT(DISTINCT F.RESERVA_ID) COUNT_RESERVA ,COUNT(P.ID) AS COUNT_PRODUCT
,  SUM(P.PRECIO_EN_EUR) AS SUM_EUR
, CONVERT(VARCHAR, FLOOR(SUM(P.PRECIO_EN_EUR) / (SELECT SUM(PRECIO_EN_EUR) FROM dbo.PRODUCTO) * 100)) + '%' AS PERCENTAGE_AMOUNT_EUR_IMPACT
FROM [dbo].[FINANZAS] F
INNER JOIN dbo.PRODUCTO P ON F.RESERVA_ID = P.RESERVA_ID
INNER JOIN dbo.RESERVA R ON F.RESERVA_ID = R.ID
GROUP BY YEAR(R.TIMESTAMP_), R.WEBSITE , P.COBRADO, R.ESTADO, F.FACTURADO 
ORDER BY SUM(P.PRECIO_EN_EUR) DESC;