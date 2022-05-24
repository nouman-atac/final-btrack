const moment = require('moment');
const {getDB} = require('../db/mongo.js');
const logger = (req,res,next)=>{


    console.log(`Log: ${req.protocol}://${req.get('host')}${req.originalUrl}  on ${Date(Date.now())}`);
// console.log(req.body);
    // console.log(getDB());
    next();
};

module.exports={logger};