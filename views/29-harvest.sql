-- Harvest: one row per event, id = transaction hash || log index as little-endian i32.
CREATE VIEW harvest AS
SELECT tx_hash || lpad(to_hex((CAST(log_index AS BIGINT)) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 8) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 16) & 255), 2, '0') || lpad(to_hex(((CAST(log_index AS BIGINT)) >> 24) & 255), 2, '0') AS id, token, owner, CAST("medalId" AS INT) AS "medalId", amount, CAST(block_timestamp AS INT) AS "createAt"
FROM bonus_template__harvest;
