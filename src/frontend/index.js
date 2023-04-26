const config =  require('./config.js');

console.log(`NODE_ENV=${config.NODE_ENV}`);

const express = require("express");
const bodyParser = require('body-parser');
var http = require("http");

const PROTO_PATH = __dirname + '/protos/list.proto';

const grpc = require('@grpc/grpc-js');

const protoLoader = require('@grpc/proto-loader');

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,

  longs: String,

  enums: String,

  defaults: true,

  oneofs: true,
});

const list_proto = grpc.loadPackageDefinition(packageDefinition).list;

const listStub = new list_proto.ListService('0.0.0.0:50051',
  grpc.credentials.createInsecure());


const app = express();

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))

// Port Number Setup
//var PORT = process.env.port || 5000;

endpoints = {
  listService: "http://localhost:50051",
};

//app.use(express.static("public"));

app.post('/newlist', (req, res) => {
  console.log("New List Request " + JSON.stringify(req.body));
  let data = req.body;
  listStub.NewList(data, (err, ListResponse) => {
    console.log("new List Added");
  }
  );

  res.send('Data Received: ' + JSON.stringify(data));
})

app.get('/getlists', (req, res) => {

  let user = { "userId" : req.query.userId };
    
  listStub.GetLists(user, (err, response) => {

    console.log("Getting Lists for user " + req.query.userId);

    if (!err) {
      
      //responseData = ListList;
      console.log('lists 1: ', response);
      res.header("Access-Control-Allow-Origin", "*");
      res.header("Access-Control-Allow-Methods", "GET,PUT,PATCH,POST,DELETE");
      res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
      //res.send(JSON.stringify(responseData.list));
      res.send(JSON.stringify(response));
    } else {
      console.error(err);
    }

  }
  );

})

app.listen(config.PORT, function (error) {
  if (error) throw error;
  console.log("Server created Successfully on PORT :", config.PORT);
});