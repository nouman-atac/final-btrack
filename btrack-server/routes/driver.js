const express=require('express');
const {body, validationResult}=require('express-validator');
const {logger}= require('../modules/logger.js');
const {getDB}= require('../db/mongo.js');
const {getBusStatus} = require("../db/db_functions.js");
const session=require('express-session');
const {v4:uuidv4} = require('uuid');
const bcrypt = require('bcrypt');
const axios = require('axios');
const MongoStore = require('connect-mongo');

const cors=require("cors");
const upload = require('multer');
const bb=require('express-busboy');
const { BSONRegExp } = require('mongodb');
const { generatePassword, sendPassword, removeElements, sendUpdateEmail, getDistanceFromBusStop,createBusStopFormat} = require('../modules/useful_functions.js');
const req = require('express/lib/request');


const router=express.Router();

bb.extend(router);

router.use(cors());
router.use(logger);
router.use(express.json());
router.use(express.raw());
router.use(session({ secret: 'keyboard cat', 
    resave: false,
    saveUninitialized:false,
    store: MongoStore.create({ mongoUrl: process.env.MONGO_URI }),
    genid:(req)=>{
        return uuidv4();
    },
    cookie: { maxAge: 6000000}}
    )
);
router.use("/api",(req,res,next)=>{
    try{
        console.log(req.session);
        if(req.session.authenticated){
            next();
        }
        else{
            res.status(200).json({"status":-1,"msg":"Please Login First"});
        }
    }
    catch(e){
        res.status(200).json({"status":-1,"msg":"Please Login First error"});
    }
    
});

