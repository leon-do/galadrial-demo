// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/galadriel-ai/contracts/blob/main/contracts/contracts/interfaces/IOracle.sol";

contract GPT4 {
    address private oracleAddress = 0x4168668812C94a3167FCd41D12014c5498D74d7e;
    mapping (address => string) public responses;
    mapping (uint => string) public prompts;

    constructor() {}

    // https://docs.galadriel.com/reference/llms/basic#createllmcall
    function prompt(string memory _message) public returns (uint256) {
        uint256 runId = uint256(uint160(msg.sender));
        prompts[runId] = _message;
        return IOracle(oracleAddress).createLlmCall(runId);
    }

    function onOracleLlmResponse(
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

    // https://docs.galadriel.com/reference/llms/message-history#getmessagehistoryroles
    function getMessageHistoryRoles(uint _runId) public pure returns (string[] memory) {
        string[] memory roles = new string[](1);
        roles[0] = "user"; // ["system", "user", "assistant"]
        return roles;
    }

    // https://docs.galadriel.com/reference/llms/message-history#getmessagehistorycontents
    function getMessageHistoryContents(uint _runId) public view returns (string[] memory) {
        string[] memory messages = new string[](1);
        messages[0] = prompts[_runId];
        return messages;
    }
}
