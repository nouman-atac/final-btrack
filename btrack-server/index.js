const { json } = require('express');
const express=require('express');
const upload=require('multer');
const {getDB,connect}= require('./db/mongo.js');
const {removeElements, generatePassword,sendPassword}=require('./modules/useful_functions.js');
const {logger}= require('./modules/logger.js');
const {v4:uuidv4} = require('uuid');
const cors = require('cors');
const bodyParser = require('body-parser');
const bb= require('express-busboy');
const { options } = require('nodemon/lib/config');
const res = require('express/lib/response');

const session = require('express-session');
const {createClient} = require('redis');
let RedisStore = require('connect-redis')(session);

const admin=require('./routes/admin.js');
const driver=require('./routes/driver.js');
const user=require('./routes/user.js');





var app=express();
require('dotenv').config();

// bb.extend(app);
app.use(express.json());
app.use(bodyParser.json());
app.use(cors());
app.use(logger);

app.use("/admin",admin.router);
app.use("/driver",driver.router);
app.use("/user",user.router);

// redis@v4

// let redisClient = createClient({legacyMode : true})
// redisClient.connect().catch(console.error)


app.use(session({ secret: 'keyboard cat', 
    resave: false,
    saveUninitialized:false,
    genid:(req)=>{
        return uuidv4();
    },
    cookie: { maxAge: 60000 }}))

// Access the session as req.session
app.get('/session', function(req, res, next) {
  if (req.session.view) {
    req.session.view++
    res.setHeader('Content-Type', 'text/html')
    res.write('<p>view: ' + req.session.view + '</p>')
    res.write('<p>expires in: ' + (req.session.cookie.maxAge / 1000) + 's</p>')
    res.end()
  } else {
    req.session.view = 1
    res.end('welcome to the session demo. refresh!')
  }
})


app.get("/",async(req,res)=>{
    console.log(typeof(["abc","bcd"]));
    // console.log(req);
    password=await generatePassword();
    res.json({"obj":password,"mail":await sendPassword("Ismail","ismail@gmail.com",password.password)});
});
app.post("/",(req,res)=>{
    console.log(req.body)

    res.status(200).send("done");

});

app.get("/sendMail",(req,res)=>{
    sendPassword("Nouman","noumankhwaja2@gmail.com","abcdefgh");
    res.json({"msg":"Check Email"});
});

app.get("/checkSession",(req,res)=>{
    // if(!req.session.view) req.session.view=0;
    console.log("")
    req.session.view++;
    res.json({"msg":"Session is Set","view":req.session.view,"id":req.session.id,"name":req.query.name});
});

app.get("/getSession",(req,res)=>{
    var obj;
    console.log(req.session.name);
    res.json({"msg":"Session is Set","session":req.session.name});
});





app.get("/checkDB",async(req,res)=>{
    var data = await getDB().collection("drivers").find({});
    // console.log(data);
    newdata=removeElements(data,["_id"]);
    // console.log(data);
    res.json({"new":newdata});
});


var port=process.env.PORT||5001;
connect((err)=>{
    if(err){
        console.log("Unable to connect to database");
        process.exit(1);
    }
    else{
        app.listen(port,()=>{console.log(`B-Track Server started at port ${port}`)});
    }
});

