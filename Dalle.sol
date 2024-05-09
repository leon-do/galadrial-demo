// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/galadriel-ai/contracts/blob/main/contracts/contracts/interfaces/IOracle.sol";

contract Dalle {
    address private oracleAddress = 0x4168668812C94a3167FCd41D12014c5498D74d7e;
    mapping (address => string) public responses;

    constructor() {}

    function promptDalle(string memory _message) public returns (uint256) {
        uint256 runId =  uint256(uint160(msg.sender));
        IOracle(oracleAddress).createFunctionCall(
            runId,
            "image_generation",
            _message
        );
        return runId;
    }

    function onOracleFunctionResponse(
        uint _runId,
        string memory _response,
        string memory _errorMessage
    ) public {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        address toAddress = address(uint160(uint256(_runId)));
        if (keccak256(abi.encodePacked(_errorMessage)) != keccak256(abi.encodePacked(""))) {
            responses[toAddress] = _errorMessage;
        } else {
            responses[toAddress] = _response;
        }
    }
}
