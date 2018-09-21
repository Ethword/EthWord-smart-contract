pragma solidity ^0.4.18;

contract Channel {

    address public channelSender;
    address public channelRecipient;
    uint public startDate;
    uint public channelTimeout;
    uint public channelMargin;
    bytes32 public channelTip;

    function Channel(address to, uint timeout, uint margin, bytes32 tip) public payable {
        channelRecipient = to;
        channelSender = msg.sender;
        startDate = now;
        channelTimeout = timeout;
        channelMargin = margin;
        channelTip = tip;
    }

    function closeChannel(bytes32 _word, uint8 _wordCount) public {

        require(msg.sender == channelRecipient);
        bytes32 wordScratch = _word;
        for (uint i = 1; i <= _wordCount; i++) {
            wordScratch = keccak256(wordScratch);
        }

        require(wordScratch == channelTip);
        require(channelRecipient.send(_wordCount * channelMargin));
        selfdestruct(channelSender);
    }

    function channelTimeout() public {
        require(now >= startDate + channelTimeout);
        selfdestruct(channelSender);
    }

}
