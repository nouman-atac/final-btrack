const express=require('express');
const {body, validationResult}=require('express-validator');
const {logger}= require('../modules/logger.js');
const {getDB}= require('../db/mongo.js');
const {getBusStatus} = require("../db/db_functions.js");
const session=require('express-session');
const {v4:uuidv4} = require('uuid');
const bcrypt = require('bcrypt');
const axios = require('axios');

const cors=require("cors");
const upload = require('multer');
const bb=require('express-busboy');
const { BSONRegExp } = require('mongodb');
const { generatePassword, sendPassword, removeElements, sendUpdateEmail } = require('../modules/useful_functions.js');
const {busRouteData,userData}= require('../db/models.js');



const router=express.Router();

bb.extend(router);

router.use(cors());
router.use(logger);
router.use(express.json());
router.use(express.raw());
router.use(session({ secret: 'keyboard cat', 
    resave: false,
    saveUninitialized:false,
    genid:(req)=>{
        return uuidv4();
    },
    cookie: { maxAge: 86400*365 }}
    )
);

// router.use("/api",(req,res,next)=>{
//     try{
//         console.log(req.session);
//         if(req.session.authenticated){
//             next();
//         }
//         else{
//             res.status(200).json({"status":-1,"msg":"Please Login First"});
//         }
//     }
//     catch(e){
//         res.status(200).json({"status":-1,"msg":"Please Login First error"});
//     }
    
// });

router.post("/register",
    body('userEmail',"Invalid user email").trim().notEmpty().isEmail().custom((value)=>{
        
        return getDB().collection('users').count({"userEmail":value}).then((count)=>{
            console.log(count);
            if(count!=0){
                return Promise.reject("User Already exists");
            }
        })    
    }),
    body('userName').trim().notEmpty().isString().matches(/[a-zA-z ]+/),
    body('password').trim().notEmpty().matches(/[a-zA-Z0-9^&*`@#$+-=/!]{8,}/),
    body('mobile').trim().notEmpty().isNumeric().matches(/[0-9]{10}/),
    // body('confirmPassword',"Incorrect Confirm password").trim().notEmpty().custom((val,{req})=>{
    //     // console.log(req.body);
    //     if(req.body.password!==val)
    //     {
    //         throw new Error("Passwords do not match")
    //     }
    //     return true;
    // }),
    (req,res)=>{
    var errors=validationResult(req);
    if(errors.isEmpty()){
        console.log(req.body);
        userData(req.body).then((user)=>{
            getDB().collection("users").insertOne(user).then((result)=>{
                console.log(result);
                res.status(200).json({"status":1,"msg":"Registeration Successful"});
            }).catch(e=>{
                res.status(200).json({"status":0,"msg":"DB Error"+e});
            })
        }).catch(e=>{
            res.status(200).json({"status":0,"msg":"Transformation Error"+e});
        });
    }
    else{
       
        res.status(200).json({"status":0,"msg":errors.errors[0].msg,errors});
        
    }
    
    

});

router.post("/login",
    body('userEmail').trim().notEmpty().isEmail().custom((val)=>{
        return getDB().collection("users").count({"userEmail":val}).then((count)=>{
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

        getDB().collection("users").findOne({"userEmail":req.body.userEmail}).then((result)=>{
            bcrypt.compare(req.body.password,result['password']).then((auth)=>{
                if(auth==true){
                    req.session.authenticated=true;
                    req.session.userId=result['userId'];
        
                    res.status(200).json({"authenticated":true,"msg":"Login Successfull"});
                }
                   else{
                    res.status(200).json({"authenticated":false,"msg":"Incorrect Password"});
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


// router.get("/api/getUser",(req,res)=>{
//     getDB().collection("users").findOne({"userId":req.session.userId},{"userName":1,"userEmail":1,"gender":1}).then((result)=>{
//         console.log(result);
//         res.status(200).json({"status":1,data:result});

//     }).catch((e)=>{
//         res.status(200).json({"status":0,"msg":"DB Error "+e});
//     });

// });

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
            getDB().collection('users').updateOne({"userId":req.session.userId},{$set:{"password":hash}}).then((result)=>{
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

router.post('/api/getRunningRoutes',(req,res)=>{

    getDB().collection('realtime_location').find({"busRouteNumber":parseInt(req.body.busRouteNumber)}
        ,{"busesRunning.currentLocation":1,"busesRunning.busStops":1,"busesRunning.busRegistrationNumber":1,"busesRunning.journeyId":1,"busRouteNumber":1,"_id":0}).toArray()
            .then((result)=>{
                res.status(200).json({"status":1,"msg":"Data Fetched","data":result});

        }).catch(e=>{
            res.status(200).json({"status":0,"msg":"DB Find Error"+e});
        })
        
});

router.post("/api/getRouteDetails",(req,res)=>{
    getDB().collection('bus_routes').aggregate([
        {$match:{"busRouteNumber":`${req.body.busRouteNumber}`}},
        {
            $lookup:{
                
                "from":"bus_stops",
                "localField":"busStopIds",
                "foreignField":"busStopId",
                // "pipeline":[],
                // "let":[]
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


router.post("/api/getJourney",(req,res)=>{
    getDB().collection('realtime_location').findOne({"busRouteNumber":parseInt(req.body.busRouteNumber)},{"busesRunning":{$elemMatch:{"journeyId" : req.body.journeyId}}}).then((result)=>{
        res.json({"status":1,msg:`Journey data fetched`,"data":result});
    }).catch(e=>{
        res.json({"status":0,msg:`Journey Finding Error 1`+e});
    })

})




module.exports={router};