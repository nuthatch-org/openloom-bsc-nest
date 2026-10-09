# openloom-bsc-nest

A [nuthatch](https://github.com/nuthatch-org/nuthatch) nest that answers the GraphQL of the
`openloom-bsc` subgraph on BNB Smart Chain, deployment
`QmXsbGm5Mbm9H5HWrt11uwWSf58MyaxjspF4TNYx166Xgz`, while no indexer on The Graph network serves it.
It is a stopgap, stood up on 2026-10-08 when Subgraph Studio stopped serving BNB Chain subgraphs.

| | |
| --- | --- |
| Endpoint | `https://subgraphs.nuthatch-indexer.com/subgraphs/id/QmXsbGm5Mbm9H5HWrt11uwWSf58MyaxjspF4TNYx166Xgz` |
| Page (status, playground, snippets) | https://nuthatch-indexer.com/subgraphs/QmXsbGm5Mbm9H5HWrt11uwWSf58MyaxjspF4TNYx166Xgz |
| Unserved on the network since | 2026-07-02 16:06 UTC (last allocation closed) |
| Last contract activity | 2026-05-19, so the data is complete and frozen |
| Record | [nuthatch-org/graph-support#53](https://github.com/nuthatch-org/graph-support/issues/53) |

## What it answers

Every field of 13 entities: `Card`, `Medal`, `Minter`, `MintPool`, `Token`, `Mint`, `Subscribe`,
`Ransom`, `BoardRelease`, `Reward`, `Brokerage`, `Harvest` and `Distribute`. Two things are not
served, and a query that asks for one gets an error naming it:

- `DailyState`: day-keyed running totals the mappings accumulate.
- `Distribute.operator`: the transaction sender, which the nest does not store.

The subgraph's mapping source is not public, so each handler's field assignments were read from the
deployed mapping WASM on IPFS rather than guessed from names. The views in `views/` carry the rule for
each entity in their header comment. Two of the less obvious ones:

- An id built by `concatI32` appends the integer as four **little-endian** bytes, as graph-ts does:
  card 10000 is `0x10270000`.
- `MintPool.totalSupply` and `Minter.supply` are running totals over `Subscribe` (adds `amount`),
  `Mint` (subtracts `usdtAmount`) and `Ransom` (subtracts `amount`), keyed by token and `cardIndex`.
  `Distribute.amount` is that total when the event fires, times `distributeRadio`, over 10^12,
  truncated.

**Checked:** the owner of 60 randomly sampled cards matches the Card contract's `ownerOf` on chain,
60 of 60. No graph-node serves the deployment, so the answers could not be compared with the
subgraph's own.

## Query it

```sh
curl -s https://subgraphs.nuthatch-indexer.com/subgraphs/id/QmXsbGm5Mbm9H5HWrt11uwWSf58MyaxjspF4TNYx166Xgz \
  -H 'content-type: application/json' \
  -d '{"query": "{ tokens { id name } }"}'
```

It takes the same queries a graph-node endpoint does: `where` filters, `orderBy`, `first`, `skip`,
`_meta` and introspection. Example documents are in [`queries/`](queries).

## Run it yourself

You need the `nuthatch-graph` build (a release download, or `cargo build --release --features graph`),
an x86_64 Linux machine or an Apple Silicon Mac, and an archive BNB Chain endpoint: the public ones do
not serve history back to block 48.9M.

```sh
git clone https://github.com/nuthatch-org/openloom-bsc-nest
nuthatch dev --dir openloom-bsc-nest --rpc "$BNB_ARCHIVE_RPC" --state-rpc "$BNB_ARCHIVE_RPC" \
  --seal-direct --concurrency 8
```

The full backfill is about 77 million blocks and 659,873 events. With those two flags, 71 million of
the blocks took about seven minutes on a 32-core machine against a paid endpoint, on 2026-10-08. GraphQL is then at
`http://127.0.0.1:8288/subgraphs/id/QmXsbGm5Mbm9H5HWrt11uwWSf58MyaxjspF4TNYx166Xgz`.

`.deploy/` holds what runs the hosted copy: the launcher, its systemd user unit, and the Caddy block.

## Going back to the network

The stopgap ends when an indexer allocates to the deployment. Ask in The Graph's `#indexers` channel
for an allocation on `QmXsbGm5Mbm9H5HWrt11uwWSf58MyaxjspF4TNYx166Xgz`, then point your client back at
`https://gateway.thegraph.com/api/<key>/deployments/id/QmXsbGm5Mbm9H5HWrt11uwWSf58MyaxjspF4TNYx166Xgz`.

## Limits

One machine on a home connection serves the hosted copy: no uptime promise, no proof of indexing, no
allocation and no dispute path.
