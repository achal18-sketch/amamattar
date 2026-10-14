-- ClickHouse: evaluation analytics & bias audit (demographics are self-reported, optional,
-- stored separately from evaluation data and NEVER visible to the scoring/decision path).
CREATE TABLE evaluation_facts (
  tenant_id       UUID,
  job_posting_id  UUID,
  rubric_version  UInt32,
  session_id      UUID,
  completed_at    DateTime,
  jurisdiction    LowCardinality(String),
  overall_score   Float32,
  recommendation  LowCardinality(String),
  competency_key  LowCardinality(String),
  competency_score Float32,
  integrity_score Float32,
  -- joined at audit time from the isolated demographics store, nullable
  sex_category        LowCardinality(Nullable(String)),
  race_ethnicity      LowCardinality(Nullable(String)),
  age_band            LowCardinality(Nullable(String)),
  disability_declared Nullable(UInt8)
) ENGINE = MergeTree
PARTITION BY toYYYYMM(completed_at)
ORDER BY (tenant_id, job_posting_id, completed_at);

-- NYC LL144 impact ratio: selection rate per category / selection rate of most-selected category
-- selected := recommendation IN ('strong_hire','hire')
SELECT race_ethnicity,
       countIf(recommendation IN ('strong_hire','hire')) / count() AS selection_rate,
       selection_rate / max(selection_rate) OVER () AS impact_ratio
FROM (SELECT DISTINCT session_id, race_ethnicity, recommendation FROM evaluation_facts
      WHERE tenant_id = {tenant:UUID} AND completed_at >= now() - INTERVAL 1 YEAR)
GROUP BY race_ethnicity;
