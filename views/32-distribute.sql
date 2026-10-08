-- Distribute: amount = the pool's totalSupply when the event fires * distributeRadio / 10^12, truncated;
-- 0 when no pool exists yet. Dividing by 10^12 drops twelve digits of the exact product: SQL division here returns a float. NOT IN THIS VIEW: operator (the transaction sender, which this nest does not store).
CREATE VIEW distribute AS
WITH e AS (
  SELECT tx_hash || lpad(to_hex((CAST(log_index AS BIGINT)) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 8) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 16) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 24) & 255), 2, '0') AS id, token, "blockHash" AS hash, tx_hash AS "txHash", CAST(block_number AS INT) AS "blockNumber",
         CAST(index AS INT) AS index, CAST("poolId" AS INT) AS "poolId", "distributeRadio",
         CAST("distributeRadio" AS DECIMAL(37,0)) AS r, CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT) AS pos, block_timestamp AS ts
  FROM forge_template__distribute
), p AS (
  SELECT e.id, (SELECT SUM(s.d) FROM ol_supply s WHERE s.token = e.token AND s.ci = e."poolId" AND s.pos < e.pos) AS supply,
         CAST(CAST((SELECT SUM(s.d) FROM ol_supply s WHERE s.token = e.token AND s.ci = e."poolId" AND s.pos < e.pos) AS DECIMAL(25,0)) * CAST(e."distributeRadio" AS DECIMAL(13,0)) AS VARCHAR) AS ps,
         (SELECT COUNT(*) FROM ol_supply s WHERE s.token = e.token AND s.ci = e."poolId" AND s.sub = 1 AND s.pos < e.pos) AS created
  FROM e
)
SELECT e.id, e.token, e.hash, e."txHash", e."blockNumber", e.index, e."poolId", e."distributeRadio",
       CASE WHEN p.created = 0 THEN '0'
            ELSE CASE WHEN length(p.ps) <= 12 THEN '0' ELSE substr(p.ps, 1, length(p.ps) - 12) END END AS amount,
       CAST(e.ts AS INT) AS "createAt"
FROM e JOIN p ON p.id = e.id;
