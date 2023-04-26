const dotenv = require('dotenv');
console.log("node_env " + process.env.NODE_ENV);
require('dotenv').config(__dirname, `${process.env.NODE_ENV}.env`);

const path = require('path');

dotenv.config({
    path: path.resolve(__dirname, `${process.env.NODE_ENV}.env`)
});

console.log("config" + path.resolve(__dirname, `${process.env.NODE_ENV}.env`));

module.exports = {
    NODE_ENV : process.env.NODE_ENV || 'development',
    HOST : process.env.HOST || 'localhost',
    PORT : process.env.PORT || 5000
}