RPC_URL := http://127.0.0.1:8545
DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy:
	@echo "Deploying GovernanceNFT..."
	@forge script script/DeployGovernanceNFT.s.sol $(NETWORK_ARGS)
	@echo "Contract deployed"

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