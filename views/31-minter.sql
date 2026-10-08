-- Minter: same key and total as MintPool; cardId is the first Subscribe's.
CREATE VIEW minter AS
WITH f AS (SELECT token, ci, cid, ts, row_number() OVER (PARTITION BY token, ci ORDER BY pos) AS rn FROM ol_supply WHERE sub = 1)
SELECT f.token || lpad(to_hex((f.ci) & 255), 2, '0') || lpad(to_hex(((f.ci) >> 8) & 255), 2, '0') || lpad(to_hex(((f.ci) >> 16) & 255), 2, '0') || lpad(to_hex(((f.ci) >> 24) & 255), 2, '0') AS id, f.token, CAST(f.cid AS INT) AS "cardId", CAST(f.ci AS INT) AS "cardIndex",
       CAST((SELECT SUM(s.d) FROM ol_supply s WHERE s.token = f.token AND s.ci = f.ci) AS VARCHAR) AS supply,
       CAST(f.ts AS INT) AS "createAt"
FROM f WHERE f.rn = 1;
