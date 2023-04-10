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


/**

* Implements the NewList RPC method.

*/

function NewList(call, callback) {
  callback(null, {  "listId": 1});
  console.log("NewList: " + call.request.listName);
}


function main() {
  const server = new grpc.Server();

  server.addService(list_proto.ListService.service, { NewList: NewList });

  console.log("Server listinening on port : 50051")

  server.bindAsync(
    '0.0.0.0:50051',

    grpc.ServerCredentials.createInsecure(),

    () => {
      server.start();
    }
  );

}

main();