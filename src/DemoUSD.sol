// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/*
 EDUCATIONAL TESTNET SAMPLE ONLY — NOT PRODUCTION-READY.
 Demonstrates role separation, pause, mint, burn and events.
 Not a complete stablecoin, reserve, redemption, compliance or custody system.
 Requires OpenZeppelin Contracts 5.x. Audit before any real deployment.
*/
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract DemoUSD is ERC20, AccessControl, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event IssuanceRecorded(address indexed recipient, uint256 amount, bytes32 indexed referenceId);

    event RedemptionRecorded(address indexed holder, uint256 amount, bytes32 indexed referenceId);

    constructor(address admin, address minter, address pauser) ERC20("Demo USD", "USDD") {
        require(admin != address(0) && minter != address(0) && pauser != address(0), "zero address");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(PAUSER_ROLE, pauser);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount, bytes32 referenceId) external onlyRole(MINTER_ROLE) whenNotPaused {
        require(to != address(0), "zero recipient");
        require(amount > 0, "zero amount");
        _mint(to, amount);
        emit IssuanceRecorded(to, amount, referenceId);
    }

    function redeemBurn(uint256 amount, bytes32 referenceId) external whenNotPaused {
        require(amount > 0, "zero amount");
        _burn(msg.sender, amount);
        emit RedemptionRecorded(msg.sender, amount, referenceId);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _update(address from, address to, uint256 value) internal override {
        require(!paused(), "token paused");
        super._update(from, to, value);
    }
}
