# crosslinkUtilities

Small collection of bash helpers for interacting with a local [Crosslink](https://github.com/ShieldedLabs/crosslink_monolith) (zebra-crosslink) node via JSON-RPC.

These scripts are intended for the Crosslink incentivized feature nets / testnets. They make it easy to inspect staking positions, rewards, Staking Day windows, and basic TFL status.

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
- `bond_key` / `pk` (needed for `wallet_staking_action`)
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

## Notes

- All amounts are converted from zatoshis (`/ 1e8`) and displayed in ZEC.
- `bond_key` values come from the `pk` field returned by `wallet_staking_positions`.
- These scripts only **read** data. They do not submit staking actions.

## License

MIT
