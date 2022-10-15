"use strict";

const functions = require("firebase-functions");

const admin = require("firebase-admin");

let unirest = require('unirest');

const dayjs = require('dayjs');

const nodemailer = require("nodemailer");

const consumerKey = "RGoMy1vA3dGzwO67rVvDGvv0IsEPECAF";
const consumerSecret = "6oCXL9IkEpTteqry";

admin.initializeApp(functions.config().firebase);

const db = admin.firestore();

const credentials = {
    apiKey: '2a3adc1828d8b53df0ac5710a98f8d3c1654cf7b38edded0d2fd25775b108b17',         // use your sandbox app API key for development in the test environment
    username: 'ekodi',      // use 'sandbox' for development in the test environment
};

const Africastalking = require('africastalking')(credentials);

// Initialize a service e.g. SMS
const sms = Africastalking.SMS


function getBase64Encode(data) {
    let keySecretData = `${data}`;
    let buff = new Buffer(keySecretData);
    let basicAuth = buff.toString('base64');

    return basicAuth;
}


function getTimestamp() {
    const d_t = new Date();
 
    let year = d_t.getFullYear();
    let month = ("0" + (d_t.getMonth() + 1)).slice(-2);
    let day = ("0" + d_t.getDate()).slice(-2);
    let hour = d_t.getHours();
    let minute = d_t.getMinutes();
    let seconds = d_t.getSeconds();

    return year+month+day+hour+minute+seconds;
}


exports.newUser = functions.firestore.document('users/{userID}').onCreate(async (snap, context) => {

    const user = snap.data();

});

exports.newMessage = functions.firestore.document('users/{userID}/messages/{messagesID}').onCreate(async (snap, context) => {
    const message = snap.data();

    const tokens = message.receiverInfo.deviceTokens;

    if(tokens.length === 0)
    {
        console.log("No tokens available");
    }
    else 
    {
        sendPushNotification(message.messageID, message.senderInfo.name, message.messageDescription, tokens);
    }
});

function sendPushNotification(messageID, title, body, tokens) {
    try{
        const messageNotification = {
            notification: {
                title: title,
                body: body,
                //image: 
            },
            data: {
                messageId: messageID,
            },
            android: {
                priority: "high",
                // notification: {
                //     imageUrl: 
                // }
            },
            apns: {
                payload: {
                    aps: {
                        'mutable-content': 1,
                        contentAvailable: true,
                    }
                },
                fcm_options: {
                    //image: 
                },
                headers: {
                    "apns-push-type": "background",
                    "apns-priority": "5", // Must be 5 when contentAvailable is set to true
                    "apns-topic": "io.flutter.plugins.firebase.messaging",
                },
            },
            webpush: {
                headers: {
                    //image: ,
                    Urgency: "high",
                },
                notification: {
                    body: body,
                    requireInteraction: "true",
                    //badge: url to image
                }
            },
            //topic: topicName,
            tokens: tokens
        }

        admin.messaging().sendMulticast(messageNotification)
        .then((response) => {
            if(response.failureCount > 0)
            {
                const failedTokens = [];

                response.responses.forEach((resp, idx) => {
                    if(!resp.success) {
                        //failedTokens.push(registrationTokens[idx]);
                    }
                });
                console.log('List of tokens that caused failures: ' + failedTokens)
            }
        });

    } catch (error) {
        console.error(error);
    }
}

