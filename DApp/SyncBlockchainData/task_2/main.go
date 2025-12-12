package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log"
	"math/big"
	"os"
	"time"

	"task_2/counter"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
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
	fmt.Println("✓ Connected to Sepolia testnet")

	// Get private key from environment variable
	privateKeyHex := os.Getenv("PRIVATE_KEY")
	if privateKeyHex == "" {
		log.Fatal("PRIVATE_KEY is not set in .env file")
	}

	privateKey, err := crypto.HexToECDSA(privateKeyHex)
	if err != nil {
		log.Fatal(err)
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("cannot assert type: publicKey is not of type *ecdsa.PublicKey")
	}

	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	fmt.Printf("✓ Using account: %s\n", fromAddress.Hex())

	nonce, err := client.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}

	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	chainId, err := client.NetworkID(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("✓ Chain ID: %s\n\n", chainId.String())

	// Step 1: Deploy Counter contract
	fmt.Println("=== Deploying Contract ===")
	auth, err := bind.NewKeyedTransactorWithChainID(privateKey, chainId)
	if err != nil {
		log.Fatal(err)
	}
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(0)     // in wei
	auth.GasLimit = uint64(300000) // in units
	auth.GasPrice = gasPrice

	address, tx, instance, err := counter.DeployCounter(auth, client)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("✓ Contract deployed at address: %s\n", address.Hex())
	fmt.Printf("✓ Deployment transaction hash: %s\n", tx.Hash().Hex())
	fmt.Println("Waiting for deployment to be mined...")

	// Wait for deployment transaction to be mined
	deployReceipt, err := waitForReceipt(client, tx.Hash())
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("✓ Deployment confirmed in block %d\n\n", deployReceipt.BlockNumber.Uint64())

	// Step 2: Query initial counter value
	fmt.Println("=== Querying Initial Counter Value ===")
	callOpts := &bind.CallOpts{Context: context.Background()}
	initialValue, err := instance.Get(callOpts)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("✓ Initial counter value: %s\n\n", initialValue.String())

	// Step 3: Call addOne() to increment counter
	fmt.Println("=== Calling addOne() Method to Increment Counter ===")

	// Get new nonce for the next transaction
	nonce, err = client.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}

	// Update auth for the addOne transaction
	auth.Nonce = big.NewInt(int64(nonce))
	auth.GasLimit = uint64(100000)

	addOneTx, err := instance.AddOne(auth)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("✓ Transaction sent: %s\n", addOneTx.Hash().Hex())
	fmt.Println("Waiting for transaction to be mined...")

	// Wait for addOne transaction to be mined
	addOneReceipt, err := waitForReceipt(client, addOneTx.Hash())
	if err != nil {
		log.Fatal(err)
	}

	if addOneReceipt.Status == 1 {
		fmt.Printf("✓ Transaction confirmed in block %d\n\n", addOneReceipt.BlockNumber.Uint64())
	} else {
		log.Fatal("Transaction failed!")
	}

	// Step 4: Query updated counter value
	fmt.Println("=== Querying Updated Counter Value ===")
	newValue, err := instance.Get(callOpts)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("✓ New counter value: %s\n", newValue.String())

	// Step 5: Display results
	fmt.Println("\n=== Results Summary ===")
	fmt.Printf("Contract Address: %s\n", address.Hex())
	fmt.Printf("Initial Value: %s\n", initialValue.String())
	fmt.Printf("Value After addOne(): %s\n", newValue.String())

	expectedValue := new(big.Int).Add(initialValue, big.NewInt(1))
	if newValue.Cmp(expectedValue) == 0 {
		fmt.Println("✓ Counter incremented successfully!")
	} else {
		fmt.Printf("✗ Unexpected value. Expected: %s, Got: %s\n", expectedValue.String(), newValue.String())
	}

	fmt.Printf("\nView transaction on Etherscan: https://sepolia.etherscan.io/tx/%s\n", addOneTx.Hash().Hex())
	fmt.Printf("View contract on Etherscan: https://sepolia.etherscan.io/address/%s\n", address.Hex())
}

// waitForReceipt waits for a transaction to be mined and returns the receipt
func waitForReceipt(client *ethclient.Client, txHash common.Hash) (*types.Receipt, error) {
	for {
		receipt, err := client.TransactionReceipt(context.Background(), txHash)
		if err == nil {
			return receipt, nil
		}
		if err != ethereum.NotFound {
			return nil, err
		}
		// Wait before querying again
		time.Sleep(2 * time.Second)
		fmt.Print(".")
	}
}
