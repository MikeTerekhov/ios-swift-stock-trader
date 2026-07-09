import 'dotenv/config';
import express from 'express';
import axios from 'axios';
import cors from 'cors';

const app = express();

app.use(express.json());
app.use(express.static('angular-app/dist/angular-app/browser'));

const corsOptions = {
    origin: 'http://localhost:4200',
    //origin: 'https://projthree.wl.r.appspot.com', // This should be the origin of your Angular app
    optionsSuccessStatus: 200 
};
app.use(cors(corsOptions)); 
app.options('*', cors(corsOptions));

const port = process.env.PORT || 8080;

app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});

app.get('/api/charts/:q/:from/:to', async (req, res) => {
    const query = req.params.q.toUpperCase();
    const apikey = process.env.POLYGON_API_KEY;
    const fromDate = req.params.from;
    const toDate = req.params.to;

    const url = `https://api.polygon.io/v2/aggs/ticker/${encodeURIComponent(query)}/range/1/hour/${encodeURIComponent(fromDate)}/${encodeURIComponent(toDate)}?adjusted=true&%20sort=asc&apiKey=${encodeURIComponent(apikey)}`;

    try {
        const poly_res = await axios.get(url);
        res.json(poly_res.data); 
    } catch (error) {
        console.error('Error calling POLYGON:', error);
        res.status(500).send('Server error');
    }
});

app.get('/api/charts2/:q/:from/:to', async (req, res) => {
    const query = req.params.q.toUpperCase();
    const apikey = process.env.POLYGON_API_KEY;
    const fromDate = req.params.from;
    const toDate = req.params.to;

    const url = `https://api.polygon.io/v2/aggs/ticker/${encodeURIComponent(query)}/range/1/day/${encodeURIComponent(fromDate)}/${encodeURIComponent(toDate)}?adjusted=true&%20sort=asc&apiKey=${encodeURIComponent(apikey)}`;
    console.log(url);

    try {
        const poly_res = await axios.get(url);
        res.json(poly_res.data); 
    } catch (error) {
        console.error('Error calling POLYGON:', error);
        res.status(500).send('Server error');
    }
});


app.get('/search/:q', async (req, res) => {
    const query = req.params.q;
    const finnhubApiKey = process.env.FINNHUB_API_KEY;

    const profileUrl = `https://finnhub.io/api/v1/stock/profile2?symbol=${encodeURIComponent(query)}&token=${finnhubApiKey}`;
    const quoteUrl = `https://finnhub.io/api/v1/quote?symbol=${encodeURIComponent(query)}&token=${finnhubApiKey}`;
    const peersRequestUrl = `https://finnhub.io/api/v1/stock/peers?symbol=${encodeURIComponent(query)}&token=${finnhubApiKey}`;
    console.log("SEARCH backy");
    try {
        const [profileResponse, quoteResponse, peersResponse] = await Promise.all([
            axios.get(profileUrl).catch(error => {
                console.error('Error fetching profile:', error);
                return { data: {} }; 
            }),
            axios.get(quoteUrl).catch(error => {
                console.error('Error fetching quote:', error);
                return { data: {} }; 
            }),
            axios.get(peersRequestUrl).catch(error => {
                console.error('Error fetching peers:', error);
                return { data: {} }; 
            })
        ]);

        if ('error' in profileResponse.data || 'error' in quoteResponse.data || 'error' in peersResponse.data) {
            throw new Error('One of the Finnhub responses came back with an error.');
        }

        const combinedResponse = {
            profile: profileResponse.data,
            quote: quoteResponse.data,
            peers: peersResponse.data 
        };

        res.json(combinedResponse);
    } catch (error) {
        console.error('Error calling Finnhub:', error);
        res.status(500).send('Server error');
    }
});

app.get('/api/autocomplete/:q', async (req, res) => {
    const query = req.params.q;
    const finnhubApiKey = process.env.FINNHUB_API_KEY;
    const finnhubUrl = `https://finnhub.io/api/v1/search?q=${encodeURIComponent(query)}&token=${finnhubApiKey}`;
  
    console.log("NODE INDEX JS!!!");

    try {
        const finnhubResponse = await axios.get(finnhubUrl);
        res.json(finnhubResponse.data); 
    } catch (error) {
        console.error('Error calling Finnhub:', error);
        res.status(500).send('Server error');
    }
});

