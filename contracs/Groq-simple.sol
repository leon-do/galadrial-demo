// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/galadriel-ai/contracts/blob/main/contracts/contracts/interfaces/IOracle.sol";

contract Groq {
    address private oracleAddress = 0x4168668812C94a3167FCd41D12014c5498D74d7e;
    IOracle.GroqRequest private config;
    uint runId = 0;
    string public message;
    string public response;

    // https://docs.galadriel.com/tutorials/multimodal
    constructor() {
        config = IOracle.GroqRequest({
            model : "mixtral-8x7b-32768", // llama3-8b-8192, llama3-70b-8192, mixtral-8x7b-32768, or gemma-7b-it
            frequencyPenalty : 21, // > 20 for null
            logitBias : "", // empty str for null
            maxTokens : 1000, // 0 for null
            presencePenalty : 21, // > 20 for null
            responseFormat : "{\"type\":\"text\"}",
            seed : 0, // null
            stop : "", // null
            temperature : 10, // Example temperature (scaled up, 10 means 1.0), > 20 means null
            topP : 101, // Percentage 0-100, > 100 means null
            user : "" // null
        });
    }

    function prompt(string memory _message) public {
        message = _message;
        IOracle(oracleAddress).createGroqLlmCall(runId, config);
    }

    // required for oracle
    function onOracleGroqLlmResponse(
        uint _runId,
        IOracle.GroqResponse memory _response,
        string memory _errorMessage
    ) public {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        if (keccak256(abi.encodePacked(_errorMessage)) != keccak256(abi.encodePacked(""))) {
            response = _errorMessage;
        } else {
            response = _response.content;
        }
    }

    // required for oracle
    function getMessageHistoryRoles(uint _runId) public pure returns (string[] memory) {
        string[] memory roles = new string[](1);
        roles[0] = "user";
        return roles;
    }

    // required for oracle
    function getMessageHistoryContents(uint _runId) public view returns (string[] memory) {
       string[] memory messages = new string[](1);
        messages[0] = message;
        return messages;
    }
}
