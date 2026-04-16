require('express');
require('mongodb');
var token = require('./createJWT.js');

exports.setApp = function (app, client) {

    // ─── LOGIN ───────────────────────────────────────────────────────────────────
    app.post('/api/login', async (req, res, next) => {
        const { login, password } = req.body; 
        const db = client.db('OutfittrDB');
        
        try {
            const user = await db.collection('Users').findOne({ 
                email: login, 
                password: password 
            });

            if (user) {
                const ret = token.createToken(user._id);
                res.status(200).json(ret);
            } else {
                res.status(401).json({ error: 'Email/Password incorrect' });
            }
        } catch (e) {
            res.status(500).json({ error: e.message });
        }
    });

    // ─── REGISTER ─────────────────────────────────────────────────────────────
    app.post('/api/register', async (req, res, next) => {
        const { email, password } = req.body;

        try {
            const db = client.db('OutfittrDB');

            const existing = await db.collection('Users').findOne({ email: email });
            if (existing) {
                res.status(200).json({ error: 'Email already exists', accessToken: '' });
                return;
            }

            const newUser = {
                email: email,
                password: password
            };

            const result = await db.collection('Users').insertOne(newUser);
            const id = result.insertedId;

            var ret;
            try {
                ret = token.createToken(id);
            } catch (e) {
                ret = { error: e.message, accessToken: '' };
            }

            res.status(200).json(ret);
        } catch (e) {
            res.status(500).json({ error: e.toString(), accessToken: '' });
        }
    });

    // ─── ADD ITEM ─────────────────────────────────────────────────────────────────
    app.post('/api/additem', async (req, res, next) => {
        const { userId, item, jwtToken } = req.body;

        if (token.isExpired(jwtToken)) {
            return res.status(200).json({ error: 'The JWT is no longer valid', accessToken: '' });
        }

        const newItem = { Item: item, UserId: userId };
        let error = '';

        try {
            const db = client.db('OutfittrDB');
            await db.collection('Items').insertOne(newItem);
        } catch (e) {
            error = e.toString();
        }

        let refreshedToken = null;
        try {
            refreshedToken = token.refresh(jwtToken);
        } catch (e) {
            console.log("Refresh error: " + e.message);
        }

        res.status(200).json({ error: error, accessToken: refreshedToken.accessToken });
    });

    // ─── SEARCH ITEMS ─────────────────────────────────────────────────────────────
    app.post('/api/searchitems', async (req, res, next) => {
        const { userId, search, jwtToken } = req.body;

        if (token.isExpired(jwtToken)) {
            return res.status(200).json({ error: 'The JWT is no longer valid', accessToken: '' });
        }

        const _search = search.trim();
        const db = client.db('OutfittrDB');
        const results = await db.collection('Items')
            .find({
                UserId: userId,
                "Item": { $regex: _search + '.*', $options: 'i' }
            })
            .toArray();

        const _ret = results.map(doc => doc.Item);

        let refreshedToken = null;
        try {
            refreshedToken = token.refresh(jwtToken);
        } catch (e) {
            console.log("Refresh error: " + e.message);
        }

        res.status(200).json({ results: _ret, error: '', accessToken: refreshedToken.accessToken });
    });
}