/*
Salk Harnessing Plants Initiative
AWS Lambda for registering plants
Russell Tran
3 December 2020

Usage: event should have the following
{
    experiment_id : string
    container_type : string (e.g. should be "plate", "cylinder", "pot")
    num_containers : can be a number or a number as a string
    plants_per_container : can be a number or a number as a string
    created_by : the user id (optional)
}
*/

const {v4 : uuidv4} = require('uuid');
const pg = require("pg");
const format = require('pg-format');
const pool = new pg.Pool({
    user: process.env.user,
    host: process.env.host,
    database: process.env.database,
    password: process.env.password,
    port: process.env.port
});

exports.handler = async (event) => {
    const experiment_id = event.experiment_id;
    const container_type = event.container_type; 
    const num_containers = parseInt(event.num_containers, 10);
    const plants_per_container = parseInt(event.plants_per_container, 10);
    const created_by = event.created_by;

    // Generate containers, plants, and containing relationships
    let container_rows = [];
    let plant_rows = [];
    let containing_rows = [];
    for (let i = 0; i < num_containers; i++) {
        // Create the container
        const container_id = uuidv4();
        container_rows.push([container_id, experiment_id, created_by]);

        for (let containing_position = 0; containing_position < plants_per_container; containing_position++) {
            // Create the plant
            const plant_id = uuidv4();
            plant_rows.push([plant_id, experiment_id, created_by]);
            // Create the containing relationship
            container_rows.push([container_id, containing_position, plant_id, created_by]);
        }
    }

    // Query
    let result;
    try {
        await pool.query("BEGIN;");
        try {
            await pool.query(format("INSERT INTO container (container_id, experiment_id, created_by) VALUES %L;", container_rows));
            await pool.query(format("INSERT INTO plant (plant_id, experiment_id, created_by) VALUES %L;", plant_rows));
            await pool.query(format("INSERT INTO containing (container_id, containing_position, plant_id, created_by) VALUES %L;", containing_rows));
            result = await pool.query("COMMIT;");
        } catch(err) {
            await pool.query("ROLLBACK");
            console.log(err);
            return {statusCode: 400, body: err.message};
        }
        
    } catch(err) {
        console.log(err);
        return {statusCode: 400, body: err.message};
    }

    console.log(result);
    return {statusCode: 200, body: result};
}

