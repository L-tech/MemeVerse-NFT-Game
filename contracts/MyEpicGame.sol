// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Helper to encode in Base64
import "./libraries/Base64.sol";



import "hardhat/console.sol";

contract MyEpicGame is ERC721 {
    // Save characters attributes in a struct
    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);
    struct CharacterAttributes{
        uint characterIndex;
        string name;
        string imageURI;        
        uint hp;
        uint maxHp;
        uint attackDamage;
        uint popularity;
        uint maxPopularity;
    }
    struct BigMeme {
      string name;
      string imageURI;
      uint hp;
      uint maxHp;
      uint attackDamage;
      uint popularity;
      uint maxPopularity;
    }

    BigMeme public bigMeme;
    // set unique value for BFT  
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // array to hold default of characters
    CharacterAttributes[] defaultCharacters;

    // a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;

    // pass some variables while initiating the contract
    constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    uint[] memory popularityLevel,
    string memory bossName, // These new variables would be passed in via run.js or deploy.js.
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDamage,
    uint bossPopularityLevel
  ) ERC721("MEMES", "MEM")
  {
    bigMeme = BigMeme({
    name: bossName,
    imageURI: bossImageURI,
    hp: bossHp,
    maxHp: bossHp,
    attackDamage: bossAttackDamage,
    popularity: bossPopularityLevel,
    maxPopularity: bossPopularityLevel
  });

  console.log("Done initializing boss %s w/ HP %s, img %s", bigMeme.name, bigMeme.hp, bigMeme.imageURI);

      for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i],
        popularity: popularityLevel[i],
        maxPopularity: popularityLevel[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }
    _tokenIds.increment();
  }
  // Users would be able to hit this function and get their NFT based on the
  // characterId they send in!
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // We map the tokenId => their character attributes. More on this in
    // the lesson below.
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].hp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage,
      popularity: defaultCharacters[_characterIndex].popularity,
      maxPopularity: defaultCharacters[_characterIndex].popularity
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }
  function attackBoss() public {
      // Get the state of the player's NFT.
      uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
      CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

      console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
      console.log("Boss %s has %s HP and %s AD", bigMeme.name, bigMeme.hp, bigMeme.attackDamage);
      
      // Make sure the player has more than 0 HP.
      require (
        player.hp > 0,
        "Error: character must have HP to attack boss."
      );

      // Make sure the boss has more than 0 HP.
      require (
        bigMeme.hp > 0,
        "Error: boss must have HP to attack boss."
      );
      
      // Allow player to attack boss.
      if (bigMeme.hp < player.attackDamage) {
        bigMeme.hp = 0;
      } else {
        bigMeme.hp = bigMeme.hp - player.attackDamage;
  }

  // Allow boss to attack player.
  if (player.hp < bigMeme.attackDamage) {
    player.hp = 0;
  } else {
    player.hp = player.hp - bigMeme.attackDamage;
  }
  
  // Console for ease.
  console.log("Boss attacked player. New player hp: %s\n", player.hp);
}

function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
  // Get the tokenId of the user's character NFT
  uint256 userNftTokenId = nftHolders[msg.sender];
  // If the user has a tokenId in the map, return their character.
  if (userNftTokenId > 0) {
    return nftHolderAttributes[userNftTokenId];
  }
  // Else, return an empty character.
  else {
    CharacterAttributes memory emptyStruct;
    return emptyStruct;
   }
}

function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
  return defaultCharacters;
}
function getBigBoss() public view returns (BigMeme memory) {
  return bigMeme;
}

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
  CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

  string memory strHp = Strings.toString(charAttributes.hp);
  string memory strMaxHp = Strings.toString(charAttributes.maxHp);
  string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
  string memory strPopularityLevel = Strings.toString(charAttributes.popularity);
  string memory strMaxPopularityLevel = Strings.toString(charAttributes.popularity);

  string memory json = Base64.encode(
    bytes(
      string(
        abi.encodePacked(
          '{"name": "',
          charAttributes.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "This is an NFT that lets people play in the game MemeVerse Anchor!", "image": "',
          charAttributes.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
          strAttackDamage,'}, {"trait_type": "Popularity", "value": ',strPopularityLevel,', "max_value":',strMaxPopularityLevel,' } ]}'
        )
      )
    )
  );

  string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
  );
  
  return output;
}
}