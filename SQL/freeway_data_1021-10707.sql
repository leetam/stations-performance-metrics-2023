SELECT
  *
FROM
  freeway.aggregated_data
WHERE
  detector_id in (100788, 100789, 100191, 100192, 100193) AND
  resolution in ('01:00:00', '1 day') AND
  starttime > '2019-01-01 00:00:00'