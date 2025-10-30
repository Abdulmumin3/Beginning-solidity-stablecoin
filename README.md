# 🪙 StablecoinSkeleton — Minimal Collateralized Stablecoin System

> A simplified and educational implementation of a **collateral-backed stablecoin protocol**, inspired by systems like DAI.  
> Built with Solidity, Chainlink price feeds, and OpenZeppelin security libraries.

---

## 🚀 Overview

**StablecoinSkeleton** is a foundational smart contract that allows users to:

-   Deposit supported tokens as **collateral** (e.g., ETH, WBTC, LINK).
-   **Mint a stablecoin (SBT)** against that collateral.
-   **Redeem** collateral by repaying (burning) minted tokens.
-   Maintain stability through a **health factor** system and **liquidation mechanism**.

This project serves as a learning and experimental template for building decentralized stablecoins, lending platforms, or collateral-backed assets.

---

## 🧠 Core Concept

Think of this as a **decentralized vault system**:

1. You deposit a token (collateral).
2. You mint SBT — a synthetic stablecoin pegged to USD.
3. The system checks your **health factor** to ensure your collateral value safely exceeds your debt.
4. If your collateral drops too much, other users can **liquidate** you for profit — keeping the system solvent.

---

## 🧩 Features

-   ✅ Collateralized stablecoin minting
-   🔒 Anti-reentrancy protection (via OpenZeppelin `ReentrancyGuard`)
-   🧾 Chainlink oracles for live USD price data
-   🧮 Dynamic health factor checks and liquidation threshold
-   ⚙️ Modular architecture — easy to extend for multi-token collateral
-   🪙 Transparent on-chain minting and redemption

---

## ⚙️ Tech Stack

| Component              | Description                                      |
| ---------------------- | ------------------------------------------------ |
| **Solidity (v0.8.28)** | Core smart contract language                     |
| **Foundry**            | Development, testing, and deployment             |
| **OpenZeppelin**       | Security utilities (`ReentrancyGuard`, `IERC20`) |
| **Chainlink**          | Price oracles for real-time asset valuation      |

---

## 🧱 Contract Architecture

```text
StablecoinSkeleton
├── Stablecoin.sol              # ERC20 stablecoin implementation (SBT)
├── StablecoinSkeleton.sol      # Core collateral + minting logic
└── External Libraries
    ├── OpenZeppelin (IERC20, ReentrancyGuard)
    └── Chainlink (AggregatorV3Interface)

```

# 💡 Example Flow

```
// 1️⃣ Deposit collateral
depositCollateral(WETH, 1 ether);

// 2️⃣ Mint 500 SBT (stablecoins)
mintSBT(500e18);

// 3️⃣ Check your account health
healthFactor(msg.sender);

// 4️⃣ Repay your loan
burnSBT(500e18);

// 5️⃣ Redeem collateral back
redeemCollateral(WETH, 1 ether);
```

# 🧰 Deployment (Foundry)

```shell
# Clone repo
git clone https://github.com/Abdulmumin3/StablecoinSkeleton.git
cd StablecoinSkeleton

# Build and test
forge build
forge test

# Deploy (example)
forge script script/DeployStablecoin.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
