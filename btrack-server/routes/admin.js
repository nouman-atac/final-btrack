const express=require('express');
const {body, validationResult}=require('express-validator');
const {logger}= require('../modules/logger.js');
const {driverData,busData,busStopData,busRouteData}= require('../db/models.js');
const {getDB}= require('../db/mongo.js');
const bodyParser=require('body-parser');


const cors=require("cors");
const upload = require('multer');
const bb=require('express-busboy');
const { BSONRegExp } = require('mongodb');
const { min } = require('moment');
const { options } = require('nodemon/lib/config');
const { generatePassword, sendPassword, removeElements, sendUpdateEmail } = require('../modules/useful_functions.js');
const { query } = require('express');
const { get } = require('express/lib/request');


const router=express.Router();

bb.extend(router);

router.use(cors());
router.use(logger);
router.use(express.json());
router.use(express.raw());
// router.use(express.urlencoded());

// router.use(bodyParser.json());
// router.use(upload);

// router.get("/api/addDriver",async(req,res)=>{
//     try{
//         await getDB().collection("drivers").insertOne({"email":`${Date.now()}`});
//        // console.log(getDB());
//        // getDB().collection("cars").insertOne(req.body);
   
//    }
//    catch(e){
//        console(e);
//    }
//     res.json({"admin":"connected"});
// });

router.post("/api/addDriver",
            body('firstName').trim().notEmpty(),
            body('lastName').trim().notEmpty(),
            body('driverEmail',"Please type a proper Email").trim().notEmpty().isEmail().custom( (value)=>{
                // var result= await getDB().collection('drivers').findOne({'driverEmail':value});
                // if(result!=null)
                //     return Promise.reject("Email is already used by a user.")
                return getDB().collection('drivers').findOne({'driverEmail':value}).then(result=>{
                    if(result!=null){
                        return Promise.reject("Email is already in user")
                    }
                })
            }),
            body('driverMobile',"Please enter a proper 10 digit Mobile Number").trim().notEmpty().isNumeric().isMobilePhone("en-IN").custom(async (value)=>{
                var result= await getDB().collection('drivers').findOne({'driverMobile':value});
                if(result!=null)
                    return Promise.reject('Mobile number is already used by a user');
                    // throw new Error('Mobile number is already used by a user');
            }),
            body('dateOfBirth').trim().notEmpty(),
            body('driverLicenseNumber','Please Enter Proper Driving License Number').trim().notEmpty().custom(async (value)=>{
                var result= await getDB().collection('drivers').findOne({'driverLicenseNumber':value});
                if(result!=null)
                    return Promise.reject('Driving License number is already used by a user');
                    // throw new Error('Mobile number is already used by a user');
            }),
            body('address').trim().notEmpty(),
            body('landmark').trim().notEmpty(),
            body('country').trim().notEmpty(),
            body('state').trim().notEmpty(),
            body('city').trim().notEmpty(),
            body('pincode','Please Enter Correct Pincode').trim().notEmpty().isLength({min:6,max:6}).matches(/\d{6}/),
            // body('driverImage').custom((value,{req})=>{
            //     var bytes=req.body.driverImage.imageBytes;
            //     // console.log(bytes);
            //     bytes=bytes.split(',');
            //     console.log(bytes);
            //     for(var byte in bytes){
            //         if(isNaN(byte))
            //         return Promise.reject('Image uploaded is not a proper image');
            //     }
            // }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            // else{
            var driverInfo;
            try{
                 driverInfo= driverData(req.body);

            
            }
            catch(e){
                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
            var newPassword=await generatePassword();
            driverInfo['password']= newPassword.encryptedPassword;
            driverInfo['createdBy']= "admin";
            driverInfo["createdOn"]=Date.now();
            result= await getDB().collection('drivers').insertOne(driverInfo);
            if(result){
            info=sendPassword(driverInfo.firstName+" "+driverInfo.lastName,driverInfo.driverEmail,newPassword.password);
            res.status(200).json({result,"status":1,"msg":"Driver Data Inserted Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error"});
            }
        
        
          
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({result,"status":1});
});

