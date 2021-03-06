// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/// @title The ERC20 Token
/// @author Barinov N.N.
/// @notice You can use this contract for studing
/// @dev All function calls are currently implemented without side effects
contract Token{
  address public owner;
  string public name;
  string public symbol;
  uint256 private totalSupply_;
  uint8 public decimals;
  
  mapping(address => uint256) private balances;
  mapping(address => mapping(address => uint256)) private allowed;

  constructor() public {
      owner = msg.sender;
      name = "Sezam";
      symbol = "SZM";
      decimals = 18;
      totalSupply_ = 1000;
      balances[owner] = totalSupply_;
  }

  modifier notZeroAddr(address testAddr){
      require(testAddr != address(0),"Address is zero address");
    _;
  }

  modifier costs(address addrOf,uint256 value){
    require(balances[addrOf] >= value,"Insufficient funds");
    _;
  }

  modifier haveAllow(address from,uint256 value){
    require(value <= allowed[from][msg.sender],"Insufficient Confirmed Funds"); 
    _;
  }

  modifier onlyOwner(){
    require(owner == msg.sender,"Ownable: caller is not owner"); 
    _;
  }

  /// @notice Transfer ownership from owner to choisen address
  /// @param newOwner The address of new owner of contract 
  /// @return answer that operation was successfully completed 
  function transferOwnership(address newOwner) 
  external 
  onlyOwner 
  notZeroAddr(newOwner) 
  returns(bool answer) 
  {
    address oldOwner = owner;
    owner = newOwner;
    
    emit OwnershipTransferred(oldOwner,newOwner);  
    return true;
  }

  /// @notice Transfer selected quantity of tokens
  /// @notice  from msg.sender to selected address
  /// @dev Return an array of one number type bool 
  /// @param _to The address where we sending the token 
  /// @param _value The amount of sending tokens 
  /// @return answer that operation was successfully completed 
  function transfer(
    address _to,
    uint256 _value
  ) 
  public
  costs(msg.sender,_value)
  notZeroAddr(_to)
  returns (bool answer)
  {
    address _from = msg.sender;
    changeBalance(_from, _to, _value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /// @notice Transfer selected quantity of tokens between two addresses  
  /// @dev Return an array of one number type bool
  /// @dev msg.sender can transfer only allowed quantity of tokens 
  /// @param _from The address from where we move tokens  
  /// @param _to The address there do we move tokens 
  /// @param _value The amount of sending tokens 
  /// @return answer that operation was successfully completed 
  function transferFrom(
    address _from,
    address _to,
    uint _value
  ) 
    public
    notZeroAddr(_from)
    notZeroAddr(_to)
    costs(_from,_value)
    haveAllow(_from,_value)
    returns (bool answer)
  {
      allowed[_from][msg.sender] -= _value;
      changeBalance(_from, _to, _value);
      
      emit Transfer(_from, _to, _value);
    
      return true;
  }

  /// @notice changes balances on two accounts to value 
  /// @param _from The address of giving account 
  /// @param _to The address of receiving account  
  /// @param _value Transfered amount  
  function changeBalance(address _from, address _to, uint256 _value) private{
    balances[_from] = balances[_from] - _value;
    balances[_to] = balances[_to] + _value;
  }

  /// @notice Approval selected quantity of tokens for address  
  /// @param _spender The address for approval
  /// @param _value The amount of approval tokens 
  /// @return answer that operation was successfully completed 
  function approve(
    address _spender,
    uint256 _value
  ) 
    public 
    returns (bool answer)
  {
      allowed[msg.sender][_spender] += _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
  }

  /// @notice Have mint choisen quantity of tokens  
  /// @param _target Address of tokens owner 
  /// @param _mintedAmount The address of tokens spender
  function mint(
    address _target,
    uint256 _mintedAmount
  ) 
  external 
  onlyOwner
  notZeroAddr(_target)
  {
    balances[_target] += _mintedAmount;
    totalSupply_ += _mintedAmount;
    emit Transfer(address(0), _target, _mintedAmount);
  }

  /// @notice Have burn choisen quantity of tokens  
  /// @param _target Address of tokens owner 
  /// @param _burnedAmount The address of tokens spender
  function burn(
    address _target,
    uint256 _burnedAmount
  ) 
  external 
  costs(
    _target,
    _burnedAmount
  ) 
  onlyOwner
  notZeroAddr(_target)
  {
    balances[_target] -= _burnedAmount;
    totalSupply_ -= _burnedAmount;
    emit Transfer(_target, address(0), _burnedAmount);
  }

  /// @notice Return quantity of approval tokens  
  /// @param _owner Address of tokens owner 
  /// @param _spender The address of tokens spender
  /// @return allow type uint256
  function allowance (
    address _owner,
    address _spender
  ) 
    external
    view 
    returns(uint256 allow)
  {
    return allowed[_owner][_spender];
  }

  /// @notice Return total supply of tokens  
  /// @return totSupply type uint256
  function totalSupply() external view returns (uint256 totSupply ){
      return totalSupply_;
  }

  /// @notice Return balance of address   
  /// @return balance type uint256
  function balanceOf(address _owner) external view returns(uint256 balance){
      return balances[_owner];
  }

  /// An event for tracking a approval of tokens.
  event Approval(address indexed tokenOwner, address indexed spender,
    uint tokens);

  /// An event for tracking a transfer of tokens.
  event Transfer(address indexed _from, address indexed _to,
    uint256 _value);

  /// An event for tracking owner of contract.
  event OwnershipTransferred(address indexed previosOwner, address indexed newOwner);
}