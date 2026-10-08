-- Card: handleMakeCard writes it (id = Bytes.fromI32(tokenId), little-endian); handleTransfer only
-- moves owner on a card that already exists, so a Transfer before its MakeCard is ignored.
CREATE VIEW card AS
WITH mk AS (
  SELECT CAST("tokenId" AS BIGINT) AS tid, "user", nickname, CAST("imageIndex" AS BIGINT) AS img,
         CAST("parentCardId" AS BIGINT) AS par, block_timestamp AS ts, CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT) AS pos,
         row_number() OVER (PARTITION BY CAST("tokenId" AS BIGINT) ORDER BY CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT) DESC) AS rn
  FROM card_factory__make_card
), m AS (SELECT * FROM mk WHERE rn = 1),
last AS (
  SELECT m.tid, t."to", row_number() OVER (PARTITION BY m.tid ORDER BY CAST(t.block_number AS BIGINT) * 1000000 + CAST(t.log_index AS BIGINT) DESC) AS rn
  FROM m JOIN card__transfer t ON CAST(t."tokenId" AS BIGINT) = m.tid
   AND CAST(t.block_number AS BIGINT) * 1000000 + CAST(t.log_index AS BIGINT) > m.pos
)
SELECT '0x' || lpad(to_hex((m.tid) & 255), 2, '0') || lpad(to_hex(((m.tid) >> 8) & 255), 2, '0') || lpad(to_hex(((m.tid) >> 16) & 255), 2, '0') || lpad(to_hex(((m.tid) >> 24) & 255), 2, '0') AS id, COALESCE(l."to", m."user") AS owner, m.nickname,
       CAST(m.tid AS INT) AS "cardId", CAST(m.img AS INT) AS "imageIndex", CAST(m.par AS INT) AS "parentCardId",
       CAST(m.ts AS INT) AS "createAt"
FROM m LEFT JOIN last l ON l.tid = m.tid AND l.rn = 1;
