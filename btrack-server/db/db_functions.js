const {getDB,connect}= require('./mongo.js');


function getBusStatus(regNo){
    return getDB().collection('buses').findOne({"busRegistrationNumber":regNo.toUpperCase()}).then((result)=>{
        return result;
    });
}


module.exports={getBusStatus};