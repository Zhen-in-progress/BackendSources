package main

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// Get API key from environment variable
	apiKey := os.Getenv("INFURA_API_KEY")
	if apiKey == "" {
		log.Fatal("INFURA_API_KEY is not set in .env file")
	}

	// Connect to Ethereum Sepolia via Infura
	client, err := ethclient.Dial("https://sepolia.infura.io/v3/" + apiKey)
	if err != nil {
		log.Fatal(err)
	}

	blockNumber := big.NewInt(5671744)

	header, err := client.HeaderByNumber(context.Background(), blockNumber)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(header.Number.Uint64())     // 5671744
	fmt.Println(header.Time)                // 1712798400
	fmt.Println(header.Difficulty.Uint64()) // 0
	fmt.Println(header.Hash().Hex())        // 0xae713dea1419ac72b928ebe6ba9915cd4fc1ef125a606f90f5e783c47cb1a4b5

	block, err := client.BlockByNumber(context.Background(), blockNumber)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(block.Number().Uint64())     // 5671744
	fmt.Println(block.Time())                // 1712798400
	fmt.Println(block.Difficulty().Uint64()) // 0
	fmt.Println(block.Hash().Hex())          // 0xae713dea1419ac72b928ebe6ba9915cd4fc1ef125a606f90f5e783c47cb1a4b5
	fmt.Println(len(block.Transactions()))   // 70
	count, err := client.TransactionCount(context.Background(), block.Hash())

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(count) // 70

	// Get chain ID for transaction signing
	chainID, err := client.ChainID(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	// Query transactions from the block
	fmt.Println("\n--- Transaction Details ---")
	for _, tx := range block.Transactions() {
		fmt.Println("Hash:", tx.Hash().Hex())            // 0x20294a03e8766e9aeab58327fc4112756017c6c28f6f99c7722f4a29075601c5
		fmt.Println("Value:", tx.Value().String())       // 100000000000000000
		fmt.Println("Gas:", tx.Gas())                    // 21000
		fmt.Println("GasPrice:", tx.GasPrice().Uint64()) // 100000000000
		fmt.Println("Nonce:", tx.Nonce())                // 245132
		fmt.Println("Data:", tx.Data())                  // []
		fmt.Println("To:", tx.To().Hex())                // 0x8F9aFd209339088Ced7Bc0f57Fe08566ADda3587

		// Get sender address using latest signer (supports all tx types)
		if sender, err := types.Sender(types.LatestSignerForChainID(chainID), tx); err == nil {
			fmt.Println("Sender:", sender.Hex()) // 0x2CdA41645F2dBffB852a605E92B185501801FC28
		} else {
			log.Fatal(err)
		}

		// Get transaction receipt
		receipt, err := client.TransactionReceipt(context.Background(), tx.Hash())
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println("Receipt Status:", receipt.Status) // 1
		fmt.Println("Receipt Logs:", receipt.Logs)     // []
		// Only process first transaction
		break
	}

	// Query transaction by block hash and index
	fmt.Println("\n--- Transaction by Block Hash ---")
	blockHash := common.HexToHash("0xae713dea1419ac72b928ebe6ba9915cd4fc1ef125a606f90f5e783c47cb1a4b5")
	txCount, err := client.TransactionCount(context.Background(), blockHash)
	if err != nil {
		log.Fatal(err)
	}

	for idx := uint(0); idx < txCount; idx++ {
		tx, err := client.TransactionInBlock(context.Background(), blockHash, idx)
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println("Transaction Hash:", tx.Hash().Hex()) // 0x20294a03e8766e9aeab58327fc4112756017c6c28f6f99c7722f4a29075601c5
		// Only process first transaction
		break
	}

	// Query transaction by hash
	fmt.Println("\n--- Transaction by Hash ---")
	txHash := common.HexToHash("0x20294a03e8766e9aeab58327fc4112756017c6c28f6f99c7722f4a29075601c5")
	tx, isPending, err := client.TransactionByHash(context.Background(), txHash)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Is Pending:", isPending)             // false
	fmt.Println("Transaction Hash:", tx.Hash().Hex()) // 0x20294a03e8766e9aeab58327fc4112756017c6c28f6f99c7722f4a29075601c5
}
