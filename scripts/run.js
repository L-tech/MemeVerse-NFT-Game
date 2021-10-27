const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
      ["Pawpaw", "Weekend", "VinDiesel"],       // Names
      ["https://i.pinimg.com/736x/9d/08/44/9d08440568a479629cd6d0c9a71cea21.jpg", // Images
      "https://pyxis.nymag.com/v1/imgs/258/ab8/b37c0379b29ab114b7c18e2bc11e89a5ec-the-weeknd-meme.2x.rsocial.w600.jpg", 
      "https://resize.indiatvnews.com/en/resize/newbucket/715_-/2021/07/vin-diesel-1625565599.jpg"],
      [100, 200, 300],                    // HP values
      [100, 50, 25],
      [90, 40, 70]                       // Attack damage values & Poularity Level
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);
    let txn;
    // We only have three characters.
    // an NFT w/ the character at index 2 of our array.
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    // Get the value of the NFT's URI.
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);
    };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();