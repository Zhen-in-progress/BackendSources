// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
// 任务：参考 openzeppelin-contracts/contracts/token/ERC20/IERC20.sol实现一个简单的 ERC20 代币合约。要求：
// 合约包含以下标准 ERC20 功能：
// balanceOf：查询账户余额。
// transfer：转账。
// approve 和 transferFrom：授权和代扣转账。
// 使用 event 记录转账和授权操作。
// 提供 mint 函数，允许合约所有者增发代币。
// 提示：
// 使用 mapping 存储账户余额和授权信息。
// 使用 event 定义 Transfer 和 Approval 事件。
// 部署到sepolia 测试网，导入到自己的钱包
contract MyECR20Token {
    string public name; // Token name, e.g., "MyToken"
    string public symbol; // Token ticker, e.g., "MTK" (like BTC, ETH)
    uint8 public decimals; // Decimal places, usually 18 (like Ether: 1.000000000000000000)
    uint256 private _totalSupply; // Total number of tokens that exist
    address public owner; // The address that deployed the contract

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowance;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        owner = msg.sender;

        _totalSupply = initialSupply * 10 ** decimals;
        _balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender,_totalSupply);
        emit Mint(msg.sender,_totalSupply);
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balance[account];
    }
    function totalSupply() external view returns (uint256) {
      return _totalSupply;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
      return _allowance[_owner][_spender];
    }
    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(_balance[msg.sender] >= _value, "Insufficient balance");

        _balance[msg.sender] -= _value;
        _balance[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0), "Cannot approve zero address");
        _allowance[msg.sender][_spender] = _value; // msg.sender's token, approve spender to use
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        require(_from != address(0), "Cannot transfer from zero address");
        require(_to != address(0), "Cannot transfer to zero address");
        require(_balance[_from] >= _value, "Insufficient balance");
        require(
            _allowance[_from][msg.sender] >= _value,
            "insufficient allowance"
        );

        _balance[_from] -= _value;
        _balance[_to] += _value;
        _allowance[_from][msg.sender] -= _value; //_from's token, msg.sender here is the spender
        emit Transfer(_from, _to, _value);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Mint(address indexed to, uint value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Mint new tokens (only owner can call)
     * @param _to Address to receive minted tokens
     * @param _value Amount to mint
     * @return success True if mint successful
     */
    function mint(
        address _to,
        uint256 _value
    ) public onlyOwner returns (bool success) {
        require(_to != address(0), "Cannot mint to zero address");

        _totalSupply += _value;
        _balance[_to] += _value;
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }
}
