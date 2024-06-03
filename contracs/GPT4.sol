// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/galadriel-ai/contracts/blob/main/contracts/contracts/interfaces/IOracle.sol";

contract OpenAI {
    address private oracleAddress = 0x4168668812C94a3167FCd41D12014c5498D74d7e;
    IOracle.OpenAiRequest private config;
    mapping (uint => string) public prompts;
    mapping (address => string) public responses;

    // https://docs.galadriel.com/tutorials/multimodal
    constructor() {
        config = IOracle.OpenAiRequest({
            model : "gpt-4-turbo", // gpt-4-turbo gpt-4o
            frequencyPenalty : 21, // > 20 for null
            logitBias : "", // empty str for null
            maxTokens : 1000, // 0 for null
            presencePenalty : 21, // > 20 for null
            responseFormat : "{\"type\":\"text\"}",
            seed : 0, // null
            stop : "", // null
            temperature : 10, // Example temperature (scaled up, 10 means 1.0), > 20 means null
            topP : 101, // Percentage 0-100, > 100 means null
            tools : "",
            toolChoice : "", // "none" or "auto"
            user : "" // null
        });
    }

    function promptGPT(string memory _message) public {
        uint256 runId = uint256(uint160(msg.sender));
        IOracle.Message memory newMessage = IOracle.Message({
            role: "user",
            content: new IOracle.Content[](1)
        });
        newMessage.content[0] = IOracle.Content({
            contentType: "text",
            value: _message
        });
        prompts[runId] = _message;
        IOracle(oracleAddress).createOpenAiLlmCall(runId, config);
    }

     function onOracleOpenAiLlmResponse(
        uint _runId,
        IOracle.OpenAiResponse memory _response,
        string memory _errorMessage
    ) public {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        address toAddress = address(uint160(uint256(_runId)));
        if (keccak256(abi.encodePacked(_errorMessage)) != keccak256(abi.encodePacked(""))) {
            responses[toAddress] = _errorMessage;
        } else {
            responses[toAddress] = _response.content;
        }
    }

    // required for Oracle
    function getMessageHistory(uint _runId) public view returns (IOracle.Message[] memory) {
        IOracle.Message memory newMessage = IOracle.Message({
            role: "user",
            content: new IOracle.Content[](1)
        });
        newMessage.content[0] = IOracle.Content({
            contentType: "text",
            value: prompts[_runId]
        });
        IOracle.Message[] memory newMessages = new IOracle.Message[](1);
        newMessages[0] = newMessage;
        return newMessages;
    }

    
}