app.get('/api/news/:q/:weekBefore/:currentDate', async (req, res) => {
    const query = req.params.q.toUpperCase();
    const weekBefore = req.params.weekBefore;
    const currentDate = req.params.currentDate;
    const finnhubApiKey = process.env.FINNHUB_API_KEY;
    const finnhubUrl = `https://finnhub.io/api/v1/company-news?symbol=${encodeURIComponent(query)}&from=${encodeURIComponent(weekBefore)}&to=${encodeURIComponent(currentDate)}&token=${finnhubApiKey}`;
  
    try {
        const finnhubResponse = await axios.get(finnhubUrl);
        res.json(finnhubResponse.data); 
    } catch (error) {
        console.error('Error calling Finnhub:', error);
        res.status(500).send('Server error');
    }
});

app.get('/api/insights/:q', async (req, res) => {
    const query = req.params.q.toUpperCase();
    const finnhubApiKey = process.env.FINNHUB_API_KEY;
    const finnhubUrl = `https://finnhub.io/api/v1/stock/insider-sentiment?symbol=${encodeURIComponent(query)}&from=2022-01-01&token=${encodeURIComponent(finnhubApiKey)}`;
  
    console.log("insightsssssss");

    try {
        const finnhubResponse = await axios.get(finnhubUrl);
        res.json(finnhubResponse.data); 
    } catch (error) {
        console.error('Error calling Finnhub:', error);
        res.status(500).send('Server error');
    }
});

app.get('/api/recs/:q', async (req, res) => {
    const query = req.params.q.toUpperCase();
    const finnhubApiKey = process.env.FINNHUB_API_KEY;
    const finnhubUrl = `https://finnhub.io/api/v1/stock/recommendation?symbol=${encodeURIComponent(query)}&token=${encodeURIComponent(finnhubApiKey)}`;
  
    try {
        const finnhubResponse = await axios.get(finnhubUrl);
        res.json(finnhubResponse.data); 
    } catch (error) {
        console.error('Error calling Finnhub:', error);
        res.status(500).send('Server error');
    }
});

app.get('/api/earn/:q', async (req, res) => {
    const query = req.params.q.toUpperCase();
    const finnhubApiKey = process.env.FINNHUB_API_KEY;
    const finnhubUrl = `https://finnhub.io/api/v1/stock/earnings?symbol=${encodeURIComponent(query)}&token=${encodeURIComponent(finnhubApiKey)}`;
  
    try {
        const finnhubResponse = await axios.get(finnhubUrl);
        res.json(finnhubResponse.data); 
    } catch (error) {
        console.error('Error calling Finnhub:', error);
        res.status(500).send('Server error');
    }
});

import { MongoClient } from 'mongodb';

const uri = process.env.MONGODB_URI;

const client = new MongoClient(uri);

let stockPurchases, favorites, accountSettings;

async function connectToMongoDB() {
    await client.connect();
    const database = client.db('HW3');
    stockPurchases = database.collection('stockPurchases');
    favorites = database.collection('favorites');
    accountSettings = database.collection('accountSettings'); 
}

connectToMongoDB().catch(console.error);

app.post('/balance/update', async (req, res) => {
    const { balance } = req.body;
    const existingBalance = await accountSettings.findOne({});
    if (existingBalance) {
        const result = await accountSettings.updateOne({}, { $set: { balance } });
        res.json(result);
    } else {
        const result = await accountSettings.insertOne({ balance });
        res.json(result);
    }
});

app.get('/balance', async (req, res) => {
    let balanceDoc = await accountSettings.findOne({});
    console.log("BALANCE");
    if (!balanceDoc) {
        console.log("Balance not found, initializing with $25,000");
        await accountSettings.insertOne({ balance: 25000 });
        balanceDoc = await accountSettings.findOne({});
    }

    res.json(balanceDoc.balance);
});


app.put('/balance', async (req, res) => {
    const { balance } = req.body;
    const result = await accountSettings.updateOne({}, { $set: { balance } }, { upsert: true });
    res.json(result);
});

app.post('/buyStock', async (req, res) => {
    const { ticker, shares, purchasePrice, currentPrice, corpName } = req.body;
    const totalCost = shares * purchasePrice;
    let session;

    try {
        session = await client.startSession();
        session.startTransaction();

        const userBalanceDoc = await accountSettings.findOne({});
        if (!userBalanceDoc || userBalanceDoc.balance < totalCost) {
            await session.abortTransaction();
            return res.status(400).json({ message: 'Insufficient funds or user not found' });
        }

        await accountSettings.updateOne(
            {}, 
            { $inc: { balance: -totalCost } },
            { session }
        );

        const existingPurchase = await stockPurchases.findOne({ ticker });

        if (existingPurchase) {
            const newTotalCost = existingPurchase.totalCost + totalCost;
            await stockPurchases.updateOne(
                { ticker },
                { 
                    $inc: { shares: shares, totalCost: totalCost },
                    $set: { currentPrice: currentPrice, corpName: corpName } 
                },
                { session }
            );
        } else {
            await stockPurchases.insertOne(
                { 
                    ticker, 
                    shares, 
                    purchasePrice, 
                    currentPrice,
                    corpName,
                    totalCost
                },
                { session }
            );
        }

        await session.commitTransaction();
        res.json({ message: 'Stock purchased successfully', totalCost: totalCost }); 
    } catch (error) {
        console.error('Error during stock purchase:', error);
        if (session) {
            await session.abortTransaction();
        }
        res.status(500).json({ message: 'An error occurred' }); 
    } finally {
        if (session) {
            await session.endSession();
        }
    }
});