exports.sendEmail = functions.firestore.document('mymail/{mailID}').onCreate(async (snap, context) => {
    const newEmail = snap.data();

    // Generate test SMTP service account from ethereal.email
    // Only needed if you don't have a real mail account for testing
    let testAccount = await nodemailer.createTestAccount();

    // create reusable transporter object using the default SMTP transport
    let transporter = nodemailer.createTransport({
        host: "smtp.ethereal.email",
        port: 587,
        secure: false, // true for 465, false for other ports
        auth: {
        user: testAccount.user, // generated ethereal user
        pass: testAccount.pass, // generated ethereal password
        },
    });

    // send mail with defined transport object
    let info = await transporter.sendMail({
        from: '"Fred Foo 👻" <foo@example.com>', // sender address
        to: "briannamutali586@gmail.com", //"bar@example.com, baz@example.com", // list of receivers
        subject: "Hello ✔", // Subject line
        text: "Hello world?", // plain text body
        html: "<b>Hello world?</b>", // html body
    });

    console.log("Message sent: %s", info.messageId);
    // Message sent: <b658f8ca-6296-ccf4-8306-87d57a0b4321@example.com>

    // Preview only available when sending through an Ethereal account
    console.log("Preview URL: %s", nodemailer.getTestMessageUrl(info));
    // Preview URL: https://ethereal.email/message/WaQKMgKddxQDoou...
});

exports.sendBulkSMS = functions.firestore.document('users/{userID}/bulkSMS/{bulkSmsID}').onCreate(async (snap, context) => {
    const newSMS = snap.data();

    const phoneList = newSMS.phoneNumbers;

    const options = {
        to: phoneList,
        message: newSMS.smsDescription,
        from: "Validus"
    }

    // Send message and capture the response or error
    sms.send(options)
        .then( response => {
            console.log(response);
        })
        .catch( error => {
            console.log(error);
        });


});

exports.mPesa = functions.firestore.document('users/{userID}/paymentRequest/{requestID}').onCreate(async (snap, context) => {
    const transactionDetails = snap.data();

    let basicAuth = getBase64Encode(`${consumerKey}:${consumerSecret}`);

    console.log("============1============");

    let accessToken = "";

    let req = await unirest('GET', 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials')//this returns the access token
    .headers({ 'Authorization': `Basic ${basicAuth}` })
    .send()
    .then(res => {
        if (res.error) throw new Error(res.error);

        else {
            let generatedAccessToken = res.body.access_token;

            accessToken = generatedAccessToken; 

            console.log(generatedAccessToken);
        }

        });

    console.log("============2============");

    if(accessToken != "")
    {
        let getPassword = getBase64Encode(`${transactionDetails.BusinessShortCode}${transactionDetails.passKey}${transactionDetails.Timestamp}`);

        let performTransaction = await unirest('POST', 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest')
        .headers({
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${accessToken}`,
        })
        .send(JSON.stringify({
            "BusinessShortCode": transactionDetails.BusinessShortCode,
            "Password": getPassword,
            "Timestamp": transactionDetails.Timestamp,
            "TransactionType": transactionDetails.TransactionType,
            "Amount": transactionDetails.Amount,
            "PartyA": transactionDetails.PartyA,
            "PartyB": transactionDetails.BusinessShortCode,
            "PhoneNumber": transactionDetails.PhoneNumber,
            "CallBackURL": transactionDetails.CallBackURL,
            "AccountReference": transactionDetails.PhoneNumber,
            "TransactionDesc": transactionDetails.TransactionDesc,
        }))
        .then(result => {
            if (result.error) throw new Error(result.error);

            //console.log(result.body);

            console.log("============3============");

            if(result.body.ResponseCode === 0)//success 
            {

            }
        });

    }
    
});


exports.callback = functions.https.onRequest((req, res) => {
    // Get the header and body through the req variable

    const resultBody = JSON.parse(req.body);

    console.log(resultBody.Body.stkCallback.CheckoutRequestID);

    // See https://firebase.google.com/docs/functions/http-events#read_values_from_the_request

    return admin.firestore().collection('response').doc('123').set({ foo: "bar" })
        .then(() => {
            res.status(200).send("OK");
        })
        .catch(error => {
            // ...
            // See https://www.youtube.com/watch?v=7IkUgCLr5oA&t=1s&list=PLl-K7zZEsYLkPZHe41m4jfAxUi0JjLgSM&index=3
        })

});