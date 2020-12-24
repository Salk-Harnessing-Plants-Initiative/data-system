/*
Salk Harnessing Plants Initiative
AWS Lambda for validating and processing data commits (uploads)
Russell Tran
December 2020
*/
// For Postgres
const pg = require('pg');
const pool = new pg.Pool({
    user: process.env.user,
    host: process.env.host,
    database: process.env.database,
    password: process.env.password,
    port: process.env.port
});

exports.handler = async (event) => {
	console.log(event);
	const meta = event.e.meta;
	const validData = event.e.validData;

    let queryResult;
    try {
    	queryResult = await pool.query(`INSERT INTO plant SELECT * FROM json_populate_recordset (NULL::json_table, '${validData}');`)
    } catch(err) {
        console.log(err);
        return {statusCode: 400, body: err.stack};
    }
    console.log(queryResult);
    return {statusCode: 200};
}