router.post("/api/updateDriver",
            body('firstName').trim().notEmpty(),
            body('lastName').trim().notEmpty(),
            body('driverEmail',"Please type a proper Email").trim().notEmpty().isEmail().custom( (value)=>{
                // var result= await getDB().collection('drivers').findOne({'driverEmail':value});
                // if(result!=null)
                //     return Promise.reject("Email is already used by a user.")
                return getDB().collection('drivers').count({'driverEmail':value}).then(result=>{
                    if(result!=1){
                        return Promise.reject("Email is not in use!")
                    }
                })
            }),
            body('driverMobile',"Please enter a proper 10 digit Mobile Number").trim().notEmpty().isNumeric().isMobilePhone("en-IN").custom(async (value)=>{
                var result= await getDB().collection('drivers').count({'driverMobile':value});
                if(result!=1)
                    return Promise.reject('No such mobile number in use!');
                    // throw new Error('Mobile number is already used by a user');
            }),
            body('dateOfBirth').trim().notEmpty(),
            body('driverLicenseNumber','Please Enter Proper Driving License Number').trim().notEmpty(),
                    // throw new Error('Mobile number is already used by a user');
           
            body('address').trim().notEmpty(),
            body('landmark').trim().notEmpty(),
            body('country').trim().notEmpty(),
            body('state').trim().notEmpty(),
            body('city').trim().notEmpty(),
            body('pincode','Please Enter Correct Pincode').trim().notEmpty().isLength({min:6,max:6}).matches(/\d{6}/),
            // body('driverImage').custom((value,{req})=>{
            //     var bytes=req.body.driverImage.imageBytes;
            //     // console.log(bytes);
            //     bytes=bytes.split(',');
            //     console.log(bytes);
            //     for(var byte in bytes){
            //         if(isNaN(byte))
            //         return Promise.reject('Image uploaded is not a proper image');
            //     }
            // }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            // else{
            var driverInfo;
            try{
                 driverInfo= driverData(req.body);

            
            }
            catch(e){
                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
            driverInfo['lastUpdatedBy']="admin";
            driverInfo['lastUpdatedOn']=Date.now();
            result= await getDB().collection('drivers').updateOne({"driverId":driverInfo['driverId']},{$set:driverInfo});
            if(result){
            info=sendUpdateEmail(driverInfo.firstName+" "+driverInfo.lastName,driverInfo.driverEmail);
            res.status(200).json({result,"status":1,"msg":"Driver Data Updated Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error"});
            }
        
        
          
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({result,"status":1});
});

