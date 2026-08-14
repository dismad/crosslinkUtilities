# crosslinkUtilities

Small collection of bash helpers for interacting with a local [Crosslink](https://github.com/ShieldedLabs/crosslink_monolith) (zebra-crosslink) node via JSON-RPC.

These scripts are intended for the Crosslink incentivized feature nets / testnets. They make it easy to inspect staking positions, rewards, Staking Day windows, finalizer roster, finality status, and individual bonds.

## Quick Install

```bash
curl -sL https://raw.githubusercontent.com/dismad/crosslinkUtilities/main/install.sh | bash
```

This will:
- Check for `curl` and `jq` (and install them if missing)
- Download all scripts into `~/crosslinkUtilities`
- Make them executable

Install to a custom directory:

```bash
curl -sL https://raw.githubusercontent.com/dismad/crosslinkUtilities/main/install.sh | bash -s -- ~/bin
```

After installing, either add the directory to your `PATH` or run the scripts with the full path.

## Requirements

- `curl`
- `jq`
- A running zebra-crosslink node with the RPC server enabled (default `http://127.0.0.1:8232`)

You can override the RPC endpoint with the environment variable:

```bash
export ZEBRAD_RPC="http://127.0.0.1:8232"
```

## Scripts

### `crosslinkStatus.sh`

One-shot overview (recommended daily driver).

```bash
./crosslinkStatus.sh          # short summary
./crosslinkStatus.sh -f       # also dump full get_tfl_recency_status JSON
./crosslinkStatus.sh --full
```

Shows:
- Current height
- Whether you are currently inside a Staking Day + blocks remaining / until next
- Whether TFL is activated
- Current finalized tip (height + hash)
- Number of active + withdrawable bonds
- Total staking rewards earned

### `listRewards.sh`

List individual position rewards and/or the total.

```bash
./listRewards.sh              # both individual + total
./listRewards.sh -i           # individual only
./listRewards.sh -t           # total only
./listRewards.sh --individual
./listRewards.sh --total
```

### `listStakingInfo.sh`

Detailed view of every staking position (active + withdrawable), including:

- Finalizer
- `bond_key` / `pk` (needed for `wallet_staking_action` and `bondinfo.sh`)
- create height
- initial / latest value
- rewards earned

```bash
./listStakingInfo.sh
```

### `stakingDayInfo.sh`

Simple check of the current Staking Day window.

```bash
./stakingDayInfo.sh
```

**Season 1 parameters** (as documented by Shielded Labs):
- New Staking Day every **150** blocks
- Window is open for **70** blocks

Staking / unbonding / withdrawing is only allowed during the open window. Retargeting is allowed at any time.

### `roster.sh`

Show the current finalizer roster and stake distribution.

```bash
./roster.sh                   # stake shown in ZEC
./roster.sh -z                # stake shown in zatoshis
./roster.sh --zats
```

### `finality.sh`

Show the current finalized tip and optionally check finality of a specific block or transaction.

```bash
./finality.sh                           # current finalized tip only
./finality.sh -b <block_hash>           # check a block hash
./finality.sh --block <block_hash>
./finality.sh -t <txid>                 # check a transaction hash
./finality.sh --tx <txid>
```

### `bondinfo.sh`

Lookup detailed information for a single bond.

```bash
./bondinfo.sh <bond_key>
```

`bond_key` is the `pk` field returned by `listStakingInfo.sh` / `wallet_staking_positions`.

## Notes

- All amounts are converted from zatoshis (`/ 1e8`) and displayed in ZEC where appropriate.
- `bond_key` values come from the `pk` field returned by `wallet_staking_positions`.
- These scripts only **read** data. They do not submit staking transactions.
- For the full set of wallet staking RPCs (`wallet_staking_action`, etc.) see the [v13_rc1 release notes](https://github.com/ShieldedLabs/crosslink_monolith/releases/tag/v13_rc1).

## License

MIT
