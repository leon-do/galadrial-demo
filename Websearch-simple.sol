// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/galadriel-ai/contracts/blob/main/contracts/contracts/interfaces/IOracle.sol";

contract Websearch {
    address private oracleAddress = 0x4168668812C94a3167FCd41D12014c5498D74d7e;
    string public response;
    string public message;

    constructor() {}

    function prompt(string memory _message) public returns (uint256) {
        uint256 runId =  uint256(uint160(msg.sender));
        message = _message;
        IOracle(oracleAddress).createFunctionCall(
            runId,
            "web_search",
            _message
        );
        return runId;
    }

   // required for oracle
    function onOracleFunctionResponse(
        uint _runId,
        string memory _response,
        string memory _errorMessage
    ) public {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        if (keccak256(abi.encodePacked(_errorMessage)) != keccak256(abi.encodePacked(""))) {
            response = _errorMessage;
        } else {
            response = _response;
        }
    }
}
