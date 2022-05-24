const { default: axios } = require('axios');
const bcrypt=require('bcrypt');
const { GridFSBucket } = require('mongodb');
const nodemailer = require("nodemailer");
require('dotenv').config();


const saltRounds = 13;

var removeElements=(data,keys)=>{
    // console.log(typeof(keys));
    var newData={};
    Object.keys(data).forEach((key)=>{
        if(keys.indexOf(key)==-1){
            newData[key]=data[key];
        }
    });
    return newData;
    
};

 async function generatePassword(){

    var password="";
    var characters="qwertyuiopa4s+-df=ghjklzxc/vbnm5QWERTYUI`@#$OPASDFGH!JKLMNBVCXZ1236987^&*"

    for(let i=0;i<10;i++){
        let index= Math.floor(Math.random()*characters.length);
        password=password+characters[index];
    }

    return bcrypt.hash(password,saltRounds).then((encryptedPassword)=>{
            return {password,encryptedPassword};
    });
    
}






// async..await is not allowed in global scope, must use a wrapper
async function sendPassword(name,email,password) {
  // Generate test SMTP service account from ethereal.email
  // Only needed if you don't have a real mail account for testing
  // let testAccount = await nodemailer.createTestAccount();

  // create reusable transporter object using the default SMTP transport
  let transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true, // true for 465, false for other ports
    auth: {
      user: process.env.MAILER_EMAIL, // generated ethereal user
      pass: process.env.MAILER_PASSWORD, // generated ethereal password
    },
  });

  // send mail with defined transport object
  let info = await transporter.sendMail({
    from: '"B-Track" <noReply@mail.btrack.com>', // sender address
    to: `${name}, ${email}`, // list of receivers
    subject: "B-Track driver login and Password", // Subject line
    text: `
        Dear ${name},
            Hello, Mr/Ms/Mrs ${name} an account with your email-address is created on the B-Track drivers portal.
        We at B-Track thank you for creating an account and join us as our driving partner. You can access your 
        account with your email as "Username" and the password given below.

        Username: ${email}
        Password: ${password}
    `, // plain text body
    
  });  

  console.log("Message sent: %s", info.messageId);



  return info;
}

async function sendUpdateEmail(name,email) {
  // Generate test SMTP service account from ethereal.email
  // Only needed if you don't have a real mail account for testing
  let testAccount = await nodemailer.createTestAccount();

  // create reusable transporter object using the default SMTP transport
  let transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true, // true for 465, false for other ports
    auth: {
      user: process.env.MAILER_EMAIL, // generated ethereal user
      pass: process.env.MAILER_PASSWORD, // generated ethereal password
    },
  });

  // send mail with defined transport object
  let info = await transporter.sendMail({
    from: '"B-Track" <noReply@mail.btrack.com>', // sender address
    to: `${name}, ${email}`, // list of receivers
    subject: "B-Track driver login and Password", // Subject line
    text: `
        Dear ${name},
            Hello, Mr/Ms/Mrs ${name} your account is updated on the B-Track drivers portal.
        We at B-Track have fulfilled your request for updating your account.

        If no such request has been made then please contact the executives incharge.

        
    `, // plain text body
    
  });

  console.log("Message sent: %s", info.messageId);
  
  return info;
}

function createBusStopFormat(newData){
    var data=newData[0];
    var i,j;
    var len=data.busStopIds.length;
    var reachedFlag=true;
    var busStops=[];
    var coordinateString="";
    for(i=0;i<len;i++){
      
      for(j=0;j<len;j++){
        if(data.busStopIds[i]==data.stops[j].busStopId){
          busStops[i]={"busStopId":data.busStopIds[i],'coordinates':data.stops[j].coordinates,'reachedStatus':reachedFlag,"timeRequired":0,"distanceRequired":0}
          console.log(data.stops[j].coordinates);
          // coordinateString+=data.stops[j].coordinates.longitude+","+data.stops[j].coordinates.latitude+";";
          break;
        }
      }
      reachedFlag=false;
    }
  return busStops;
}

async function getDistanceFromBusStop(latitude,longitude,busStops){
  var len = busStops.length;
  var coordinateString=`${longitude},${latitude};`;
  var indices=[],j=0;
  for(let i=0;i<len;i++)
  {
    if(!busStops[i].reachedStatus){
      indices[j]=i
      coordinateString+=`${busStops[i].coordinates.longitude},${busStops[i].coordinates.latitude};`;
      j+=1;
    }
  }

  return axios.get(`https://api.mapbox.com/directions/v5/mapbox/driving/${coordinateString.substring(0,coordinateString.length-1)}?language=en&overview=simplified&access_token=${process.env.mapbox_access_token}`)
    .then((value)=>{
      var time=0,distance=0;
      var legs=value.data.routes[0].legs;
      var len=legs.length,k=0;
      for(let i=0;i<len;i++){
        time=time+legs[i].duration;
        distance=distance+legs[i].distance;
        busStops[indices[i]].timeRequired=time;
        busStops[indices[i]].distanceRequired=distance;
        if(distance<20){
          busStops[indices[i]].reachedStatus=true;
        }
      }

      return busStops;

    });
  
}


module.exports={removeElements,generatePassword,sendPassword,sendUpdateEmail,getDistanceFromBusStop,createBusStopFormat};