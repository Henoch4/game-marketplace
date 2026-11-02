# Loot Bazaar — Game Asset Marketplace

> Loot Bazaar is a fire-sale style marketplace for in-game items listed as tokens: fixed-price listings with escrow-style transfers, direct player-to-player settlement and a caption-generation-free trading feed.

## What it does

Loot Bazaar is a fire-sale style marketplace for in-game items listed as tokens: fixed-price listings with escrow-style transfers, direct player-to-player settlement and a caption-generation-free trading feed. The entire lifecycle lives in one contract, every button in the UI calls a real function on it — there is no mock backend.

## Contract

| | |
|---|---|
| File | `contracts/GameMarketplace.sol` |
| Contract name | `GameMarketplace` (inherits `ReentrancyGuard, Ownable`) |
| Solidity | `^0.8.20` |
| State functions | 5 (of which 1 payable) |
| Deployed (mainnet 677) | not yet deployed — placeholder `0x000…000` |

### Function surface

| Function | Type | Returns |
|---|---|---|
| `owner` | view | address |
| `listItem` | write | uint256 |
| `buyItem` | payable | tx receipt |
| `cancelListing` | write | result / revert |
| `getListing` | view | address seller, address nftContract, uint256 tokenId, uint256 price, bool active, bool sold |

### Events

| Event | Signature |
|---|---|
| `OwnershipTransferred` | (address indexed previousOwner, address indexed newOwner) |
| `ListingCreated` | (uint256 indexed lid, address indexed seller, address nftContract, uint256 tokenId, uint256 price) |
| `ListingBought` | (uint256 indexed lid, address indexed buyer, address indexed seller, uint256 price) |
| `ListingCancelled` | (uint256 indexed lid, address indexed seller) |

## Network

| | |
|---|---|
| Chain | BOT Chain Mainnet (chainId `677`) |
| RPC | `https://rpc.botchain.ai` |
| Explorer | `https://scan.botchain.ai` |
| Native currency | BOT (18 decimals) |
| Testnet | BOT Chain Testnet (chainId `968`) - `https://rpc.bohr.life` |

## Frontend

- **Wallet connection** - [Reown/AppKit](https://reown.com) (Web3Modal v2, inline modal, `subscribeAccount` / `subscribeNetwork`)
- **Web3 library** - ethers.js v6 (`BrowserProvider`, `Contract`, `parseEther`)
- **Animation** - GSAP 3 + ScrollTrigger (`expo.out` entrances, `prefers-reduced-motion` fallback renders content instantly)
- **Zero build step** - single `index.html`, CDN imports via ESM import map; no bundler, no framework runtime
- **Accessibility** - auto-generated `aria-label`s on all binary and form controls, focus-visible styles, button busy states

## Run it locally

```bash
git clone https://github.com/Henoch4/game-marketplace.git
cd game-marketplace
# open the frontend directly (no build step)
start frontend/index.html   # Windows
# or serve it if your browser blocks file:// modules:
npx serve frontend
```

> **Note** — contract addresses: the UI reads its deploy target from the `CA` constant at the top of the inline script. Until the contract is deployed to mainnet 677, the demo runs against the deterministic sample data built into the page; after deployment, set `CA['677']` to the real address and every button goes live.