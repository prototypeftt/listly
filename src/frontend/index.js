const express = require("express");
const bodyParser = require('body-parser');
var http = require("http");

const PROTO_PATH = __dirname + '../../listservice/protos/list.proto';

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
var PORT = process.env.port || 5000;

endpoints = {
  listService: "http://localhost:50051",
};

app.use(express.static("public"));

app.post('/newlist', (req, res) => {
  console.log("New List Request " + JSON.stringify(req.body));
  let data = req.body;
  listStub.NewList(data , (err, ListResponse) => 
  {
    console.log("new List Added");
  }
  );

  res.send('Data Received: ' + JSON.stringify(data));
})

app.listen(PORT, function (error) {
  if (error) throw error;
  console.log("Server created Successfully on PORT :", PORT);
});