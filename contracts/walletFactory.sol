// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./multiSigWallet.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract MultiSigWalletFactory is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    mapping(uint256 => address) public wallets;
    uint256 public walletIndex;

    event Deploy(address addr);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    // to deploy another contract using owner address and salt specified

    function deploy(
        uint256 _salt,
        address[] memory _signers,
        uint256 confirmations
    ) external {
        MultiSigWallet _contract = new MultiSigWallet{salt: bytes32(_salt)}(
            msg.sender,
            _signers,
            confirmations
        );
        walletIndex++;
        wallets[walletIndex] = address(_contract);
        emit Deploy(address(_contract));
    }

    function getAddress(
        bytes memory bytecode,
        uint256 _salt
    ) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(MultiSigWallet).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_owner));
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}

    function getWallets() external view returns(address[] memory) {
        address[] memory _wallets = new address[](walletIndex);
        for(uint256 i =0; i< walletIndex; i++) {
            _wallets[i] = wallets[i+1];
        }
        return _wallets;
    }
}