router.get('/api/getDrivers',async(req,res)=>{
    try{
        result = await getDB().collection('drivers').find({},{"driverImage":0}).toArray();
        console.log(result.length);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});

router.get('/api/getDriver',async(req,res)=>{
    try{   
        console.log(req.query.id);
        result = await getDB().collection('drivers').findOne({"driverId":{$eq:req.query.id}});
        // newRes=removeElements(result,"driverImage");
        // console.log(newRes);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});


router.delete('/api/deleteDriver',async(req,res)=>{
    try{   
        console.log(req.query.id);
        result = await getDB().collection('drivers').deleteOne({"driverId":{$eq:req.query.id}});
        // newRes=removeElements(result,"driverImage");
        // console.log(newRes);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});



router.post("/api/addBus",
            body('busRegistrationNumber').trim().notEmpty().matches(/\D{2}[0-9]{2}[A-Z]{2}[0-9]{4}/),
            body('busRegistrationNumber',"Bus is Already Registered").custom( (value)=>{
                // var result= await getDB().collection('drivers').findOne({'driverEmail':value});
                // if(result!=null)
                //     return Promise.reject("Email is already used by a user.")
                return getDB().collection('buses').findOne({'busRegistrationNumber':value}).then(result=>{
                    if(result!=null||result=={}){
                        return Promise.reject("Bus is Already Registered");
                    }
                })
            }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                console.log(req.body);
                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            // else{
            var busInfo;
            try{
                // console.log(req.body);
                 busInfo= busData(req.body);

            
            }
            catch(e){
                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
           
            busInfo['createdBy']="admin";
            busInfo['createdOn']=Date.now();
            result= await getDB().collection('buses').insertOne(busInfo);
            if(result){
            
            res.status(200).json({result,"status":1,"msg":"Bus Stop Data Inserted Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error"});
            }
        
        
          
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({result,"status":1});
});

router.post("/api/updateBus",
            body('busRegistrationNumber').trim().notEmpty().matches(/[^'"%/]/).matches(/\D{2}[0-9]{2}[A-Z]{2}[0-9]{4}/),
            body('busRegistrationNumber',"Bus is Already Registered").custom( (value)=>{
                // var result= await getDB().collection('drivers').findOne({'driverEmail':value});
                // if(result!=null)
                //     return Promise.reject("Email is already used by a user.")
                return getDB().collection('buses').count({'busRegistrationNumber':value}).then(result=>{
                    if(result!=1){
                        return Promise.reject("The bus being updated does not exists in the system");
                    }
                })
            }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            // else{
            var busInfo;
            try{
                // console.log(req.body);
                 busInfo= busData(req.body);

            
            }
            catch(e){
                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
           
            busInfo['lastUpdatedBy']="admin";
            busInfo['lastUpdatedOn']=Date.now();
            result= await getDB().collection('buses').updateOne({"busId":{$eq:busInfo['busId']}},{$set:busInfo});
            if(result){
            
            res.status(200).json({result,"status":1,"msg":"Bus Stop Data Updated Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error"});
            }
        
        
          
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({result,"status":1});
});

router.get('/api/getBuses',async(req,res)=>{
    try{
        result = await getDB().collection('buses').find({}).toArray();

        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});

router.get('/api/getBus',async(req,res)=>{
    try{   
        console.log(req.query.id);
        result = await getDB().collection('buses').findOne({"busId":{$eq:req.query.id}});
        // newRes=removeElements(result,"driverImage");
        // console.log(newRes);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});


router.delete('/api/deleteBus',async(req,res)=>{
    try{   
        console.log(req.query.id);
        result = await getDB().collection('buses').deleteOne({"busId":{$eq:req.query.id}});
        // newRes=removeElements(result,"driverImage");
        // console.log(newRes);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});



// Bus Stops

router.post("/api/addBusStop",
            body('busStopName').trim().notEmpty(),
            
            body('address').trim().notEmpty(),
            body('landmark').trim().notEmpty(),
            body('country').trim().notEmpty(),
            body('state').trim().notEmpty(),
            body('city').trim().notEmpty(),
            body('pincode','Please Enter Correct Pincode').trim().notEmpty().isLength({min:6,max:6}).matches(/\d{6}/),
            // body('coordinates','Please Provide Proper Bus Stop Coordinated').custom((value,{req})=>{

            //     console.log( (isNaN(parseFloat(req.body.coordinates['lattitude'])) || isNaN(parseFloat(req.body.coordinates['longitude'])))!==false );
            //     console.log(value); 

            //     if( isNaN(parseFloat(value['lattitude'])) || isNaN(parseFloat(value['longitude']))===true ){

            //         // return Promise.reject("Please Provide Proper Bus Stop Coordinated");
            //         throw new Error('Please Provide Proper Bus Stop Coordinated');
            //     }
            // }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                console.log(req.body);
                console.log(isNaN(parseFloat(req.body.coordinates['lattitude'])));
                    console.log(isNaN(parseFloat(req.body.coordinates['longitude'])));
                console.log( isNaN(parseFloat(req.body.coordinates['lattitude'])) || isNaN(parseFloat(req.body.coordinates['longitude'])) );


                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            // else{
            var busStopInfo;
            try{
                busStopInfo= busStopData(req.body);

            
            }
            catch(e){
                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
            busStopInfo['createdBy']="admin";
            busStopInfo['createdOn']=Date.now();
            result= await getDB().collection('bus_stops').insertOne(busStopInfo);
            if(result){
            res.status(200).json({result,"status":1,"msg":"Bus Stop Data Inserted Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error"});
            }
        
        
          
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({result,"status":1});
});

router.post("/api/updateBusStop",
            body('busStopId').trim().notEmpty().custom((value)=>{
                return getDB().collection('bus_stops').count({'busStopId':value}).then(result=>{
                    if(result!=1){
                        return Promise.reject("The bus stop being updated does not exists in the system");
                    }
                })
            }),
            body('busStopName').trim().notEmpty(),
            
            body('address').trim().notEmpty(),
            body('landmark').trim().notEmpty(),
            body('country').trim().notEmpty(),
            body('state').trim().notEmpty(),
            body('city').trim().notEmpty(),
            body('pincode','Please Enter Correct Pincode').trim().notEmpty().isLength({min:6,max:6}).matches(/\d{6}/),
            // body('coordinates','Please Provide Proper Bus Stop Coordinated').custom((value,{req})=>{

            //     console.log( (isNaN(parseFloat(req.body.coordinates['lattitude'])) || isNaN(parseFloat(req.body.coordinates['longitude'])))!==false );
            //     console.log(value); 

            //     if( isNaN(parseFloat(value['lattitude'])) || isNaN(parseFloat(value['longitude']))===true ){

            //         // return Promise.reject("Please Provide Proper Bus Stop Coordinated");
            //         throw new Error('Please Provide Proper Bus Stop Coordinated');
            //     }
            // }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                console.log(req.body);
                console.log(isNaN(parseFloat(req.body.coordinates['lattitude'])));
                    console.log(isNaN(parseFloat(req.body.coordinates['longitude'])));
                console.log( isNaN(parseFloat(req.body.coordinates['lattitude'])) || isNaN(parseFloat(req.body.coordinates['longitude'])) );


                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            // else{
            var busStopInfo;
            try{
                busStopInfo= busStopData(req.body);

            
            }
            catch(e){

                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
            busStopInfo['lastUpdatedBy']="admin";
            busStopInfo['lastUpdatedOn']=Date.now();
            result= await getDB().collection('bus_stops').updateOne({"busStopId":busStopInfo['busStopId']},{$set:busStopInfo});
            if(result){
            res.status(200).json({result,"status":1,"msg":"Bus Stop Data Updated Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error"});
            }
        
        
          
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({result,"status":1});
});


router.get('/api/getBusStops',async(req,res)=>{
    try{
        result = await getDB().collection('bus_stops').find({}).toArray();
        // console.log(result);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});

router.get('/api/getBusStop',async(req,res)=>{
    try{   
        console.log(req.query.id);
        result = await getDB().collection('bus_stops').findOne({"busStopId":{$eq:req.query.id}});
        // newRes=removeElements(result,"driverImage");
        // console.log(newRes);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});


router.delete('/api/deleteBusStop',async(req,res)=>{
    try{   
        console.log(req.query.id);
        
        result1 = await getDB().collection('bus_routes').aggregate([{$match:{"busStopId":req.query.id}},{$project: { "count": { $size:"$routeNumbers" }}}]);
        if(result['count']==0){
            result= await getDB().collection('bus_stops').updateMany({},{$pull:{"routeNumbers":req.query.number}});

        // newRes=removeElements(result,"driverImage");
        console.log(result);
        res.status(200).json({"status":1,"data":result});
        }
        else
        res.status(200).json({"status":0,"msg":"Please edit or delete all the routes that pass through to the bus stop to be deleted"});
        
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    //  .then((result)=>{
        
    //         res.status(200).json({"status":1,"data":result});
    //  })
    //  .catch((err)=>{
    //      res.status(200).json({"status":0,"msg":"An error has occurred"});
    //     });
});

router.post("/api/addBusRoute",
            body('busRouteNumber',"Route Number is Already in use.").trim().notEmpty().isNumeric().custom(async(value)=>{
                await getDB().collection("bus_routes").count({"busRouteNumber":value}).then((count)=>{
                    console.log("Entered:"+count);
                    if(count!=0) return  Promise.reject("Route Number is Already in use.");
                }).catch((e)=>{
                 return  Promise.reject("Route Number is Already in use.");
                });
            }),
            
            body('numberOfStops').trim().notEmpty().isNumeric(),
            body('busStopIds').custom(async(ids)=>{
                var newIds=Array.from(new Set(ids));
                // var newIds=ids;
               await getDB().collection('bus_stops').count({"busStopId":{$exists:true,$in:newIds}}).then((count)=>{
                   if(count!=newIds.length) return  Promise.reject("Some of the bus stops selected do not exists in the system");
               }).catch((e)=>{
                return  Promise.reject("Some of the bus stops selected do not exists in the system");
               });
                
                
            }),
            body('routeGeometry').notEmpty(),
            
            // body('coordinates','Please Provide Proper Bus Stop Coordinated').custom((value,{req})=>{

            //     console.log( (isNaN(parseFloat(req.body.coordinates['lattitude'])) || isNaN(parseFloat(req.body.coordinates['longitude'])))!==false );
            //     console.log(value); 

            //     if( isNaN(parseFloat(value['lattitude'])) || isNaN(parseFloat(value['longitude']))===true ){

            //         // return Promise.reject("Please Provide Proper Bus Stop Coordinated");
            //         throw new Error('Please Provide Proper Bus Stop Coordinated');
            //     }
            // }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                console.log(req.body);
                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            else{
            var busRouteInfo;
            try{
                busRouteInfo= busRouteData(req.body);

            
            }
            catch(e){
                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
            busRouteInfo['createdBy']="admin";
            busRouteInfo['createdOn']=Date.now();
            result= await getDB().collection('bus_routes').insertOne(busRouteInfo);
            result2= await getDB().collection('bus_stops').updateMany({'busStopId':{$in:[...busRouteInfo['busStopIds']]}},{$push:{"routeNumbers":busRouteInfo['busRouteNumber']}});
            if(result){
            res.status(200).json({result,"status":1,"msg":"Bus Stop Data Inserted Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error"});
            }
        
        
        }
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({"status":1});
});


router.post("/api/updateBusRoute",
            body('busRouteNumber',"Route Number is Already in use.").trim().notEmpty().isNumeric().custom(async(value)=>{
                await getDB().collection("bus_routes").count({"busRouteNumber":value}).then((count)=>{
                    console.log("Entered:"+count);
                    if(count!=1) return  Promise.reject("Route Number being updated does not exists in the system");
                }).catch((e)=>{
                 return  Promise.reject("Route Number being updated does not exists in the system");
                });
            }),
            
            body('numberOfStops').trim().notEmpty().isNumeric(),
            body('busStopIds').custom(async(ids)=>{
                var newIds=Array.from(new Set(ids));
                // var newIds=ids;
               await getDB().collection('bus_stops').count({"busStopId":{$exists:true,$in:newIds}}).then((count)=>{
                   if(count!=newIds.length) return  Promise.reject("Some of the bus stops selected do not exists in the system");
               }).catch((e)=>{
                return  Promise.reject("Some of the bus stops selected do not exists in the system");
               });
                
                
            }),
            body('routeGeometry').notEmpty(),
            
            // body('coordinates','Please Provide Proper Bus Stop Coordinated').custom((value,{req})=>{

            //     console.log( (isNaN(parseFloat(req.body.coordinates['lattitude'])) || isNaN(parseFloat(req.body.coordinates['longitude'])))!==false );
            //     console.log(value); 

            //     if( isNaN(parseFloat(value['lattitude'])) || isNaN(parseFloat(value['longitude']))===true ){

            //         // return Promise.reject("Please Provide Proper Bus Stop Coordinated");
            //         throw new Error('Please Provide Proper Bus Stop Coordinated');
            //     }
            // }),
            async (req,res)=>{

                var errors=validationResult(req);
                if(!errors.isEmpty()){
                console.log(errors);
                console.log(req.body);
                res.json({"errors":errors.errors[0].msg,"status":0});
                }
            else{
            var busRouteInfo;
            try{
                busRouteInfo= busRouteData(req.body);

            
            }
            catch(e){
                res.json({"status":2,"msg":"The request is not valid"});
            }

        try{
        if(errors.isEmpty()){
            busRouteInfo['lastUpdatedBy']="admin";
            busRouteInfo['lastUpdatedOn']=Date.now();
            result= await getDB().collection('bus_routes').updateOne({"busRouteNumber":busRouteInfo['busRouteNumber']},{$set:busRouteInfo});
            console.log(req.body['oldBusStopIds']);
            result1= await getDB().collection('bus_stops').updateMany({'busStopId':{$in:[...req.body['oldBusStopIds']]}},{$pull:{"routeNumbers":busRouteInfo['busRouteNumber']}});
            result2= await getDB().collection('bus_stops').updateMany({'busStopId':{$in:[...busRouteInfo['busStopIds']]}},{$push:{"routeNumbers":busRouteInfo['busRouteNumber']}});

            if(result){
            res.status(200).json({result,"status":1,"msg":"Bus Stop Data Updated Successfully."});
            }
            else{
                res.json({"status":2,"msg":"Inserting Error: Please contact the website administrators!"});
            }
            // console.log(result);
        }
        
        
        }catch(e){
            
                res.json({"status":2,"msg":"Database Error "+e});
            }
        
        
        }
        // result =  await getDB().collection("drivers").insertOne(driverData(req.body));

    // res.status(200).json({"status":1});
});

router.get('/api/getBusRoutes',async(req,res)=>{
    try{
        result = await getDB().collection("bus_routes").aggregate(
            [
                {
                "$lookup":{
                    "from":"bus_stops",
                    "localField":"busStopIds",
                    "foreignField":"busStopId",
                    // "let":[]
                    // "pipeline":[],
                    "as":"stops"
                }
            
            }
            ]
            ).toArray();
        // console.log(result);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        res.status(200).json({"status":0,"msg":"An error has occurred"+err});
    }
   
});

router.get('/api/getBusRoute',async(req,res)=>{
    try{   
        console.log(req.query.number);
        result = await getDB().collection('bus_routes').findOne({"busRouteNumber":{$eq:req.query.number}});
        // newRes=removeElements(result,"driverImage");
        // console.log(newRes);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
    
});


router.delete('/api/deleteBusRoute',async(req,res)=>{
    try{   
        console.log(req.query.number);
        result = await getDB().collection('bus_routes').deleteOne({"busRouteNumber":{$eq:req.query.number}});
        result1= await getDB().collection('bus_stops').updateMany({},{$pull:{"routeNumbers":req.query.number}});

        // newRes=removeElements(result,"driverImage");
        console.log(result);
        res.status(200).json({"status":1,"data":result});
        
    }
    catch(err){
        console.log(err);
        res.status(200).json({"status":0,"msg":"An error has occurred"});
    }
});





module.exports={router};