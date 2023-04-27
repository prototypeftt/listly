const config =  require('./config.js');

console.log(`NODE_ENV=${config.NODE_ENV}`);

const express = require("express");
const bodyParser = require('body-parser');
var http = require("http");

const PROTO_PATH = __dirname + '/protos/list.proto';

console.log('proto path:' + PROTO_PATH);

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


service_address = config.SERVICE_ADDRESS+':'+config.SERVICE_ADDRESS_PORT;
//service_address = config.SERVICE_ADDRESS;

console.log('service address: '+service_address)

/*const listStub = new list_proto.ListService(service_address,
  grpc.credentials.createInsecure());*/

const listStub = new list_proto.ListService('dns:///listservice-3pziucpdaa-ey.a.run.app:443',
  grpc.credentials.createInsecure());

const app = express();

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))

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

  console.log('get lists request for user:' + req.query.userId);
    
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