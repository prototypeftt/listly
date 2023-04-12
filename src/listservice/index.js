// Imports the Google Cloud client library
const { Spanner } = require('@google-cloud/spanner');

const projectId = 'listly-f1ab7';
const instanceId = 'list-instance';
const databaseId = 'list-database';

// Creates a client
const spanner = new Spanner({
  projectId: projectId,
});

// Gets a reference to a Cloud Spanner instance and database
const instance = spanner.instance(instanceId);
const database = instance.database(databaseId);

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
  callback(null, { "listId": 1 });
  console.log("NewList: " + call.request.listName);

  database.runTransaction(async (err, transaction) => {
    if (err) {
      console.error(err);
      return;
    }
    try {
      const [rowCount] = await transaction.runUpdate({
        //sql: 'INSERT INTO list (listId, userId, listName) VALUES (7,666,@listName)',
        sql: 'INSERT Into list (listId, userId, listName) VALUES ($1,$2,$3)',
        params: {
          p1: call.request.listName,
          p2: call.request.listName,
          p3: call.request.listName,
        },
      });
  
      console.log(
        `Successfully inserted ${rowCount} record into the list table.`
      );
  
      await transaction.commit();
    } catch (err) {
      console.error('ERROR:', err);
    } finally {
      // Close the database when finished.
      //database.close();
    }
  });


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