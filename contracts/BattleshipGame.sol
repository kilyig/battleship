//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IBoardSetupVerifier.sol";
import "./interfaces/IFireShotVerifier.sol";
import "./interfaces/IBattleshipGame.sol";

contract BattleshipGame is IBattleshipGame {
    
    IBoardSetupVerifier boardSetupVerifier;
    IFireShotVerifier fireShotVerifier;

    struct BattleshipGame {
        /// The address of the two players.
        address[2] participants;
        /// The hash committing to the ship configuration of each playment.
        uint256[2] boards;
        /// The turn number of this game.
        uint256 turn;
        /// Mapping of player shot indices to turn number.
        /// The shot indices of the second player are offset by 100.
        mapping(uint256 => uint256) shots;
        /// The number of hits each player has made on a ship.
        uint256[2] hits;
        /// The winner of the game.
        address winner;
    }

    constructor(address _boardSetupVerifier, address _fireShotVerifier) {
        boardSetupVerifier = IBoardSetupVerifier(_boardSetupVerifier);
        fireShotVerifier = IFireShotVerifier(_fireShotVerifier);
    }

    function forceToPlay(
        uint256 _gameI, uint256[2] memory _shot) {

    }


    function gameFinished() {

    }
}