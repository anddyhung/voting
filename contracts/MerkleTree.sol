//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        uint index
    ) public pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            // if the computed hash is equal to the element in the proof,
            // this is the right element.
            if (i % 2 == 0) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
            index = index / 2;
        }

        return (computedHash == root);
    }
}

contract TestMerkleProof is MerkleProof {
    bytes32[] hashes;

    constructor() {
        string[4] memory transactions = [
            "alice=>boby",
            "boby=>budin",
            "budin=>terry",
            "terry=>alice"
        ];
        uint length = transactions.length;
        for (uint i = 0; i < length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }
        uint offset = 0;
        while (length > 0) {
            for (uint i = 0; i < length - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(
                            hashes[offset + i],
                            hashes[offset + i + 1]
                        )
                    )
                );
            }
            offset += length;
            length = length / 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }
}
