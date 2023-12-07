// priceFetcher.js
const axios = require('axios');

async function usdtPrice() {
    try {
        const response = await axios.get('https://api.coingecko.com/api/v3/simple/price?ids=tether&vs_currencies=usd');
        const data = response.data;
        return data['tether']['usd'];
    } catch (error) {
        console.error('Error fetching USDT price:', error.message);
        throw error;
    }
}

module.exports = { usdtPrice };
