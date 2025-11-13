// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MyERC20Token
 * @dev Simple ERC20 token implementation with mint function
 */
contract MyERC20Token {
    // Token metadata
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Owner of the contract
    address public owner;

    // Balances for each account
    mapping(address => uint256) public balanceOf;

    // Allowances: owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);

    // Modifier to restrict functions to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Constructor - Initialize token with name, symbol, decimals and initial supply
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;

        // Mint initial supply to contract creator
        totalSupply = _initialSupply * (10 ** uint256(_decimals));
        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @dev Transfer tokens from sender to recipient
     * @param _to Recipient address
     * @param _value Amount to transfer
     * @return success True if transfer successful
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Approve spender to spend tokens on behalf of owner
     * @param _spender Address authorized to spend
     * @param _value Amount authorized to spend
     * @return success True if approval successful
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Cannot approve zero address");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another (requires approval)
     * @param _from Address to transfer from
     * @param _to Address to transfer to
     * @param _value Amount to transfer
     * @return success True if transfer successful
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Cannot transfer from zero address");
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Mint new tokens (only owner can call)
     * @param _to Address to receive minted tokens
     * @param _value Amount to mint
     * @return success True if mint successful
     */
    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        require(_to != address(0), "Cannot mint to zero address");

        totalSupply += _value;
        balanceOf[_to] += _value;

        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }
}
