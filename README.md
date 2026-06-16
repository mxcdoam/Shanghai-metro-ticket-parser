# Shanghai-metro-ticket-parser

Parses Shanghai Metro single-journey tickets (and possibly - day passes) stored on Fudan FM11RF005SH chips using a Proxmark3.

**Warning: work in progress — some fields may be parsed incorrectly.**

## Usage

Requires a Proxmark3. Place `shmrt_parser.lua` in `client/luascripts/`, connect the device, run the client and then - run the script:

```
script run shmrt_parser
```

Put a card on the Proxmark3, and press `1` + Enter. Press `0` + Enter to exit.

### From a dump (no card needed)

```
script run shmrt_parser -d <hex>
```

Accepts either:
- Full 8-block dump (64 hex chars) — strips blocks 0-1 automatically
- Blocks 2-7 only (48 hex chars)

Spaces are ignored:

```
script run shmrt_parser -d "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
```

## Station data

Station lookup table sourced from the [TripReader project](https://github.com/domosekai/tripreader-data).

## Contributing

The ticket format is still partially unknown. If you'd like to help, please open a GitHub issue and share:

- A hex dump of the ticket (all 8 blocks)
- The station where you purchased it
- The date and approximate time of purchase
- The fare loaded on the card

Any additional context helps piece together the remaining unknown fields.

## License

GPLv3 
