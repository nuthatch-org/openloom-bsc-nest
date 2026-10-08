-- Token: handleCreateToken, id = the token address.
CREATE VIEW token AS
SELECT token AS id, name, sysmbol, "totalSupply", token, medal, board, forge, bonus, achievement, CAST(block_timestamp AS INT) AS "createAt"
FROM factory__create_token;
