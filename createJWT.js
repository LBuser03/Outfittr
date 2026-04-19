const jwt = require("jsonwebtoken");
require("dotenv").config();

exports.createToken = function (id) {
    return _createToken(id);
}

_createToken = function (id) {
    try {
        // This is correct for your minimal schema
        const user = { userId: id }; 
        
        const accessToken = jwt.sign(user, process.env.ACCESS_TOKEN_SECRET, 
            { expiresIn: '30m' });    
        
        return { accessToken: accessToken };
    }
    catch (e) {
        return { error: e.message };
    }
}

exports.isExpired = function (token) {
    try {
        jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        return false;
    }
    catch (e) {
        return true;
    }
}

exports.refresh = function (token) {
    if (!token) {
        throw new Error("Missing token");
    }

    var ud = jwt.decode(token, { complete: true });
    var userId = ud.payload.userId;
    
    // Refreshing only with userId
    return _createToken(userId);
}