const {MongoClient}=require('mongodb');
require('dotenv').config();

var url = process.env.MONGO_URI;

// const client = mongodb.MongoClient(url);
var db =null;
// var dbName = "test1";
var dbName = "btrack";


var connect=async(cb)=> {
    if(db!=null){
       cb();
    }
    else{
        const client= await MongoClient.connect(url,async(err,client)=>{
            if(err) cb(err);

            db= await client.db(dbName);
            // console.log(db);
            cb();
        });
      

    }
}

var getDB=()=>db;

module.exports={getDB,connect};