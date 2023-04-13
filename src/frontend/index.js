const express = require("express");

const app = express();

// Port Number Setup
var PORT = process.env.port || 5000;

app.use(express.static("public"));

app.listen(PORT, function (error) {
    if (error) throw error;
    console.log("Server created Successfully on PORT :", PORT);
  });