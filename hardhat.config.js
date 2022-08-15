require("@nomicfoundation/hardhat-toolbox");
require("hardhat-circom");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.16",
  circom: {
    // (optional) Base path for input files, defaults to `./circuits/`
    inputBasePath: "./circuits/src",
    outputBasePath: "./circuits/src",
    // (required) The final ptau file, relative to inputBasePath, from a Phase 1 ceremony
    ptau: "ptau/pot15_final.ptau",
    // (required) Each object in this array refers to a separate circuit
    circuits: [
      {
        // (required) The name of the circuit
        name: "boardsetup",
        // (optional) The circom version used to compile circuits (1 or 2), defaults to 2
        version: 2,
        // (optional) Protocol used to build circuits ("groth16" or "plonk"), defaults to "groth16"
        protocol: "groth16",
        // (optional) Input path for circuit file, inferred from `name` if unspecified
        circuit: "boardsetup/boardsetup.circom",
        // (optional) Input path for witness input file, inferred from `name` if unspecified
        input: "boardsetup/inputs/boardsetup-input.json",
        // (optional) Output path for wasm file, inferred from `name` if unspecified
        wasm: "boardsetup/boardsetup.wasm",
        // (optional) Output path for zkey file, inferred from `name` if unspecified
        zkey: "boardsetup/boardsetup.zkey",
        // Used when specifying `--deterministic` instead of the default of all 0s
        beacon: "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f",
      },
      {
        // (required) The name of the circuit
        name: "fireshot",
        // (optional) The circom version used to compile circuits (1 or 2), defaults to 2
        version: 2,
        // (optional) Protocol used to build circuits ("groth16" or "plonk"), defaults to "groth16"
        protocol: "groth16",
        // (optional) Input path for circuit file, inferred from `name` if unspecified
        circuit: "fireshot/fireshot.circom",
        // (optional) Input path for witness input file, inferred from `name` if unspecified
        input: "fireshot/inputs/fireshot-input.json",
        // (optional) Output path for wasm file, inferred from `name` if unspecified
        wasm: "fireshot/fireshot.wasm",
        // (optional) Output path for zkey file, inferred from `name` if unspecified
        zkey: "fireshot/fireshot.zkey",
        // Used when specifying `--deterministic` instead of the default of all 0s
        beacon: "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f",
      },
    ],
  },
};
