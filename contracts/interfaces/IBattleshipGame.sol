// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBoardsetupVerifier.sol";
import "./IFireshotVerifier.sol";


interface IBattleshipGame {
    // event Started(uint256 _gameId, address _by);
    // event Joined(uint256 _gameId, address _by);
    // event ShotFired(uint256 _gameId, uint8 _shotIndex);
    // event ShotLanded(uint256 _gameId, uint8 _shipId);
    // event Won(uint256 _gameId, address _by);

    struct BattleshipGameState {
        // identifier for the games between the two players.
        // (not a unique identifier for all the games played by all players)
        uint256 gameId;
        // The address of the two players.
        address[2] players;
        // The hash committing to the ship configuration of each game.
        uint256[2] boardHashes;
        // The turn number of this game.
        uint256 turn;
        // Mapping of player shot indices to turn number.
        // The shot indices of the second player are offset by 100.
        //mapping(uint256 => uint256) shots;
        // The number of hits each player has made on a ship.
        uint256[2] hits;
        // The winner of the game.
        address winner;

        uint256 forceePlayInterval;
    }

    struct FireshotResultData {
        uint256 _hitShipId;
        uint256 _prevTurnShotIndex;
        uint256 _turnShotIndex;
        uint256 deneme;
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }

    function forceToPlay(
        BattleshipGameState memory _gameStateLastAgreed,
        bytes memory forceeSignatureLastAgreed,
        FireshotResultData memory _fireshotResultData,
        uint256[2] memory _shot
    ) external;

    function play(
        BattleshipGameState memory _gameStateAfterForcedTurn,
        bytes memory forceeForcedTurnSignature,
        uint256[2] memory _shot
    ) external;


    /*
     * @dev modifier isPlayer
     * Called by a player when they feel a need to force the other player
     * to share the result of the latest shot (hit/miss). Such a situation
     * can arise if a losing player is intentionally slowing down the game
     * or sending invalid messages. This function declares the timestamp before
     * which the other player must have submitted the result of the shot by.
     * The function calculates the timestamp from the game state.
     *
     * @param _lastAgreedGameState uint256 - hash of ship placement on board
     * @param a uint256[2] - zk proof part 1
     * @param b_0 uint256[2] - zk proof part 2 split 1
     * @param b_1 uint256[2] - zk proof part 2 split 2
     * @param c uint256[2] - zk proof part 3
     */
    // function forceToShareShotResult(
    //     BattleshipGameState memory _lastAgreedGameState,
    //     bytes memory otherPlayerSignature,
    //     uint256[2] memory _shot
    // ) external;

    /* TODO: correct the descriptions below
     * Called by a player when they feel a need to force the other player
     * to share the result of the latest shot (hit/miss). Such a situation
     * can arise if a losing player is intentionally slowing down the game
     * or sending invalid messages. This function declares the timestamp before
     * which the other player must have submitted the result of the shot by.
     * The function calculates the timestamp from the game state.
     * @dev modifier isPlaying
     *
     * @param _lastAgreedGameState uint256 - hash of ship placement on board
     * @param a uint256[2] - zk proof part 1
     * @param b uint256[2][] - zk proof part 2
     * @param c uint256[2] - zk proof part 3
     */
    // function shareShotResult(
    //     BattleshipGameState memory _gameStateAfterShotResult,
    //     bytes memory signature,
    //     uint256 _hitShipId,
    //     uint256[2] memory a,
    //     uint256[2][2] memory b,
    //     uint256[2] memory c
    // ) external;


}