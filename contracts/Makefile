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
	@cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "createGovernanceNFT(uint256)(address)" 1 --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

getNFTByProposal:
	@echo "Getting NFT by proposal ID..."
	@cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getNFTByProposal(uint256)(address)" 1 --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

getAllNFTs:
	@echo "Getting all NFTs..."
	@cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getAllNFTs()(address[])" --rpc-url http://127.0.0.1:8545

getTokenCounter:
	@echo "Getting token counter..."
	@cast call 0xCafac3dD18aC6c6e92c921884f9E4176737C052c "getTokenCounter()(uint256)" --rpc-url http://127.0.0.1:8545

getNftName:
	@echo "Getting token name..."
	@cast call 0xCafac3dD18aC6c6e92c921884f9E4176737C052c "getNftName()(uint256)" --rpc-url http://127.0.0.1:8545

getNftSymbol:
	@echo "Getting token symbol..."
	@cast call 0xCafac3dD18aC6c6e92c921884f9E4176737C052c "getNftSymbol()(uint256)" --rpc-url http://127.0.0.1:8545

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

PROPOSAL_ID ?= 1
TOKEN_ID ?= 0
SUPPORT ?= true

voteFor:
	@echo "Voting on proposal..."
	@forge script script/Vote.s.sol --sig "voteFor(uint256,uint256)" $(PROPOSAL_ID) $(TOKEN_ID) $(NETWORK_ARGS)
	@echo "Voted on proposal"

voteAgainst:
	@echo "Voting on proposal..."
	@forge script script/Vote.s.sol --sig "voteAgainst(uint256,uint256)" $(PROPOSAL_ID) $(TOKEN_ID) $(NETWORK_ARGS)
	@echo "Voted on proposal"

DAO_ADDRESS ?= 0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE

result:
	@echo "Getting proposal result for proposal $(PROPOSAL_ID) from DAO $(DAO_ADDRESS)..."
	@cast call $(DAO_ADDRESS) "getProposal(uint256)(string,uint256,uint256,uint256,uint256,bool)" $(PROPOSAL_ID) --rpc-url $(RPC_URL)