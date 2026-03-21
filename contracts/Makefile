RPC_URL := http://127.0.0.1:8545
DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy:
	@echo "Deploying GovernanceNFT..."
	@forge script script/DeployGovernanceNFT.s.sol $(NETWORK_ARGS)
	@echo "Contract deployed"

setup-anvil:
	@echo "Setting up Anvil with pre-funded accounts..."
	@forge script script/SetupAnvil.s.sol --rpc-url http://127.0.0.1:8545 --private-key ${DEFAULT_ANVIL_KEY} --via-ir --broadcast -vvv

deploy-proxy:
	@echo "Deploying GovernanceNFT..."
	@forge create src/GovernanceNFTFactory.sol:GovernanceNFTFactory --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80  --constructor-args 0x5FbDB2315678afecb367f032d93F642f64180aa3

createGovernanceNFT:
	@echo "Creating GovernanceNFT..."
	@cast send 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853 "createGovernanceNFT(uint256)(address)" 1 --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

getAllNFTs:
	@echo "Getting all NFTs..."
	@cast call 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853 "getAllNFTs()(address[])" --rpc-url http://127.0.0.1:8545

getTokenCounter:
	@echo "Getting token counter..."
	@cast call 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 "getTokenCounter()(uint256)" --rpc-url http://127.0.0.1:8545

mint:
	@echo "Minting GovernanceNFT..."
	@cast send 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 "safeMint(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
	@echo "GovernanceNFT minted"

deploy-all:
	@echo "Deploying GovernanceNFT..."
	@forge script script/DeployGovernanceNFT.s.sol $(NETWORK_ARGS)
	@echo "Contract deployed"
	@forge script script/DeployGovernanceDAO.s.sol $(NETWORK_ARGS)
	@echo "Contract deployed"

create-proposal:
	@echo "Creating proposal..."
	@forge script script/CreateProposal.s.sol $(NETWORK_ARGS)
	@echo "Proposal created"

mint-governance-nft:
	@echo "Minting GovernanceNFT..."
	@forge script script/MintGovernanceNFT.s.sol $(NETWORK_ARGS)
	@echo "GovernanceNFT minted"

PROPOSAL_ID ?= 0
TOKEN_ID ?= 0
SUPPORT ?= true

vote:
	@echo "Voting on proposal..."
	@forge script script/Vote.s.sol --sig "run(uint256,uint256,bool)" $(PROPOSAL_ID) $(TOKEN_ID) $(SUPPORT) $(NETWORK_ARGS)
	@echo "Voted on proposal"

result:
	@echo "Getting proposal result..."
	@forge script script/GetProposalResult.s.sol --sig "run(uint256)" $(PROPOSAL_ID) $(NETWORK_ARGS)
	@echo "Got proposal result"