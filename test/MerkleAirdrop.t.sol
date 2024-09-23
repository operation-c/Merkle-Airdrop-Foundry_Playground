//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { KrakenToken } from "../src/KrakenToken.sol"; 
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { DeployMerkleAirdrop } from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    KrakenToken public token;
    MerkleAirdrop public airdrop;

    address USER;
    address public gasPayer;

    uint256 userPrivKey;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;


    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32 public ROOT = 0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;
    bytes32[] public PROOF = [proofOne, proofTwo];

    function setUp() public {

        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.deployMerkleAirdrop();

        token = new KrakenToken();
        airdrop = new MerkleAirdrop(ROOT, token); 

        token.mint(token.owner(), AMOUNT_TO_SEND);
        token.transfer(address(airdrop), AMOUNT_TO_SEND);

        (USER, userPrivKey) = makeAddrAndKey("USER");
        gasPayer = makeAddr("gasPayer");
    }

    // checking to see someone else can claim the airdrop for us aka pay for gas fee's
    function testUsersCanClaim() public {
        // pre claim
        uint256 startingBalance = token.balanceOf(USER);
        bytes32 digest = airdrop.getMessage(USER, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        // gas payer calls claim usig the signed message
        vm.prank(gasPayer);
        airdrop.claim(USER, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        // post claim
        uint256 endingBalance = token.balanceOf(USER);
        console.log("Ending Balance: %d", endingBalance);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }   
}