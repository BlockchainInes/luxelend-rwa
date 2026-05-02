// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LuxeLendRWA is AccessControl, ReentrancyGuard {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    
    uint256 public constant LTV_RATIO = 60;
    string public constant name = "LuxeLend Real World Assets";
    
    mapping(uint256 => uint256) public propertyValuations;
    mapping(address => uint256) public borrowedAmount;

    event ValuationUpdated(uint256 indexed propertyId, uint256 newValue);
    event LoanExecuted(address indexed borrower, uint256 amount);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ORACLE_ROLE, msg.sender);
    }

    function updateValuation(uint256 _propertyId, uint256 _newValue) 
        external 
        onlyRole(ORACLE_ROLE) 
    {
        propertyValuations[_propertyId] = _newValue;
        emit ValuationUpdated(_propertyId, _newValue);
    }

    function borrowAgainstProperty(uint256 _propertyId) external nonReentrant {
        uint256 valuation = propertyValuations[_propertyId];
        require(valuation > 0, "No valuation available");
        
        uint256 maxLoan = (valuation * LTV_RATIO) / 100;
        require(borrowedAmount[msg.sender] == 0, "Existing loan detected");

        borrowedAmount[msg.sender] = maxLoan;
        emit LoanExecuted(msg.sender, maxLoan);
    }
}