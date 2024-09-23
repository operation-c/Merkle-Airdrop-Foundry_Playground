//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { KrakenToken } from "../src/KrakenToken.sol"; 
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;
    bytes32 private s_merkleRoot  = 0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, KrakenToken) {
        vm.startBroadcast();
        
        // create new contracts every run 
        KrakenToken token = new KrakenToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        
        // mint tokens 
        token.mint(token.owner(), s_amountToTransfer);
    
        // transfer minted tokens to airdrop contract
        token.transfer(address(airdrop), s_amountToTransfer);

        vm.stopBroadcast();

        return(airdrop, token);
    }
    
    function run() external returns (MerkleAirdrop, KrakenToken) {
        return deployMerkleAirdrop();
    }
}