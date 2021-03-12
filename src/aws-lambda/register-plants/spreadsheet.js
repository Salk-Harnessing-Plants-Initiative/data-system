const ExcelJS = require('exceljs');
const MAX_PLANT_COLUMNS = 50;
const PLANT_SHEET_NAME = 'plant_metadata';
const CONTAINER_SHEET_NAME = 'container_metadata';

function generate_workbook(num_containers, plants_per_container) {
	const workbook = new ExcelJS.Workbook();

	// set up plant_metadata sheet
	const plant_sheet = workbook.addWorksheet(PLANT_SHEET_NAME, {views:[{state: 'frozen', xSplit: 0, ySplit:1}]});
	plant_sheet.properties.defaultColWidth = 15;
	const plant_predefined_cols = [
		{ header: 'plant_id', key: 'plant_id', width: 30 },
		{ header: 'container_id', key: 'container_id', width: 25 },
		{ header: 'containing_position', key: 'containing_position', width: 17},
		{ header: 'plant_id_abbrev', key: 'plant_id_abbrev', width: 16}
	];
	const plant_blank_cols = [
		{ header: 'line_accession', key: 'line_accession', width: 19},
		{ header: 'local_id', key: 'local_id', width: 14},
		{ header: 'local_batch', key: 'local_id', width: 14}
	];
	plant_sheet.columns = plant_predefined_cols.concat(plant_blank_cols);

	// set up container_metadata sheet
	const container_sheet = workbook.addWorksheet(CONTAINER_SHEET_NAME, {views:[{state: 'frozen', xSplit: 2, ySplit:1}]});
	container_sheet.properties.defaultColWidth = 15;
	const container_predefined_cols = [
	  { header: 'container_id', key: 'container_id', width: 25 },
	  { header: 'container_id_abbrev', key: 'container_id_abbrev', width: 20}
	];
	container_sheet.columns = container_predefined_cols;

	// generate container_metadata column name formulas that reference plant_metadata column names
	create_container_column_names(plants_per_container, container_sheet, 
		plant_predefined_cols.length, container_predefined_cols.length);
	
	// generate container_metadata cell formulas that reference plant_metadata cells
	create_container_cell_formulas(num_containers, plants_per_container, container_sheet, 
		plant_predefined_cols.length, container_predefined_cols.length);

	return workbook;
}

function create_container_column_names(plants_per_container, container_sheet, 
	num_predefined_plant_cols, num_predefined_container_cols) {
	var container_col = num_predefined_container_cols + 1;
	// iterate left to right over the non-predefined plant columns
	for (var plant_col = num_predefined_plant_cols + 1; plant_col <= MAX_PLANT_COLUMNS; plant_col++) {
		const plant_cell = columnToLetter(plant_col) + '1'; // (cell in first row to grab column header; e.g. E1)
		// create a version of the plant column in the container sheet for each plant i within a container
		for (var i = 1; i <= plants_per_container; i++) {
			const container_cell = columnToLetter(container_col) + '1'; // (cell in first row to set column header; e.g. C1)
			container_sheet.getCell(container_cell).value = { 
				// use concatenate to dynamically reference the future plant column names by the user
				formula: `CONCATENATE(${i}, "_", '${PLANT_SHEET_NAME}'!${plant_cell})`
			};
			container_col++; // get ready to populate the next column in container sheet
		} 
	}
}

function create_container_cell_formulas(num_containers, plants_per_container, 
	container_sheet, num_predefined_plant_cols, num_predefined_container_cols) {
	const num_generated_container_cols = plants_per_container * MAX_PLANT_COLUMNS;
	
	// iterate down over the rows in container sheet
	for (var container_row = 2; container_row <= num_containers + 1; container_row++) {
		const baseline_plant_row = 2 + (container_row - 2) * plants_per_container;
		var plant_row = baseline_plant_row;
		var plant_col = num_predefined_plant_cols + 1;
		// iterate left to right over the non-predefined container columns 
		for (var container_col = num_predefined_container_cols + 1; 
			container_col <= num_predefined_container_cols + num_generated_container_cols;
			container_col++) {

			const container_cell = columnToLetter(container_col) + container_row ; // e.g. C2
			const plant_cell = columnToLetter(plant_col) + plant_row; // e.g. E2
			container_sheet.getCell(container_cell).value = { formula : `'${PLANT_SHEET_NAME}'!${plant_cell}`};

			// Increment the plant sheet cell row we are referring to.
			// Once we have finished with all the numberings of a particular column,
			// reset the plant row to baseline (jump back up a few in the plant sheet)
			// and increment the plant column (go right in the plant sheet)
			// e.g. done with "1_line_accession", "2_line_accession", "3_line_accession" and about to 
			// move on to "1_local_id", so reset to baseline row and move to the column to the right
			plant_row++;
			if (plant_row - baseline_plant_row >= plants_per_container) {
				plant_row = baseline_plant_row;
				plant_col++;
			}
		}
	}
}

// https://stackoverflow.com/a/21231012/14775744
// where column is 1-indexed
function columnToLetter(column) {
	var temp, letter = '';
	while (column > 0) {
		temp = (column - 1) % 26;
		letter = String.fromCharCode(temp + 65) + letter;
		column = (column - temp - 1) / 26;
	}
	return letter;
}
function letterToColumn(letter) {
	var column = 0, length = letter.length;
	for (var i = 0; i < length; i++) {
		column += (letter.charCodeAt(i) - 64) * Math.pow(26, length - i - 1);
	}
	return column;
}
