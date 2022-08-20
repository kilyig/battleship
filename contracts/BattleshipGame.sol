//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

import "./interfaces/IBoardsetupVerifier.sol";
import "./interfaces/IFireshotVerifier.sol";
import "./interfaces/IBattleshipGame.sol";

contract BattleshipGame is IBattleshipGame {
    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    uint256 public constant WIN_HIT_COUNT = 5 + 4 + 3 + 3 + 2;

    IBoardsetupVerifier boardsetupVerifier;
    IFireshotVerifier fireshotVerifier;

    Counters.Counter private _ticketCounter;
    mapping(uint256 => uint256) private shots;

    constructor(address _boardsetupVerifier, address _fireshotVerifier) {
        boardsetupVerifier = IBoardsetupVerifier(_boardsetupVerifier);
        fireshotVerifier = IFireshotVerifier(_fireshotVerifier);
    }

    mapping (uint256 => BattleshipGameState) tickets;

    modifier isPlayer(address supposedPlayer, BattleshipGameState memory gameState) {
        require(
            supposedPlayer == gameState.players[0] ||
            supposedPlayer == gameState.players[1]
        );
        _;
    }

    modifier playsNext(address player, BattleshipGameState memory gameState) {
        require(
            player == gameState.players[nextPlayerIndex(gameState)]
        );
        _;
    }

    function nextPlayerIndex(BattleshipGameState memory gameState) internal pure returns (uint256) {
        return gameState.turn % 2;
    }

    function verifyGameState(
        BattleshipGameState memory gameState,
        address desiredSigner,
        bytes memory signature
        ) internal pure returns (bool) {
        // Hash those params!
        bytes32 messagehash =  keccak256(abi.encode(gameState));
        // See who's the signer
        address signer = messagehash.toEthSignedMessageHash().recover(signature);
        if (desiredSigner  == signer) {
            // Checks out!
            return (true);
        } else {
            // Looks bogus.
            return (false);
        }
    }

    function iterateGameState(
        BattleshipGameState memory _gameState,
        uint256 _hitShipId
    ) internal pure {
        uint256 playerThatShotIndex = nextPlayerIndex(_gameState);
        if(_hitShipId != 0) {
            _gameState.hits[playerThatShotIndex] += 1;
            if(_gameState.hits[playerThatShotIndex] == WIN_HIT_COUNT) {
                _gameState.winner = _gameState.players[playerThatShotIndex];
            }
        }

        _gameState.turn += 1;
    }

    function isFinished(BattleshipGameState memory _gameState) public pure returns (bool) {
        return _gameState.winner == _gameState.players[0] ||
               _gameState.winner == _gameState.players[1];
    }

    function forceToPlay(
        BattleshipGameState memory _gameStateLastAgreed,
        bytes memory forceeSignatureLastAgreed,
        FireshotResultData memory _fireshotResultData,
        uint256[2] memory _shot
    ) external playsNext(msg.sender, _gameStateLastAgreed) {
        // verify that the forcee had really agreed on the state
        address forceeAddress = _gameStateLastAgreed.players[(nextPlayerIndex(_gameStateLastAgreed) + 1) % 2];
        require(verifyGameState(_gameStateLastAgreed,
                                forceeAddress,
                                forceeSignatureLastAgreed));

        // check that the forcer has called hit/miss correctly
        // the first shot of the game is an exception as the starter
        // only fires a shot and doesn't need to call
        if(_gameStateLastAgreed.turn != 0) {
            require(fireshotVerifier.verifyProof(_fireshotResultData.a,
                                                 _fireshotResultData.b,
                                                 _fireshotResultData.c,
                                                 [_fireshotResultData._hitShipId,
                                                  _gameStateLastAgreed.boardHashes[nextPlayerIndex(_gameStateLastAgreed)],
                                                  _fireshotResultData._prevTurnShotIndex]),
                                                 "Invalid proof!");
        }

        // update the game state with the result of the forcee's shot
        iterateGameState(_gameStateLastAgreed, _fireshotResultData._hitShipId);

        // the forcee needs to make the next move only if the forcer's move
        // did not already finish the game.
        bool forceeNeedsToReply = !isFinished(_gameStateLastAgreed);
        if(forceeNeedsToReply) {
            uint256 forceeDeadline = block.timestamp + _gameStateLastAgreed.forceePlayInterval;  
        }






    }

    function play(
        BattleshipGameState memory _gameStateAfterForcedTurn,
        bytes memory forceeForcedTurnSignature,
        uint256[2] memory _shot
    ) external {

    }

}