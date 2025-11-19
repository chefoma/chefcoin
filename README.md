# Chefcoin

Chefcoin is a fungible token smart contract written in [Clarity](https://www.stacks.co/clarity) and developed with [Clarinet](https://github.com/hirosystems/clarinet).

This repository contains:

- A Clarinet project configuration (`Clarinet.toml`)
- The `chefcoin` fungible token contract in `contracts/chefcoin.clar`

## Prerequisites

- Node.js and npm (for installing Clarinet, if not already installed)
- Clarinet CLI `clarinet` (version 3.x)

To check Clarinet is installed:

```bash path=null start=null
clarinet --version
```

If it is not installed, you can install it globally via npm:

```bash path=null start=null
npm install -g @hirosystems/clarinet
```

## Project Structure

- `Clarinet.toml` – Clarinet project configuration, including contract registration
- `contracts/chefcoin.clar` – Chefcoin fungible token smart contract
- `LICENSE` – Project license

## Chefcoin Smart Contract

The `chefcoin` contract implements a simple fungible token with an interface similar to SIP-010:

- `transfer` – transfer tokens between principals
- `get-balance` – read the balance of a principal
- `get-total-supply` – read the total token supply
- `get-name` – token name ("Chefcoin")
- `get-symbol` – token symbol ("CHEF")
- `get-decimals` – token decimals (`6`)
- `get-token-uri` – optional metadata URI (currently `none`)
- `mint` – owner-only mint function to create new tokens

### Error Codes

The contract uses a small set of error codes:

- `u100` – not authorized (caller is not the contract owner for `mint`)
- `u101` – insufficient balance for `transfer`
- `u102` – invalid amount (e.g. zero amount)

## Common Commands

Run these from the project root (`/home/anthony/Documents/GitHub/chefcoin`).

### Check Contracts

Static check all contracts registered in `Clarinet.toml`:

```bash path=null start=null
clarinet check
```

### Format Contracts (Optional)

Format Clarity source files:

```bash path=null start=null
clarinet format
```

## Development Notes

- The contract owner is the deploying principal (`contract-owner` in Clarity).
- Only the owner can call `mint`.
- Balances are tracked in the `balances` map; total supply is stored in the `total-supply` data variable.
