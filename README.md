# Onchain Voting App

An end-to-end Web3 voting system built as a monorepo.

The project combines:

- Smart contracts (Foundry)
- Frontend dApp (React + Vite + wagmi)
- Event indexing (rindexer config)

## What This Project Does

At a high level:

1. Admin creates a proposal in the DAO.
2. Eligible users receive ClaimTicket NFTs.
3. Users redeem tickets into GovernanceNFTs.
4. Users vote with GovernanceNFT ownership.
5. Votes are counted onchain and proposal can be closed.

## Monorepo Structure

```text
onchain-voting-app/
	contracts/   # Solidity contracts, scripts, and Foundry tests
	frontend/    # React frontend for wallet connection and voting UI
	indexer/     # rindexer configuration and generated CSV event output
```

## High-Level Architecture

```text
User -> Frontend -> GovernanceDAO
									 -> ClaimTicket
									 -> GovernanceNFTRedeemer
									 -> GovernanceNFTFactory -> GovernanceNFT (per proposal)

GovernanceNFT events -> Indexer -> CSV/analytics
```

## Main Components

### Contracts

Core contracts live in [contracts/src](contracts/src) and include:

- GovernanceDAO
- GovernanceNFTFactory
- GovernanceNFT
- ClaimTicket
- GovernanceNFTRedeemer

Detailed contract documentation and commands are in [contracts/README.md](contracts/README.md).

### Frontend

Frontend app lives in [frontend](frontend) and uses React, Vite, wagmi, viem, and RainbowKit.

### Indexer

Indexer config is in [indexer/rindexer.yaml](indexer/rindexer.yaml), currently set up for local Anvil (chain id 31337) and GovernanceNFT mint events.

## Prerequisites

- Foundry (forge, cast, anvil)
- Node.js 20+ recommended
- pnpm

References:

- Foundry: https://book.getfoundry.sh/
- Node.js: https://nodejs.org/
- pnpm: https://pnpm.io/

## Quick Start (Local End-to-End)

### 1) Clone and install dependencies

Install per module:

```bash
cd contracts && forge install
cd ../frontend && pnpm install
```

### 2) Start local chain

In terminal A:

```bash
cd contracts
anvil
```

### 3) Deploy and initialize contracts

In terminal B:

```bash
cd contracts
make setup-anvil
```

### 4) Run frontend

In terminal C:

```bash
cd frontend
pnpm dev
```

## Development Commands

### Contracts (Foundry)

```bash
cd contracts
forge build
forge test -vv
forge coverage
```

### Frontend

```bash
cd frontend
pnpm dev
pnpm build
pnpm lint
```

## Testing Strategy

Current contract suite includes unit/integration-style tests for:

- ClaimTicket
- GovernanceNFT
- GovernanceNFTFactory
- GovernanceNFTRedeemer
- GovernanceDAO

Run all contract tests:

```bash
cd contracts
forge test -vv
```

Run a single file:

```bash
cd contracts
forge test --match-path test/GovernanceDAOTest.t.sol -v
```

## Security and Trust Assumptions

- Access control is role-based (owner, redeemer, voters).
- Voting uses ownership checks and per-token single-use constraints.
- Proposal closure is owner-controlled.
- Local keys in scripts are for development only and must not be reused in production.

Before any public deployment, run an additional security review and threat model pass.

## Deployment Notes

- Local development is currently optimized for Anvil.
- For testnet/mainnet deployments, migrate RPC endpoints and private keys to environment variables and CI/CD secrets.
- Keep deployment scripts deterministic and versioned.

## Deprecated Artifacts

Deprecated but preserved files are kept under:

- [contracts/src/deprecated](contracts/src/deprecated)
- [contracts/script/deprecated](contracts/script/deprecated)

These are intentionally not part of the active governance flow.

## Recommended Next Improvements

1. Add an indexer README with exact run commands and expected outputs.
2. Add a frontend README with environment variables and local wallet setup.
3. Add CI workflows for forge test, frontend lint/build, and optional coverage upload.
