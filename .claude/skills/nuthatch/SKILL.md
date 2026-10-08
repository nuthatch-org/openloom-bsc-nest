---
name: nuthatch
description: Query this self-hosted nuthatch nest on bsc - decoded events, balances, and read-only SQL. Use when asked about on-chain activity for these contracts.
---

# Querying the nuthatch nest

Contracts indexed on bsc:
- `factory` = 0xea82f9d5f2832295b5d3b75f0e9f260b2694fb03
- `card_factory` = 0x6a40b14e33984c8179cfd751fe8ca0d188b06868
- `card` = 0xdab4c309944a61a42a1879fcc7381c47a5561377

Data is local - never call an external API for it.

## Preferred: MCP
If a `nuthatch` MCP server is configured, use its tools. Call `schema` first to learn the
data model, then `sql` / `entity` / `balance` / `top_balances`.

## Fallback: HTTP (a `nuthatch dev` must be running)
- Recent rows:  `curl localhost:8288/entities?limit=20`
- Read-only SQL: `curl -G localhost:8288/sql --data-urlencode 'q=SELECT count(*) FROM board_template__release'`

`sql` reads hot and sealed rows together, so it covers the live tip. Each answer's
`provenance.sealed_through` is where finalized data ends.
