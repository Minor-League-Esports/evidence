WITH raw AS (
    SELECT *
    FROM read_csv(
        'https://docs.google.com/spreadsheets/d/1xsWBR-ZaF3WEY-cel2mk0pNdLd5_Qlg5-Ir5gfAT78U/gviz/tq?tqx=out:csv&sheet=Champions',
        header = false
    )
    WHERE TRY_CAST(column00 AS INTEGER) IS NOT NULL
)

-- Seasons 12+: FL/AL/CL/ML/PL with Doubles and Standard
SELECT
    CAST(column00 AS INTEGER)   AS season,
    CAST(NULL AS VARCHAR)       AS solo_doubles,
    NULLIF(TRIM(column02), '')  AS fl_doubles,
    NULLIF(TRIM(column04), '')  AS fl_standard,
    NULLIF(TRIM(column06), '')  AS al_doubles,
    NULLIF(TRIM(column08), '')  AS al_standard,
    NULLIF(TRIM(column10), '')  AS cl_doubles,
    NULLIF(TRIM(column12), '')  AS cl_standard,
    NULLIF(TRIM(column14), '')  AS ml_doubles,
    NULLIF(TRIM(column16), '')  AS ml_standard,
    NULLIF(TRIM(column18), '')  AS pl_doubles,
    NULLIF(TRIM(column20), '')  AS pl_standard
FROM raw
WHERE CAST(column00 AS INTEGER) >= 12
  AND (
    TRIM(COALESCE(column02, '')) != ''
    OR TRIM(COALESCE(column04, '')) != ''
    OR TRIM(COALESCE(column06, '')) != ''
    OR TRIM(COALESCE(column08, '')) != ''
    OR TRIM(COALESCE(column10, '')) != ''
  )

UNION ALL

-- Season 11: FL/AL/CL/ML/PL — Doubles only
SELECT
    CAST(column00 AS INTEGER),
    NULL,
    NULLIF(TRIM(column02), ''),  -- FL
    NULL,
    NULLIF(TRIM(column04), ''),  -- AL
    NULL,
    NULLIF(TRIM(column06), ''),  -- CL
    NULL,
    NULLIF(TRIM(column08), ''),  -- ML
    NULL,
    NULLIF(TRIM(column10), ''),  -- PL
    NULL
FROM raw
WHERE CAST(column00 AS INTEGER) = 11

UNION ALL

-- Seasons 8-10: FL/AL/CL/PL — Doubles only (no ML)
SELECT
    CAST(column00 AS INTEGER),
    NULL,
    NULLIF(TRIM(column02), ''),  -- FL
    NULL,
    NULLIF(TRIM(column04), ''),  -- AL
    NULL,
    NULLIF(TRIM(column06), ''),  -- CL
    NULL,
    NULL,                        -- ML (didn't exist)
    NULL,
    NULLIF(TRIM(column08), ''),  -- PL
    NULL
FROM raw
WHERE CAST(column00 AS INTEGER) BETWEEN 8 AND 10

UNION ALL

-- Seasons 6-7: AL/CL — Doubles only
SELECT
    CAST(column00 AS INTEGER),
    NULL,
    NULL,                        -- FL (didn't exist)
    NULL,
    NULLIF(TRIM(column02), ''),  -- AL
    NULL,
    NULLIF(TRIM(column04), ''),  -- CL
    NULL,
    NULL,                        -- ML (didn't exist)
    NULL,
    NULL,                        -- PL (didn't exist)
    NULL
FROM raw
WHERE CAST(column00 AS INTEGER) BETWEEN 6 AND 7

UNION ALL

-- Seasons 1-5: single champion, no leagues — Doubles only
SELECT
    CAST(column00 AS INTEGER),
    NULLIF(TRIM(column02), ''),  -- solo champion
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
FROM raw
WHERE CAST(column00 AS INTEGER) BETWEEN 1 AND 5

ORDER BY season DESC