app.post('/updateCurrentPrice', async (req, res) => {
    const { ticker, currentPrice } = req.body;
    try {
        const result = await stockPurchases.updateOne(
            { ticker: ticker },
            { $set: { currentPrice: currentPrice } }
        );
        res.json({ message: 'Current price updated successfully', result });
    } catch (error) {
        console.error(`Error updating current price for ${ticker}:`, error);
        res.status(500).json({ message: 'An error occurred' });
    }
});

app.get('/stockPurchases', async (req, res) => {
    const cursor = stockPurchases.find({});
    const results = await cursor.toArray();
    res.json(results);
});

app.post('/sellStock', async (req, res) => {
    const { ticker, sharesToSell } = req.body;
    let session;

    try {
        session = await client.startSession();
        session.startTransaction();

        const userBalanceDoc = await accountSettings.findOne({});
        if (!userBalanceDoc) {
            await session.abortTransaction();
            return res.status(400).json({ message: 'User not found' });
        }

        const existingPurchase = await stockPurchases.findOne({ ticker });
        if (!existingPurchase || existingPurchase.shares < sharesToSell) {
            await session.abortTransaction();
            return res.status(400).json({ message: 'Not enough shares to sell' });
        }

        const totalSale = sharesToSell * existingPurchase.currentPrice;
        await accountSettings.updateOne(
            {},
            { $inc: { balance: totalSale } },
            { session }
        );

        if (existingPurchase.shares === sharesToSell) {
            await stockPurchases.deleteOne({ ticker }, { session });
        } else {
            const newTotalCost = existingPurchase.totalCost - (sharesToSell * existingPurchase.purchasePrice);

            await stockPurchases.updateOne(
                { ticker },
                { 
                    $inc: { 
                        shares: -sharesToSell,
                        totalCost: - (sharesToSell * existingPurchase.purchasePrice)
                    }
                },
                { session }
            );
        }

        await session.commitTransaction();
        res.json({ message: 'Stock sold successfully', totalSale: totalSale });
    } catch (error) {
        console.error('Error during stock sale:', error);
        if (session) {
            await session.abortTransaction();
        }
        res.status(500).json({ message: 'An error occurred' });
    } finally {
        if (session) {
            session.endSession();
        }
    }
});


app.post('/favorites', async (req, res) => {
    const result = await favorites.insertOne(req.body);
    res.json(result);
});

app.get('/favorites', async (req, res) => {
    const cursor = favorites.find({});
    const results = await cursor.toArray();
    res.json(results);
});

app.put('/favorites/:id', async (req, res) => {
    const result = await favorites.updateOne(
        { _id: new ObjectId(req.params.id) },
        { $set: req.body }
    );
    res.json(result);
});

app.delete('/favorites/del/:ticker', async (req, res) => {
    console.log("remove fav BACKY");
    const { ticker } = req.params;
    const result = await favorites.deleteOne({ ticker });
    if (result.deletedCount === 0) {
        return res.status(404).send('Favorite not found');
    }
    res.json({ message: 'Favorite removed', ticker });
});

app.post('/updateFavorite', async (req, res) => {
    const { ticker, corpName, highPrice, change, percentChange } = req.body; 

    try {
        const updateResult = await favorites.updateOne(
            { ticker: ticker }, 
            {
                $set: {
                    corpName: corpName,
                    highPrice: highPrice,
                    change: change,
                    percentChange: percentChange
                }
            } 
        );

        if (updateResult.matchedCount === 0) {
            return res.status(404).json({ message: `Favorite stock with ticker ${ticker} not found.` });
        }

        res.json({ message: `Favorite for ${ticker} updated successfully.` });
    } catch (error) {
        console.error(`Error updating favorite for ${ticker}:`, error);
        res.status(500).json({ message: 'An error occurred while updating the favorite.' });
    }
});
