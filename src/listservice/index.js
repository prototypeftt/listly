const config = require('./config.js');

console.log(`NODE_ENV=${config.NODE_ENV}`);

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

// Imports the Google Cloud client library
const {
  RegistrationServiceClient, LookupServiceClient,
} = require('@google-cloud/service-directory').v1;

// Creates a client
const registrationServiceClient = new RegistrationServiceClient();

const namespaceId = 'list';
const serviceId = 'listservice';
const locationId = 'europe-west3';
const endpointId = 'listservice1';

/**
 * UUID
 */

const uuid = require('uuid');

/**
 * GRPC
 */

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

function RegisterService() {

  // Build the namespace name
  const namespaceName = registrationServiceClient.namespacePath(
    projectId,
    locationId,
    namespaceId
  );

  async function createService() {
    try {
      const [service] = await registrationServiceClient.createService({
        parent: namespaceName,
        serviceId: serviceId,
      });
      console.log(`Created service: ${service.name}`);
      return service;
    } catch (err) {
      console.log('error creating service' + err);
      return err;
    }

  }

  try {
    return createService();
  } catch (err) {
    console.log("error creating service");
  }
}

function ConfigureEndPoint() {

  // Build the service name
  const serviceName = registrationServiceClient.servicePath(
    projectId,
    locationId,
    namespaceId,
    serviceId
  );

  async function createEndpoint() {
    const [endpoint] = await registrationServiceClient.createEndpoint({
      parent: serviceName,
      endpointId: endpointId,
      //endpoint: {address: '10.0.0.1', port: 8080},
    });

    console.log(`Created endpoint: ${endpoint.name}`);
    return endpoint;
  }

  try {
    return createEndpoint();
  } catch (err) {
    console.log("error creating service");
  }

}

function GetServiceList() {
  // Creates a client
  const lookupServiceClient = new LookupServiceClient();

  // Build the service name
  const serviceName = registrationServiceClient.servicePath(
    projectId,
    locationId,
    namespaceId,
    serviceId
  );

  async function resolveService() {
    const [response] = await lookupServiceClient.resolveService({
      name: serviceName,
    });

    console.log(`Resolved service: ${response.service.name}`);
    for (const e of response.service.endpoints) {
      console.log(`\n${e.name}`);
      console.log(`Address: ${e.address}`);
      console.log(`Port: ${e.port}\n`);
    }
    return response.service;
  }

  return resolveService();

}

//const PORT = process.env.PORT;

/**

* Implements the NewList RPC method.

*/

function NewList(call, callback) {

  //Generate UUID for listId
  listId = uuid.v4();

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
          p1: listId,
          p2: call.request.userId,
          p3: call.request.listName,
        },
      });

      callback(null, { "listId": listId });
      console.log("NewList: " + call.request.listName);
      console.log("user: " + call.request.userId);

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

function DeleteList(call, callback) {

  console.log("request:" + call.request.listId);

  database.runTransaction(async (err, transaction) => {
    if (err) {
      console.error(err);
      return;
    }
    try {
      console.log("running delete list query");

      const [result] = await transaction.runUpdate({
        sql: 'DELETE FROM list WHERE listid=$1',
        params: {
          p1: call.request.listId,
        },
      });

      console.log(
        `${result} records deleted`
      );
      await transaction.commit();
      const jsonString = JSON.parse(JSON.stringify(result));

      callback(null, { "deleted": jsonString });

    } catch (err) {
      console.error('ERROR:', err);
    } finally {
      // Close the database when finished.
      //database.close();
    }
  });

}

function GetLists(call, callback) {

  console.log("request:" + call.request.userId);

  database.runTransaction(async (err, transaction) => {
    if (err) {
      console.error(err);
      return;
    }
    try {
      console.log("running get lists query for user:" + call.request.userId);

      const [result] = await transaction.run({
        sql: 'SELECT listId,listName FROM list WHERE (userId=$1)',
        params: {
          p1: call.request.userId,
        },
      });

      console.log(
        `${result.length} records returned`
      );

      const jsonString = JSON.parse(JSON.stringify(result));

      callback(null, { "list": jsonString });

    } catch (err) {
      console.error('ERROR:', err);
    } finally {
      // Close the database when finished.
      //database.close();
    }
  });

}

function main() {

  //RegisterService();

  //ConfigureEndPoint();

  //GetServiceList();

  const server = new grpc.Server();

  server.addService(list_proto.ListService.service, {
    NewList: NewList,
    GetLists: GetLists,
    DeleteList: DeleteList,
  });

  console.log("Server listening on port :" + config.PORT);

  server.bindAsync(
    //`[::]:${config.PORT}`,
    `0.0.0.0:${config.PORT}`,

    grpc.ServerCredentials.createInsecure(),

    () => {
      server.start();
    }
  );

}

main();