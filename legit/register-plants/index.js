const pg = require("pg");
const pool = new pg.Pool({
user: process.env.user,
host: process.env.host,
database: process.env.database,
password: process.env.password,
port: process.env.port});

exports.handler = async (event) => {

    console.log("HOWDY!");

    try {
        let result = await pool.query("SELECT * FROM experiment"); 
        console.log(result.rows);
    } catch(err) {
        console.log(err);
    }
    pool.end();

    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
    };

    console.log("GOODBYE!");

    return response;
};