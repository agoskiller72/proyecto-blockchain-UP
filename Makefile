
-include .env


VALOR_NFT = 100000000000000000000            
MAX_VALUE = 1000000000000000000000000        
APPROVE_TOTAL = 10000000000000000000000000   
MAX_BATCH = 10                               
BUY_FEE = 100                                
TRADE_FEE = 200                              
PROFIT = 500                                 


RED = --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY)

.PHONY: build test deploy-busd deploy-ccnft verificar-busd verificar-ccnft seteos approve buy ver-estado poner-en-venta


build:
	forge build

test:
	forge test -vv

deploy-busd:
	forge script script/DeployBUSD.s.sol:DeployBUSD $(RED) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --gas-estimate-multiplier 200

deploy-ccnft:
	forge script script/DeployCCNFT.s.sol:DeployCCNFT $(RED) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --gas-estimate-multiplier 200


verificar-busd:
	forge verify-contract $(BUSD_ADDRESS) src/BUSD.sol:BUSD --chain sepolia --etherscan-api-key $(ETHERSCAN_API_KEY) --watch

verificar-ccnft:
	forge verify-contract $(CCNFT_ADDRESS) src/CCNFT.sol:CCNFT --chain sepolia --etherscan-api-key $(ETHERSCAN_API_KEY) --watch


seteos:
	cast send $(CCNFT_ADDRESS) "setFundsToken(address)" $(BUSD_ADDRESS) $(RED)
	cast send $(CCNFT_ADDRESS) "setFundsCollector(address)" $(FUNDS_COLLECTOR) $(RED)
	cast send $(CCNFT_ADDRESS) "setFeesCollector(address)" $(FEES_COLLECTOR) $(RED)
	cast send $(CCNFT_ADDRESS) "setCanBuy(bool)" true $(RED)
	cast send $(CCNFT_ADDRESS) "setCanTrade(bool)" true $(RED)
	cast send $(CCNFT_ADDRESS) "setCanClaim(bool)" true $(RED)
	cast send $(CCNFT_ADDRESS) "setMaxBatchCount(uint16)" $(MAX_BATCH) $(RED)
	cast send $(CCNFT_ADDRESS) "setMaxValueToRaise(uint256)" $(MAX_VALUE) $(RED)
	cast send $(CCNFT_ADDRESS) "addValidValues(uint256)" $(VALOR_NFT) $(RED)
	cast send $(CCNFT_ADDRESS) "setBuyFee(uint16)" $(BUY_FEE) $(RED)
	cast send $(CCNFT_ADDRESS) "setTradeFee(uint16)" $(TRADE_FEE) $(RED)
	cast send $(CCNFT_ADDRESS) "setProfitToPay(uint32)" $(PROFIT) $(RED)


approve:
	cast send $(BUSD_ADDRESS) "approve(address,uint256)" $(CCNFT_ADDRESS) $(APPROVE_TOTAL) $(RED)


buy:
	cast send $(CCNFT_ADDRESS) "buy(uint256,uint256)" $(VALOR_NFT) 1 $(RED)


poner-en-venta:
	cast send $(CCNFT_ADDRESS) "putOnSale(uint256,uint256)" 0 150000000000000000000 $(RED)


ver-estado:
	cast call $(CCNFT_ADDRESS) "canBuy()(bool)" --rpc-url $(SEPOLIA_RPC_URL)
	cast call $(CCNFT_ADDRESS) "fundsToken()(address)" --rpc-url $(SEPOLIA_RPC_URL)
	cast call $(CCNFT_ADDRESS) "fundsCollector()(address)" --rpc-url $(SEPOLIA_RPC_URL)
	cast call $(CCNFT_ADDRESS) "feesCollector()(address)" --rpc-url $(SEPOLIA_RPC_URL)
	cast call $(CCNFT_ADDRESS) "totalValue()(uint256)" --rpc-url $(SEPOLIA_RPC_URL)
	cast call $(CCNFT_ADDRESS) "totalSupply()(uint256)" --rpc-url $(SEPOLIA_RPC_URL)
