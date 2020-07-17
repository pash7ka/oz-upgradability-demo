pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/roles/SignerRole.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

contract MultisigWallet is Initializable, SignerRole {
    event TokenTransferProposalCreated(uint256 proposalIndex, address token, address to, uint256 amount);
    event TokenTransferProposalSigned(uint256 proposalIndex, address signer);
    event TokenTransferProposalExecuted(uint256 proposalIndex);

    struct TokenTransferProposal {
        address token;
        address to;
        uint256 amount;
        mapping(address=>bool) signed;
        uint256 signatureCount;
        bool executed;
    }

    uint256 requiredSignatures; 
    TokenTransferProposal[] proposals;

    function initialize() public initializer {
        SignerRole.initialize(msg.sender);
        requiredSignatures = 2;
    }

    function createTokenTransferProposal(address _token, address _to, uint256 _amount) public onlySigner {
        proposals.push(TokenTransferProposal({
            token: _token,
            to: _to,
            amount: _amount,
            signatureCount: 0,
            executed: false
        }));
        emit TokenTransferProposalCreated(proposals.length-1, _token, _to, _amount);
    }
    
    function signTokenTransferProposal(uint256 proposalId) public onlySigner {
        require(proposalId < proposals.length, "Proposal not found");
        TokenTransferProposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(!proposal.signed[msg.sender], "Already signed");
        proposal.signed[msg.sender] = true;
        proposal.signatureCount += 1;
        emit TokenTransferProposalSigned(proposalId, msg.sender);

        if(proposal.signatureCount >= requiredSignatures) {
            proposal.executed = true;
            IERC20(proposal.token).transfer(proposal.to, proposal.amount);
            emit TokenTransferProposalExecuted(proposalId);
        }
    }
}

