

const {v4:uuidv4}=require('uuid');
const {generatePassword}=require("../modules/useful_functions");
const bcrypt = require('bcrypt');


function driverData(data){

    var drivers={
        "driverId":("driverId" in data)?data['driverId']:`d${uuidv4()}`,
        "firstName":data['firstName'],
        "lastName":data['lastName'],
        "driverEmail":data['driverEmail'],
        "driverMobile":data['driverMobile'],
        "password":(data['password'])?data['password']:"",
        "dateOfBirth":data['dateOfBirth'],
        "driverLicenseNumber":data['driverLicenseNumber'],
        "driverImage":data['driverImage'],
        // "driverImage":{name:data["driverImage"]['imageName'],bytes:data['driverImage']['imageBytes']},
        "landmark":data['landmark'],
        "address":data['address'],
        "country":data['country'],
        "state":data['state'],
        "city":data['city'],
        "pincode":data['pincode'],
        "lastLogin":null,
        "currentStatus":null,
        "currentBusId":null,
        "currentRoute":null,
    
    }
    return drivers;
    
}

function busData(data){
    var buses={
        "busId":("busId" in data)?data['busId']:`b${uuidv4()}`,
        "busRegistrationNumber":data['busRegistrationNumber'].toUpperCase(),
        "currentLocation":null,
        "currentRoute":null,
        
    };
    return buses;
}


function busStopData(data){
    var busStops={
        "busStopId":("busStopId" in data)?data['busStopId']:`s${uuidv4()}`,
        "busStopName":data['busStopName'],
        "address":data['address'],
        "landmark":data['landmark'],
        "country":data['country'],
        "state":data['state'],
        "city":data['city'],
        "pincode":data['pincode'],
        "coordinates":{"latitude":data.coordinates.latitude,"longitude":data.coordinates.longitude},
        "routeNumbers":[],
        
        
    };
    return busStops;
}

function busRouteData(data){
    var busRoutes={
        "busRouteNumber":data['busRouteNumber'],
        "busStopIds":data['busStopIds'],
        "numberOfStops":data["numberOfStops"],
        "routeGeometry":data['routeGeometry'],
        
       
    };
    return busRoutes;
}

function realtimeLocation(data){
    var realtime={
        busId:data['busId'],
        driverId:data['driverId'],
        currentLocation:{
            latitude:data['currentLocation']['latitude'],
            longitude:data['currentLocation']['longitude'],
        },
        busStops:[
            // {busStopId:"",location:{latitude:0.0,longitude:0.0},reachedStatus:false,timeRequired:0,distanceRequired:0}
        ],
        numberOfStopsReached:0
    };
    return realtime;
}


async function userData(data){
    return bcrypt.hash(data.password,10).then((hash)=>{
        var user={
            userId:data.userId!=undefined?data['userId']:"u"+uuidv4(),
            userName:data.userName,
            userEmail:data.userEmail,
            password:hash,
            gender:data.gender,
            favouriteRoutes:{}
        };
        return user;
    })
    
}



module.exports={driverData,busData,busStopData,busRouteData,realtimeLocation,userData};