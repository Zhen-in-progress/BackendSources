package main

import (
	"encoding/hex"
	"fmt"
	"log"

	"github.com/ethereum/go-ethereum/crypto"
)

func GenerateTestKey() {
	// Generate a new private key
	privateKey, err := crypto.GenerateKey()
	if err != nil {
		log.Fatal(err)
	}

	// Convert to hex format (without 0x prefix)
	privateKeyBytes := crypto.FromECDSA(privateKey)
	privateKeyHex := hex.EncodeToString(privateKeyBytes)

	// Get the public address
	address := crypto.PubkeyToAddress(privateKey.PublicKey)

	fmt.Println("=== New Test Wallet Generated ===")
	fmt.Println("Private Key:", privateKeyHex)
	fmt.Println("Address:", address.Hex())
	fmt.Println("\n⚠️  IMPORTANT: This is for TESTING ONLY!")
	fmt.Println("⚠️  Never use this wallet for real funds!")
	fmt.Println("\nCopy the private key to your .env file:")
	fmt.Println("PRIVATE_KEY=" + privateKeyHex)
}
