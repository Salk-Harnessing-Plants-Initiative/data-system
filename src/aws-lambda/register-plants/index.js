/*
Salk Harnessing Plants Initiative
AWS Lambda for registering plants
Russell Tran
December 2020
*/


// TODO: container_metadata formula as an option
// TODO: every-other-group shading for plant_metadata as an option

// For CSVs
const moment = require('moment')
const stringify = require('csv-stringify/lib/sync');
const fs = require('fs');
const node_path = require('path');
// Excel
const spreadsheet = require('./spreadsheet');
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
    let workbook_s3_key;
    try {
        // Insert into Postgres
        await do_insert(container_rows, plant_rows);

        const num_containers = parseInt(event.num_containers, 10);
        const plants_per_container = parseInt(event.plants_per_container, 10);
        const workbook = spreadsheet.generate_workbook(num_containers, plants_per_container, container_csv_rows, plant_csv_rows);

        const experiment_id = event.experiment_id;
        const path = `/tmp/${experiment_id}_${nanoid(4)}.xlsx`; // TODO make distinctions for additional registrations
        await workbook.xlsx.writeFile(path);
        workbook_s3_key = await upload(path); 

    } catch (err) {
        console.log(err);
        return {statusCode: 400, body: err.stack};
    }
    return {"statusCode": 200, workbook_s3_key : workbook_s3_key};
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
        const container_id_abbrev = container_id.substring(0, 6);
        container_csv_rows.push([container_id, container_id_abbrev]);

        // (Notice here that this is 1-indexed because biologists like it that way!!)
        for (let containing_position = 1; containing_position <= plants_per_container; containing_position++) {
            // Create the plant
            const plant_id = generate_plant_id();
            plant_rows.push([plant_id, experiment_id, created_by, container_id, containing_position]);
            const plant_id_abbrev = plant_id.substring(0, 6);
            plant_csv_rows.push([plant_id, container_id, plant_id_abbrev, containing_position]);
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
}

function make_csv (header_row, rows, experiment_id, topic) {
    rows.unshift(header_row);
    const data = stringify(rows);
    const path = `/tmp/${experiment_id}-new-${topic}-${moment().utcOffset('-0800').format("YYYY-MM-DD-HHMMSS")}.csv`;
    fs.writeFileSync(path, data, 'utf8');
    return path;
}

async function upload (path) {
    const fileContent = fs.readFileSync(path);
    const key = "tmp/csv/" + node_path.basename(path);
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

