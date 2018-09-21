pragma solidity ^0.4.18;

//Code by @mattdf (modernized slightly by @-------)

contract Channel {

    address public channelSender;
    address public channelRecipient;
    uint public startDate;
    uint public channelTimeout;

    mapping (bytes32 => address) public signatures;

    function Channel(address to, uint timeout) public payable {
        channelRecipient = to;
        channelSender = msg.sender;
        startDate = now;
        channelTimeout = timeout;
    }

    function closeChannel(bytes32 h, uint8 v, bytes32 r, bytes32 s, uint value) public {
        address signer;
        bytes32 proof;
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, h);
        signer = ecrecover(prefixedHash, v, r, s);
        if (signer != channelSender && signer != channelRecipient) revert();

        proof = keccak256(this, value);
        require(proof == h);

        if (signatures[proof] == 0)
            signatures[proof] = signer;
        else if (signatures[proof] != signer) {
            if (!channelRecipient.send(value)) revert();
            selfdestruct(channelSender);
        }

    }

    function channelTimeout() public {
        require(startDate + channelTimeout <= now);
        selfdestruct(channelSender);
    }

}
