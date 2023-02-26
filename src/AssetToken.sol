// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AssetToken is ERC20 {
    constructor() ERC20("Asset Token", "AST") {}

    function mintAsset(uint amount) external {
        _mint(msg.sender, amount);
    }

}
