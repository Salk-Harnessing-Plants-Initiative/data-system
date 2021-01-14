/*
Salk Harnessing Plants Initiative
AWS Lambda for registering plants
Russell Tran
December 2020
*/

// For CSVs
const moment = require('moment')
const stringify = require('csv-stringify/lib/sync');
const fs = require('fs');
const node_path = require('path');
// For Postgres
const { nanoid } = require("nanoid");
const pg = require("pg");
const format = require('pg-format');
const pool = new pg.Pool({
    user: process.env.user,
    host: process.env.host,
    database: process.env.database,
    password: process.env.password,
    port: process.env.port
});
// For AWS S3
const bucket = process.env.bucket;
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    let {container_rows, plant_rows, container_csv_rows, plant_csv_rows} = generate_rows(event);
    try {
        // Upload container csv for user to S3
        const container_csv_header = ["container_id"];
        container_csv_key = await upload(make_csv(container_csv_header, container_csv_rows, event.experiment_id, event.container_type));
        // Upload plant csv for user to S3
        // line_accession and local_id are headers for blank columns for user to fill in later
        const plant_csv_header = ["plant_id", "container_id", "containing_position", "line_accession", "local_id"];
        plant_csv_key = await upload(make_csv(plant_csv_header, plant_csv_rows, event.experiment_id, "plant"));
        // Insert into Postgres
        await do_insert(container_rows, plant_rows);
    } catch (err) {
        console.log(err);
        return {statusCode: 400, body: err.stack};
    }
    return {statusCode: 200, container_csv_key: container_csv_key, plant_csv_key: plant_csv_key};
}

function generate_container_id() {
    // Notice here that the nanoid is 14 characters instead of the usual 21.
    var container_id = nanoid(14);
    while (container_id.startsWith("-")) {
        // Excel gets confused if a cell starts with "-"
        container_id = nanoid(14);
    }
    return container_id;
}

function generate_plant_id() {
    var plant_id = nanoid();
    while (plant_id.startsWith("-")) {
        // Excel gets confused if a cell starts with "-"
        plant_id = nanoid();
    }
    return plant_id;
}

function generate_rows (event) {
    const experiment_id = event.experiment_id;
    const container_type = event.container_type; 
    const num_containers = parseInt(event.num_containers, 10);
    const plants_per_container = parseInt(event.plants_per_container, 10);
    const created_by = event.created_by;

    // For database entry
    let container_rows = [];
    let plant_rows = [];
    // For CSVs for the client
    let container_csv_rows = [];
    let plant_csv_rows = [];

    // Generate containers, plants, and containing relationships
    for (let i = 0; i < num_containers; i++) {
        // Create the container
        const container_id = generate_container_id();
        container_rows.push([container_id, experiment_id, created_by, container_type]);
        container_csv_rows.push([container_id]);

        // (Notice here that this is 1-indexed because biologists like it that way!!)
        for (let containing_position = 1; containing_position <= plants_per_container; containing_position++) {
            // Create the plant
            const plant_id = generate_plant_id();
            plant_rows.push([plant_id, experiment_id, created_by, container_id, containing_position]);
            plant_csv_rows.push([plant_id, container_id, containing_position]);
        }
    }
    return {container_rows, plant_rows, container_csv_rows, plant_csv_rows};
}

async function do_insert(container_rows, plant_rows) {
    let queryResult;
    try {
        await pool.query("BEGIN;");
        try {
            await pool.query(format("INSERT INTO container (container_id, experiment_id, created_by, container_type) VALUES %L;", container_rows));
            await pool.query(format("INSERT INTO plant (plant_id, experiment_id, created_by, container_id, containing_position) VALUES %L;", plant_rows));
            queryResult = await pool.query("COMMIT;");
        } catch(err) {
            await pool.query("ROLLBACK;");
            throw err;
        }
    } catch(err) {
        throw err;
    }

    console.log(queryResult);
}

function make_csv (header_row, rows, experiment_id, topic) {
    rows.unshift(header_row);
    const data = stringify(rows);
    const path = `/tmp/${experiment_id}-new-${topic}-${moment().format("YYYY-MM-DD-HHMMSS")}.csv`;
    fs.writeFileSync(path, data, 'utf8');
    return path;
}

async function upload (path) {
    const fileContent = fs.readFileSync(path);
    const key = node_path.basename(path);
    try {
        const params = {
            Bucket: bucket,
            Key: key, // File name you want to save as in S3
            Body: fileContent,
            ContentType: 'text/csv'
        };
        // executes the upload and waits for it to finish
        await s3.upload(params).promise().then(function(data) {
            console.log(`File uploaded successfully. ${data.Location}`);
        }, function (err) {
            console.error("Upload failed", err);
        });
        
    } catch (err) {
        throw err;
    } 
    return key;
}

