-- Every change to a pool's supply: Subscribe adds amount; Mint subtracts usdtAmount; Ransom subtracts amount.
-- MintPool and Minter share the key (token, cardIndex) and the same running total.
CREATE VIEW ol_supply AS
SELECT token, CAST("cardIndex" AS BIGINT) AS ci, CAST("cardId" AS BIGINT) AS cid, CAST(amount AS DECIMAL(37,0)) AS d, block_timestamp AS ts, CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT) AS pos, 1 AS sub FROM forge_template__subscribe
  UNION ALL SELECT token, CAST("cardIndex" AS BIGINT), CAST("cardId" AS BIGINT), -CAST("usdtAmount" AS DECIMAL(37,0)), block_timestamp, CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT), 0 FROM forge_template__mint
  UNION ALL SELECT token, CAST("cardIndex" AS BIGINT), CAST("cardId" AS BIGINT), -CAST(amount AS DECIMAL(37,0)), block_timestamp, CAST(block_number AS BIGINT) * 1000000 + CAST(log_index AS BIGINT), 0 FROM forge_template__ransom;
