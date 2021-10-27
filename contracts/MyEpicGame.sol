// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MyEpicGame {
    // Save characters attributes in a struct

    struct CharacterAttributes{
        uint characterIndex;
        string name;
        string imageURI;        
        uint hp;
        uint maxHp;
        uint attackDamage;
        uint popularity;
    }
    // array to hold default of characters
    CharacterAttributes[] defaultCharacters;
    // pass some variables while initiating the contract
    constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    uint[] memory popularityLevel
  ){
      for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i],
        popularity: popularityLevel[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }
  }
}