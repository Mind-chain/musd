// mainScript.js
const { ethers } = require('ethers');
const { usdtPrice } = require('./fetcher.js');

const privateKey = 'YOUR_PRIVATE_KEY';
// Replace the next line with the URL of your custom Ethereum node
const customProviderUrl = 'YOUR_CUSTOM_PROVIDER_URL';
const oracleAddress = 'YOUR_ORACLE_CONTRACT_ADDRESS';
const updateIntervalInSeconds = 300;

// Use your custom provider URL
const provider = new ethers.providers.JsonRpcProvider(customProviderUrl);
const wallet = new ethers.Wallet(privateKey, provider);

const oracleAbi = [...]; // Replace with the actual ABI of your Oracle contract
const oracleContract = new ethers.Contract(oracleAddress, oracleAbi, wallet);

async function updatePrice() {
    try {
        const newPrice = await usdtPrice();

        // Call the updatePrice function in the Oracle contract
        const transaction = await oracleContract.updatePrice();
        await transaction.wait();

        console.log(`USD price updated to: ${newPrice}`);
    } catch (error) {
        console.error('Error updating price:', error.message);
    }
}

async function run() {
    while (true) {
        await updatePrice();
        await sleep(updateIntervalInSeconds * 1000); // Convert seconds to milliseconds
    }
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

run();
