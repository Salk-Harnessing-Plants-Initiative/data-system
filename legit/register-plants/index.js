const {v4 : uuidv4} = require('uuid');
const pg = require("pg");
const pool = new pg.Pool({
    user: process.env.user,
    host: process.env.host,
    database: process.env.database,
    password: process.env.password,
    port: process.env.port
});

exports.handler = async (event) => {
    let result;
    try {
        result = await pool.query("SELECT * FROM experiment"); 
        console.log(result.rows);
    } catch(err) {
        console.log(err);
    }
    pool.end();

    console.log(uuidv4());

    const response = {
        statusCode: 200,
        body: JSON.stringify(result.rows),
    };

    return response;
};