router.post("/login",
    body('driverEmail').trim().notEmpty().isEmail().custom((val)=>{
        return getDB().collection("drivers").count({"driverEmail":val}).then((count)=>{
            if(count!=1){
                return Promise.reject("No Such User exists");
            }
        }).catch((e)=>{
            console.log(e)
            return Promise.reject(e);
        })
    }),
    body('password').trim().notEmpty().matches(/[a-zA-Z0-9^&*`@#$+-=/!]{8,}/),    
    (req,res)=>{
    var errors=validationResult(req);
    if(errors.isEmpty()){

        getDB().collection("drivers").findOne({"driverEmail":req.body.driverEmail}).then((result)=>{
            bcrypt.compare(req.body.password,result['password']).then((auth)=>{
                if(auth==true){
                    req.session.authenticated=true;
                    req.session.driverId=result['driverId'];
                    req.session.driverEmail=result['driverEmail'];
                    req.session.driverName=result['firstName']+" "+result['lastName'];
                    res.status(200).json({"authenticated":true,"session":req.session.id});
                }
                   else{
                    res.status(200).json({"authenticated":false,"msg":"Incorrect Password"});
                    // req.session.destroy();
                }
        
            }).catch((e)=>{
                res.status(200).json({"authenticated":false,"msg":"Password Match Error"+e});
            });
        }).catch((e)=>{
            res.status(200).json({"authenticated":false,"msg":"DB Error "+e});
        });

        
    }
    else{
        console.log(errors.length)
        res.status(200).json({"authenticated":false,"msg":"Incorrect Format of Email Or Password",errors});
    }
    
});

router.post("/api/changePassword",
    body('password').trim().notEmpty().matches(/[a-zA-Z0-9^&*`@#$+-=/!]{8,}/),
    body('confirmPassword',"Incorrect Confirm password").trim().notEmpty().custom((val,{req})=>{
        console.log(req.body);
        if(req.body.password!==val)
        {
            throw new Error("Passwords do not match")
        }
        return true;
    }),    
    (req,res)=>{
    var errors=validationResult(req);
    if(errors.isEmpty()){

        bcrypt.hash(req.body.password,10).then((hash)=>{
            getDB().collection('drivers').updateOne({"driverEmail":req.session.driverEmail},{$set:{"password":hash}}).then((result)=>{
                console.log(result);
                res.status(200).json({"status":1,"msg":"Password changed Successfully"});
            }).catch((e)=>{
                res.status(200).json({"msg":"DB Error"+e});
            })
        }).catch((e)=>{
            res.status(200).json({"msg":"Hash Creation Error"+e});
        })

        
    }
    else{
        res.status(200).json({"msg":"Incorrect Format Password",errors});
    }
    
});

router.post("/api/selectBus",
body("busRegistrationNumber").trim().notEmpty().matches(/[a-zA-Z]{2}[0-1]{2}[a-zA-Z]{2}[0-1]{4}/),
(req,res)=>{
    console.log(req.session.busId);
    if(req.session.busId!=null){
        if(req.session.busRegistrationNumber==req.body.busRegistrationNumber)
        res.status(200).json({"status":1,"msg":`Bus with number ${req.body.busRegistrationNumber} is already Selected by you`});
        else
        res.status(200).json({"status":1,"msg":`Bus with number ${req.body.busRegistrationNumber} is already Selected by you. Deselect it to get different bus`});
    }else{
        getBusStatus(req.body.busRegistrationNumber).then((result)=>{
            if(result!=null){
                if(result.status==0){
                    req.session.busId=result.busId;
                    req.session.busRegistrationNumber=result.busRegistrationNumber
                    getDB().collection('buses').updateOne({busId:result.busId},{$set:{"status":1,"currentDriverId":req.session.driverId}}).then((result)=>{
                        
                        res.status(200).json({"status":1,"msg":`Bus with number ${req.body.busRegistrationNumber} is obtained successfully`});
                    }).catch(e=>{
                        res.status(200).json({"selectStatus":0,"msg":"DB ERROR"});
                    });
                }
                else{
                    res.status(200).json({"selectStatus":0,"msg":`Bus with number ${req.body.busRegistrationNumber} is already Selected By someone else.`});  
                }
            }
            else{
                res.status(200).json({"selectStatus":0,"msg":`No bus with number ${req.body.busRegistrationNumber} exists`});
            }
        }).catch(e=>{
            res.status(200).json({"selectStatus":0,"msg":"DB ERROR"});
            
        });
    }
    
});

router.post("/api/deSelectBus",(req,res)=>{
    // req.session.
    
    if(req.session.busId!=null){
        getDB().collection('buses').updateOne({busId:req.session.busId},{$set:{"status":0,"currentDriverId":null}}).then((result)=>{
            delete req.session.busId;
            res.status(200).json({"status":1,"msg":`Bus with number is deselected successfully`});
        }).catch(e=>{
            res.status(200).json({"selectStatus":0,"msg":"DB ERROR"});
        });
    }
    else{
        res.status(200).json({"selectStatus":0,"msg":"No bus selected"});
    }
});

router.post("/api/selectRoute",(req,res)=>{
    
        req.session.busRouteNumber=req.body.busRouteNumber;
        res.json({"status":1,msg:`Bus route number ${req.session.busRouteNumber} is selected`});
    
});

router.get("/api/getRouteDetails",(req,res)=>{
    getDB().collection('bus_routes').aggregate([
        {$match:{"busRouteNumber":`${req.session.busRouteNumber}`}},
        {
            $lookup:{
                
                "from":"bus_stops",
                "localField":"busStopIds",
                "foreignField":"busStopId",
                // "let":[]
                // "pipeline":[],
                "as":"stops"
            },
            
        },
        {
            $project:{"busStopIds":1,"routeGeometry":1,"stops.busStopName":1,'stops.coordinates':1,"stops.busStopId":1,"stops.landmark":1,"stops.pincode":1}
        }
    ]).toArray().then((result)=>{
        console.log(result);
        res.status(200).json({"status":1,"msg":"Route Details successfully fetched",data:result});
    }).catch(e=>{
        res.json({"status":0,msg:`DB Error 1`});
    })
});


router.post("/api/startJourney",(req,res)=>{
    console.log(req.body)
    getDB().collection('bus_stops').findOne({busStopId:req.body.startStopId},{"coordinates":1}).then((result)=>{
        // console.log(result);
        axios.get(`https://api.mapbox.com/directions/v5/mapbox/driving/${req.body.longitude},${req.body.latitude};${result.coordinates.longitude},${result.coordinates.latitude}?language=en&overview=simplified&access_token=${process.env.mapbox_access_token}`)
        .then((value)=>{
            console.log(value.data);
            console.log(`${req.body.longitude},${req.body.latitude};${result.coordinates.longitude},${result.coordinates.latitude}`);
            if(value.data.routes[0].distance>0)
            {
                getDB().collection('bus_routes').aggregate([
                    {$match:{"busRouteNumber":`${req.session.busRouteNumber}`}},
                    {
                        $lookup:{
                            
                            "from":"bus_stops",
                            "localField":"busStopIds",
                            "foreignField":"busStopId",
                            // "let":[]
                            // "pipeline":[],
                            "as":"stops"
                        },
                        
                    },
                    {
                        $project:{"busStopIds":1,"stops.busStopName":1,'stops.coordinates':1,"stops.busStopId":1,"stops.landmark":1,"stops.pincode":1}
                    }
                ]).toArray().then((result)=>{
                    console.log(result);
                    var realtime={
                        journeyId:uuidv4(),
                        busRegistrationNumber:req.session.busRegistrationNumber,
                        driverId:req.session.driverId,
                        currentLocation:{
                            latitude:req.body.latitude,
                            longitude:req.body.longitude,
                        },
                        busStops:[
                            // {busStopId:"",location:{latitude:0.0,longitude:0.0},reachedStatus:false,timeRequired:0,distanceRequired:0}
                        ],
                        numberOfStopsReached:0
                    };
                    req.session.journeyId=realtime.journeyId;
                    // var newData=createBusStopFormat(result);

                    var busStops=createBusStopFormat(result);
                    getDistanceFromBusStop(req.body.latitude,req.body.longitude,busStops).then((stops)=>{
                    realtime.busStops=stops;
                    getDB().collection('realtime_location').findOne({"busRouteNumber":req.session.busRouteNumber},{"busesRunning":{$elemMatch:{"busId" : req.session.busId}}}).then((count)=>{
                        // console.log(realtime);
                        
                        if(count==null){
                            getDB().collection('realtime_location').updateOne({"busRouteNumber":parseInt(req.session.busRouteNumber)},{$push:{"busesRunning":realtime}}).then((doc)=>{
                                // res.status(200).json({"status":1,"msg":"Route Details successfully fetched",data:realtime});
                                res.status(200).json({status:1,msg:"Journey Started","distance":value.data.routes[0].distance,data:realtime});
                            }).catch(e=>{
                                res.status(200).json({"status":0,"msg":"DB insert Error"+e,});
                            });
                        }
                        // res.status(200).json({"status":1,msg:"Done","data":count==null?"null":count});
                        else{
                            res.status(200).json({"status":0,"msg":"Bus is already running on a route",});
                        }
                    }).catch(e=>{
                            res.status(200).json({"status":0,"msg":"DB count error"+e,data:result});
                    });
                
            })

                    
                }).catch(e=>{
                    res.json({"status":0,msg:`DB Aggregate Error 2`+e});
                    console.log(e);
                })
                
            }
            else
            res.status(200).json({status:0,msg:`The bus should be under 15 of the bus stops.Currently ${value.data.routes[0].distance} away.`,"data":{"distance":value.data.routes[0].distance}});
        }).catch(e=>{
            res.status(200).json({status:0,msg:"Matrix Error 1"})
        })
        
    }).catch(e=>{
        res.status(200).json({status:0,msg:"DB Error 1"});
    });

});

router.post("/api/updateJourney",(req,res)=>{
    if(req.session.busRouteNumber!=null){
        getDB().collection('realtime_location').findOne({"busRouteNumber":parseInt(req.session.busRouteNumber)},{"busesRunning":{$elemMatch:{"journeyId" : req.session.journeyId}},busStops:1}).then(result=>{
            // console.log(result);
            var stops=result.busesRunning[0].busStops;

            getDistanceFromBusStop(req.body.latitude,req.body.longitude,stops).then((updatedBusStops)=>{

                getDB().collection('realtime_location').updateOne({"busRouteNumber":parseInt(req.session.busRouteNumber),"busesRunning":{$elemMatch:{"journeyId":{$eq:req.session.journeyId}}}},
                    {$set:{"busesRunning.$.busStops":updatedBusStops,"busesRunning.$.currentLocation.latitude":req.body.latitude,"busesRunning.$.currentLocation.longitude":req.body.longitude}}).then(data=>{
                        console.log(updatedBusStops);
                        res.status(200).json({status:1,msg:"Updating Successfull",updatedBusStops});

                }).catch(e=>{
                    res.status(200).json({status:0,msg:"Updating Bus Stop Error 1"+e});
                })

            }).catch(e=>{
                res.status(200).json({status:0,msg:"Distance function error Error 1"+e});
            })

        }).catch(e=>{
            res.status(200).json({status:0,msg:"DB find Error 1"+e});
        })
        

    }else{
        res.status(200).json({status:-2,msg:"Bus route number not set"});
    }
});

router.post("/api/completeJourney",(req,res)=>{
    getDB().collection('realtime_location').findOne({"busRouteNumber":parseInt(req.session.busRouteNumber)},
        {"busesRunning":{$elemMatch:{"journeyId" : req.session.journeyId}},busStops:1}).then((result)=>{
            var stops=result.busesRunning[0].busStops;
            if(stops[stops.length-1].reachedStatus==true){

                getDB().collection('realtime_location').updateOne({"busRouteNumber":req.session.busRouteNumber,"busesRunning":{$elemMatch:{"journeyId":{$eq:req.session.journeyId}}}},
                    {$pull:{'busesRunning':{"journeyId":req.session.journeyId}}}).then((value)=>{
                        delete req.session.journeyId;
                        res.status(200).json({status:1,msg:"Journey Completed successfully"});
                }).catch(e=>{
                    res.status(200).json({status:0,msg:"DB remove Error 1"+e});
                })
        
            }
            else{
                res.status(200).json({status:0,msg:"Please Complete the Journey First"+e});
            }
        }).catch(e=>{
            res.status(200).json({status:0,msg:"DB find Error 1"+e})
        })
        
    
})

router.post("/api/logout",(req,res)=>{
    getDB().collection('buses').updateOne({busId:req.session.busId},{$set:{status:0,currentDriverId:null}}).then(result=>{
        if(req.session.journeyId!=null){
            console.log("here")
            getDB().collection('realtime_location').updateOne({"busRouteNumber":parseInt(req.session.busRouteNumber),"busesRunning":{$elemMatch:{"journeyId":{$eq:req.session.journeyId}}}},
            {$pull:{'busesRunning':{"journeyId":req.session.journeyId}}}).then((value)=>{
                delete req.session.journeyId;
                req.session.destroy()
            res.status(200).json({status:1,msg:"Logout Successfull"});


        }).catch(e=>{
            res.status(200).json({status:0,msg:"DB remove Error 1"+e});
        })

        }
        else{
            req.session.destroy();
            res.status(200).json({status:1,msg:"Logout Successfull 2"});
        }
    }).catch(e=>{
        res.status(200).json({status:0,msg:"DB De-select Error 1"+e})
        
    })
})

router.get("/api/getRunningBusRoute",(req,res)=>{

    res.status(200).json({"sid":req.session.id,"did":req.session.driverId});
});

router.get("/api/getDriverData",(req,res)=>{

    // getDB().collection('drivers').findOne
    res.status(200).json({"status":1,"driverName":req.session.driverName,"driverEmail":req.session.driverEmail});
});


router.get("/api/",(req,res)=>{
    res.status(200).json({status:1});
})



module.exports={router};