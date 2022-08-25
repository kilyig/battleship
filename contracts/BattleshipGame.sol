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
    Counters.Counter private _finishedGameCounter;

    struct ForceeResponseState {
        address forceeAddress;
        uint256 forceeDeadline;
        bool forceeShouldPlay;
    }

    constructor(address _boardsetupVerifier, address _fireshotVerifier) {
        boardsetupVerifier = IBoardsetupVerifier(_boardsetupVerifier);
        fireshotVerifier = IFireshotVerifier(_fireshotVerifier);
    }

    mapping (uint256 => BattleshipGameState) ticketGameStates;
    mapping (uint256 => ForceeResponseState) forceeResponses;
    mapping (uint256 => BattleshipGameState) finishedGames;

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

    function verifyGameStateSignature(
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
        FireshotResultData memory _fireshotResultData
    ) internal view {
        // check that the forcer has called hit/miss correctly
        // the first shot of the game is an exception as the starter
        // only fires a shot and doesn't need to call
        if(_gameState.turn != 0) {
            require(fireshotVerifier.verifyProof(_fireshotResultData.a,
                                                 _fireshotResultData.b,
                                                 _fireshotResultData.c,
                                                 [_fireshotResultData._hitShipId,
                                                  _gameState.boardHashes[nextPlayerIndex(_gameState)],
                                                  _fireshotResultData._prevTurnShotIndex]),
                                                 "Invalid proof!");
        }

        uint256 playerThatShotIndex = nextPlayerIndex(_gameState);
        if(_fireshotResultData._hitShipId != 0) {
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
        require(verifyGameStateSignature(_gameStateLastAgreed,
                                        forceeAddress,
                                        forceeSignatureLastAgreed));

        // update the game state with the result of the forcee's shot
        iterateGameState(_gameStateLastAgreed, _fireshotResultData);

        // NOTE: the name `_gameStateLastAgreed` is not an accurate description after this point

        // the forcee needs to make the next move only if the forcer's move
        // did not already finish the game.
        bool forceeNeedsToReply = !isFinished(_gameStateLastAgreed);
        uint256 deadlineToPlay = 0;
        if(forceeNeedsToReply) {
            deadlineToPlay = block.timestamp + _gameStateLastAgreed.forceePlayInterval;  
        }

        // create the ticket that the forcee needs to reference when
        // submitting their move 
        ticketGameStates[_ticketCounter.current()] = _gameStateLastAgreed;

        ForceeResponseState memory forceeResponseState;
        forceeResponseState.forceeAddress = forceeAddress;
        forceeResponseState.forceeDeadline = deadlineToPlay;
        forceeResponseState.forceeShouldPlay = true;
        forceeResponses[_ticketCounter.current()] = forceeResponseState;

        emit ForceToPlay(_ticketCounter.current(), msg.sender, forceeAddress, deadlineToPlay, _shot, _gameStateLastAgreed);
        _ticketCounter.increment();
    }

    function play(
        uint256 _ticketNum,
        bytes memory forceeSignatureNewAgreedState,
        FireshotResultData memory _fireshotResultData,
        uint256[2] memory _shot
    ) external playsNext(msg.sender, ticketGameStates[_ticketNum])  {
        // the `playsNext` modifier verified that the sender can make the next
        // move that corresponds to the ticket the sender is referencing

        // check that the forcee is making this move before the deadline
        // and that it is expected to make a move
        require(
            forceeResponses[_ticketNum].forceeShouldPlay &&
            block.timestamp <= forceeResponses[_ticketNum].forceeDeadline 
        );

        BattleshipGameState memory _gameState = ticketGameStates[_ticketNum];

        // update the game state with the result of the forcee's shot
        iterateGameState(_gameState, _fireshotResultData);

        // verify that the forcee's signature matches the game state after
        // the forcer's shot's result is recorded
        require(verifyGameStateSignature(_gameState,
                                        msg.sender,
                                        forceeSignatureNewAgreedState));

        // record the updated game state and the fact that the forcee has provided
        // a valid move before the deadline
        ticketGameStates[_ticketNum] = _gameState;
        forceeResponses[_ticketNum].forceeShouldPlay = false;

        emit Played(_ticketNum, msg.sender, _shot, _gameState);
    }

    function recordFinishedGame(
        BattleshipGameState memory _gameState,
        bytes memory callerSignature,
        bytes memory opponentSignature
    ) external {
        require(isFinished(_gameState));

        // check the caller's signature
        require(verifyGameStateSignature(_gameState,
                                msg.sender,
                                callerSignature));

        // check the opponent's signature
        bool callerIsFirst = _gameState.players[0] == msg.sender;
        address opponentAddress;
        if(callerIsFirst) {
            opponentAddress = _gameState.players[1];
        } else {
            opponentAddress = _gameState.players[0];
        }
        require(verifyGameStateSignature(_gameState,
                                opponentAddress,
                                opponentSignature));

        // record the game
        finishedGames[_finishedGameCounter.current()] = _gameState;
        emit GameFinished(_finishedGameCounter.current());
        _finishedGameCounter.increment();
    }

    function recordFinishedGameForceeAbandoned(
        uint256 _ticketNum
    ) external {
        // deadline to play should have passed
        require(block.timestamp > forceeResponses[_ticketNum].forceeDeadline);

        // declare the winner of the abandoned game
        BattleshipGameState memory _gameStateAbandoned = ticketGameStates[_ticketNum];
        if(forceeResponses[_ticketNum].forceeAddress == _gameStateAbandoned.players[0]) {
            _gameStateAbandoned.winner = _gameStateAbandoned.players[1];
        } else {
            _gameStateAbandoned.winner = _gameStateAbandoned.players[0];
        }

        // record the game as finished
        finishedGames[_finishedGameCounter.current()] = _gameStateAbandoned;
        emit GameFinished(_finishedGameCounter.current());
        _finishedGameCounter.increment();
    }
}
