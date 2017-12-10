pragma solidity ^0.4.13;

contract SafeMath{
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
    
    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
  }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
  }
    function assert(bool assertion) internal {
        if (!assertion) {
          revert();
        }
    }
}

contract COOMS is SafeMath {
    
    event Transfer(address indexed _from, address indexed _recipient, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Log(string _message, uint256 _value);
    
    string     public name;
    string     public symbol;
    uint     public decimals = 2;
    uint256 public INITIAL_SUPPLY;
    uint256 public price;
    address public owner;
    
    uint256 public totalSupply;
    
    address TAX_FEE_BIG_ADDRESS = 0xc587D94787035B32c6c481e2C5211288f3F45F8c;
    
    // in M percentage: 1000000 = 1%, so below equals to 0.25%
    uint256 TAX_FEE_BIG_AMOUNT = 250000;
    
    // equals to 0.083333%
    uint256 TAX_FEE_SMALL_AMOUNT = 83333;
    
    address TAX_FEE_SMALL_ADDRESS_ONE = 0x44f994297dE6A9F2d9eE7f7befF94802531DF3c2;
    address TAX_FEE_SMALL_ADDRESS_TWO = 0xd1D6f0C93Eb7C2C4a4b8A38b7cD1Da9c81875306;
    address TAX_FEE_SMALL_ADDRESS_THREE = 0xE390fA8e1b30258FEb0A01e9C32e9C56eBF7e786;
    
    mapping(address => uint256) balances;

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns (bool success){
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    mapping (address => mapping (address => uint256)) allowed;

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
        var _allowance = allowed[_from][msg.sender];
        
        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(_allowance, _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function () payable {
        createTokens(msg.sender);
    }

    function createTokens(address recipient) payable {
        if (msg.value == 0) {
          revert();
        }

        uint tokens = safeDiv(safeMul(msg.value, price), 1 ether);
        Log("total amount of tokens to send back", tokens);
        totalSupply = safeSub(totalSupply, tokens);
        
        // check if there is enough tokens in the vault
        if (totalSupply < 0) revert();
        
        // // credit big fee
        // uint MILLION = 100000000; // million is 1 percent, then make it 100%
        // uint tokensBigOne = tokens * TAX_FEE_BIG_AMOUNT / MILLION;
        // Log("amount of tokens to send as a big fee", tokensBigOne);
        
        // balances[TAX_FEE_BIG_ADDRESS] = safeAdd(balances[TAX_FEE_BIG_ADDRESS], tokensBigOne);
        
        // // credit three small fees
        // uint tokensSmallOne = tokens * TAX_FEE_SMALL_AMOUNT / MILLION;
        // Log("amount of tokens to send as a smaller fee (used for 3)", tokensSmallOne);
        
        // // one
        // balances[TAX_FEE_SMALL_ADDRESS_ONE] = safeAdd(balances[TAX_FEE_SMALL_ADDRESS_ONE], tokensSmallOne);
        // Transfer(owner, TAX_FEE_SMALL_ADDRESS_ONE, tokensSmallOne);
        // // two
        // balances[TAX_FEE_SMALL_ADDRESS_TWO] = safeAdd(balances[TAX_FEE_SMALL_ADDRESS_TWO], tokensSmallOne);
        // Transfer(owner, TAX_FEE_SMALL_ADDRESS_TWO, tokensSmallOne);
        // // three
        // balances[TAX_FEE_SMALL_ADDRESS_THREE] = safeAdd(balances[TAX_FEE_SMALL_ADDRESS_THREE], tokensSmallOne);
        // Transfer(owner, TAX_FEE_SMALL_ADDRESS_THREE, tokensSmallOne);
        
        // // return to buyer amount of tokens minus BIG fee and 3 SMALL fees
        // uint tokensReturnToBuyer = safeSub(tokens, tokensBigOne);
        // tokensReturnToBuyer = safeSub(tokensReturnToBuyer, safeMul(tokensBigOne, 3));
        
        // credit buyer
        balances[recipient] = safeAdd(balances[recipient], tokens);
        Log("amount of tokens sent to purchaser", tokens);
        
        // uint256 TAX_FEE_BIG_AMOUNT = 250000;
    
        // equals to 0.083333%
        // uint256 TAX_FEE_SMALL_AMOUNT = 83333;
    
        Log("amount of wei received", msg.value);
        
        uint tax1 = msg.value * TAX_FEE_BIG_AMOUNT / 100000000;
        Log("amount of wei for tax1", tax1);
        if (!TAX_FEE_BIG_ADDRESS.send(tax1)) revert();
        
        uint tax2 = msg.value * TAX_FEE_SMALL_AMOUNT / 100000000;
        Log("amount of wei for tax1", tax2);
        if (!TAX_FEE_SMALL_ADDRESS_ONE.send(tax2)) revert();
        
        uint tax3 = msg.value * TAX_FEE_SMALL_AMOUNT / 100000000;
        Log("amount of wei for tax1", tax3);
        if (!TAX_FEE_SMALL_ADDRESS_TWO.send(tax3)) revert();
        
        uint tax4 = msg.value * TAX_FEE_SMALL_AMOUNT / 100000000;
        Log("amount of wei for tax1", tax4);
        if (!TAX_FEE_SMALL_ADDRESS_THREE.send(tax4)) revert();
        
        uint remaining = msg.value - tax1 - tax2 - tax3 - tax4;
        Log("amount of wei for owner", remaining);
        
        // send pasta to the owner
        if (!owner.send(remaining)) revert();
        
        // owner still gets deducted total amount of tokens
        balances[owner] = safeSub(balances[owner], tokens);
        Transfer(owner, msg.sender, tokens);
    
    }

    function COOMS(string _name, string _symbol, uint _supply, uint _price) {
        totalSupply = _supply;
        INITIAL_SUPPLY = _supply;
        balances[msg.sender] = _supply;
        owner     = msg.sender;
        price     = _price;
        name = _name;
        symbol = _symbol;
    }
}



