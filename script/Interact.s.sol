//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from  "forge-std/Script.sol";
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdrop__InvalidSignature();

    uint256 CLAIMING_AMOUNT = 25 * 1e18;

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;


    bytes32 PROOF_ONE = 0x72995a443d90c829031cb42be582996fb8747dc02130f358dba0ad65c8db5119;
    bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE = hex"8c0a6e0996608368886a3c69250697fbb572a965c9108d72e4a2cd4fbcf97a4037b8fb6f99f2fc57b4b7e3ded801d88c67df218d074b8fd009ef245bfdc01b561b";

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) { revert ClaimAirdrop__InvalidSignature(); }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external { 
        address mostRecent = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecent);
    }
}