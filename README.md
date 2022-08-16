# zkBattleship
[Battleship](https://en.wikipedia.org/wiki/Battleship_(game)) using smart contracts and zero-knowledge proofs.

## This Project's Contribution
Other zero-knowledge implementations of the battleship game are on-chain. So, starting a game, joining a game and making moves are all done by calling functions on a smart contract. This setup 1) slows down the gameplay as players need to wait until transactions are added to the blockchain, 2) makes the game expensive to play as every move costs gas. Our smart contract acts as a referee, not as a game driver. Players are able to play the game completely off-chain while having the option to communicate with the referee smart contract at any point during the game. This reflects our view that a blockchain's primary goal should be to settle disagreements. The existence of a reliable referee that punishes bad behaviour forces players to abide by the rules.

## Installation and Usage
To download, run
```
git clone https://github.com/kilyig/battleship.git
```
and make sure that [`hardhat-circom`](https://github.com/projectsophon/hardhat-circom) is installed. In the project's root,
run
```
npx hardhat circom
```
to compile the circom files. Here, we unfortunately hit a `TODO` that will hopefully be cared for soon. Please rename the contracts in the verifiers as described in the `TODO` in `scripts/deploy.js`. Next, start the local network by running
```
npx hardhat node
```
In another terminal, run
```
npx hardhat run scripts/deploy.js
```
to deploy the two verifiers and the referee smart contract.

## Acknowledgements
The zero-knowledge circuits were copied from CDDelta's [`battleship3`](https://github.com/CDDelta/battleship3), as this project focuses on optimizing the smart contract side.

## Related Work
https://github.com/tommymsz006/zkbattleship/tree/master/src/app
https://courses.csail.mit.edu/6.857/2020/projects/13-Gupta-Kaashoek-Wang-Zhao.pdf
https://github.com/SteelShredder/ZKBattleship
https://github.com/BattleZips/BattleZips
https://github.com/CDDelta/battleship3
https://docs.electronlabs.org/docs/battleship-game

