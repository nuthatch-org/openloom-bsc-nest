-- Subscribe: one row per event, id = transaction hash || log index as little-endian i32.
CREATE VIEW subscribe AS
SELECT tx_hash || lpad(to_hex((CAST(log_index AS BIGINT)) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 8) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 16) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 24) & 255), 2, '0') AS id, token, owner, CAST("cardId" AS INT) AS "cardId", CAST("cardIndex" AS INT) AS "cardIndex", amount, CAST(block_timestamp AS INT) AS "createAt"
FROM forge_template__subscribe;
