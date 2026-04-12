# Onchain Voting Contracts (Foundry)

This directory contains Solidity contracts for an onchain voting system built around the following flow:

1. A proposal is created in the DAO.
2. ClaimTicket NFTs are distributed to eligible users.
3. GovernanceNFTRedeemer exchanges tickets for GovernanceNFTs.
4. GovernanceDAO accepts votes only from valid GovernanceNFT holders.

The project is configured for local development on Anvil and test execution with Foundry.

## Table of Contents

- Architecture
- Contracts
- Repository Structure (contracts)
- Quick Start
- Main Commands
- End-to-End Flow
- Testing and Quality
- Best Practices and Security
- Deprecated

## Architecture

Voting flow:

```text
GovernanceDAO.createProposal()
		|
		v
GovernanceNFTFactory.createGovernanceNFT(proposalId)
		|
		v
DAO transfers NFT ownership to GovernanceNFTRedeemer
		|
		v
ClaimTicket mint -> user redeem(ticketId)
		|
		v
Redeemer: burn ticket + safeMint GovernanceNFT
		|
		v
GovernanceDAO.vote(proposalId, tokenId, support)
```

## Contracts

### Core

- src/GovernanceDAO.sol
  - creates proposals
  - counts for/against votes
  - prevents double voting per tokenId
  - closes proposals

- src/GovernanceNFTFactory.sol
  - creates per-proposal GovernanceNFT clones
  - stores mapping proposalId -> nftAddress

- src/GovernanceNFT.sol
  - NFT representing one voting right for a specific proposal
  - mint restricted to owner (in practice: Redeemer)

- src/ClaimTicket.sol
  - distribution ticket used for redeem
  - burn restricted to authorized GovernanceNFTRedeemer

- src/GovernanceNFTRedeemer.sol
  - validates ticket ownership
  - burns ticket
  - mints GovernanceNFT for user

### Interfaces

- src/IGovernanceNFTFactory.sol

### Deprecated

- src/deprecated/MerkleClaim.sol
  - kept for potential future use
  - not part of the active governance flow

## Repository Structure (contracts)

```text
contracts/
  src/
  script/
  test/
  lib/
  foundry.toml
  Makefile
```

## Quick Start

### 1) Install dependencies

```bash
forge install
```

### 2) Build

```bash
forge build
```

### 3) Testy

```bash
forge test -vv
```

### 4) Start local chain

```bash
anvil
```

### 5) Run local setup scenario

In a second terminal:

```bash
make setup-anvil
```

This runs full local setup for testing the governance flow on Anvil.

## Main Commands

### Foundry

```bash
forge build
forge test
forge test --match-path test/GovernanceDAOTest.t.sol -v
forge coverage
forge fmt
```

### Make targets

```bash
make setup-anvil
make create-proposal
make voteFor PROPOSAL_ID=1 TOKEN_ID=0
make voteAgainst PROPOSAL_ID=1 TOKEN_ID=0
make result PROPOSAL_ID=1 DAO_ADDRESS=<address>
```

## End-to-End Flow (local)

1. Start Anvil.
2. Run `make setup-anvil`.
3. Verify deployed contracts and proposal state using scripts/cast.
4. Submit vote via Vote.s.sol.
5. Read results via GetProposalResult.s.sol or `make result`.

## Testing and Quality

Current test suite covers:

- ClaimTicket
- GovernanceNFT
- GovernanceNFTFactory
- GovernanceNFTRedeemer
- GovernanceDAO

Run a single test file:

```bash
forge test --match-path test/GovernanceNFTRedeemerTest.t.sol -v
```

Run all tests:

```bash
forge test -vv
```

Coverage report:

```bash
forge coverage
forge coverage --report lcov
```

## Best Practices and Security

### 1. Access control

- Keep roles explicitly separated (owner, redeemer, voter).
- Test negative scenarios for every role.

### 2. One-way redemption

- Tickets should be single-use.
- After redeem, ticket must be burned and impossible to reuse.

### 3. Double voting prevention

- A given tokenId can vote only once per proposal.
- Always test repeated vote attempts with the same token.

### 4. Deterministic tests

- Use fixed test accounts/addresses.
- Keep tests small, isolated, and readable.

### 5. Deployment hygiene

- Do not hardcode sensitive keys outside local development.
- Use environment variables for testnet/mainnet deployments.

### 6. Events

- Emit events for critical actions (proposal, vote, redeem).
- Validate event emission in key happy paths.

## Deprecated

Maintained only for historical/experimental purposes:

- src/deprecated/MerkleClaim.sol
- script/deprecated/DeployMerkleClaim.s.sol

These are intentionally separated from the active governance flow.

## Documentation

- Foundry Book: https://book.getfoundry.sh/
- OpenZeppelin Contracts: https://docs.openzeppelin.com/contracts
