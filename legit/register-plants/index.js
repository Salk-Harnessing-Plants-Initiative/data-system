const pg = require("pg");
const pool = new pg.Pool({
user: process.env.user,
host: process.env.host,
database: process.env.database,
password: process.env.password,
port: process.env.port});

exports.handler = async (event) => {

	pool.query("SELECT * FROM experiment", (err, res) => {
		console.log(err, res);
		pool.end();
	});

    // TODO implement
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
    };
    return response;
};

