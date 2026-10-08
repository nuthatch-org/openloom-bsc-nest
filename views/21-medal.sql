-- Medal: handleMintMedal (id = medal || medalId as little-endian i32); the medal contract's Transfer
-- moves owner on an existing medal only.
CREATE VIEW medal AS
WITH mk AS (
  SELECT medal AS m_addr, CAST("medalId" AS BIGINT) AS mid, owner, CAST("medalType" AS BIGINT) AS mtype,
         block_timestamp AS ts, CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT) AS pos,
         row_number() OVER (PARTITION BY medal, CAST("medalId" AS BIGINT) ORDER BY CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT) DESC) AS rn
  FROM bonus_template__mint_medal
), m AS (SELECT * FROM mk WHERE rn = 1),
last AS (
  SELECT m.m_addr, m.mid, t."to", row_number() OVER (PARTITION BY m.m_addr, m.mid ORDER BY CAST(t.block_number AS BIGINT) * 1000000 + CAST(t.log_index AS BIGINT) DESC) AS rn
  FROM m JOIN medal_template__transfer t ON t.address = m.m_addr AND CAST(t."tokenId" AS BIGINT) = m.mid
   AND CAST(t.block_number AS BIGINT) * 1000000 + CAST(t.log_index AS BIGINT) > m.pos
)
SELECT m.m_addr || lpad(to_hex((m.mid) & 255), 2, '0') || lpad(to_hex(((m.mid) >> 8) & 255), 2, '0') || lpad(to_hex(((m.mid) >> 16) & 255), 2, '0') || lpad(to_hex(((m.mid) >> 24) & 255), 2, '0') AS id, m.m_addr AS medal, COALESCE(l."to", m.owner) AS owner,
       CAST(m.mid AS INT) AS "medalId", CAST(m.mtype AS INT) AS "medalType", CAST(m.ts AS INT) AS "createAt"
FROM m LEFT JOIN last l ON l.m_addr = m.m_addr AND l.mid = m.mid AND l.rn = 1;
