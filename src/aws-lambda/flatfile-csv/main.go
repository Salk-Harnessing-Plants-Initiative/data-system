package main

import (
    "errors"
    "log"
    "context"
    "fmt"
    "os"
    "io/ioutil"
    "encoding/json"
    "net/http"
    "database/sql"

    "github.com/tidwall/gjson"

    "github.com/aws/aws-lambda-go/events"
    "github.com/aws/aws-lambda-go/lambda"
    "github.com/go-chi/chi"
    "github.com/awslabs/aws-lambda-go-api-proxy/chi"

    _ "github.com/lib/pq"
)

var (
	host string     = os.Getenv("host")
	port string     = os.Getenv("port")
	user string     = os.Getenv("user")
	password string = os.Getenv("password")
	database string = os.Getenv("database")
    apikey string   = os.Getenv("apikey")
)
var db *sql.DB
var chiLambda *chiadapter.ChiLambda

func init() {
    // API routes
    r := chi.NewRouter()
    r.Get("/flatfile-csv", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("welcome"))
    })
    r.Post("/flatfile-csv/submit/plant", submitPlant)
    r.Post("/flatfile-csv/submit/plant_data", submitPlantData)
    r.Post("/flatfile-csv/submit/line_accession", submitLineAccession)
    r.Post("/flatfile-csv/submit/container", submitContainer)
    chiLambda = chiadapter.New(r)

    // Postgres
	psqlconn := fmt.Sprintf("host=%s port=%s user=%s " +
    	"password=%s dbname=%s sslmode=disable",
    	host, port, user, password, database)
    var err error
	db, err = sql.Open("postgres", psqlconn)
	if err != nil {
        log.Fatal(err)
    }
}

func sendErrorResponse(w http.ResponseWriter, err error) {
    w.WriteHeader(http.StatusBadRequest)
    w.Write([]byte(err.Error()))
    log.Println("Error:", err)
}

func synthesizeSubmitPayload(payload string) (string, error) {
    // metadata stored as stringified json in data.customer.name
    customerNameField := gjson.Get(payload, "data.customer.name")
    if !customerNameField.Exists() {
        return "", errors.New("missing parameter data.customer.name")
    }
    var metadata map[string]interface{}
    err := json.Unmarshal([]byte(customerNameField.String()), &metadata)
    if err != nil {
        return "", err
    }
    // validRows
    var validRows []map[string]interface{}
    err = json.Unmarshal([]byte(gjson.Get(payload, "data.validRows").String()), &validRows)
    if err != nil {
        return "", err
    }
    if len(validRows) == 0 {
        return "", errors.New("no validRows given")
    }
    // add a copy of each metadata field to each row
    for i := 0; i < len(validRows); i++ {
        for key, val := range metadata {
            validRows[i][key] = val
        }         
    }
    output, err := json.Marshal(validRows)
    return string(output), err
}

func submit(w http.ResponseWriter, r *http.Request, query string) {
    body, err := ioutil.ReadAll(r.Body)
    if err != nil {
        sendErrorResponse(w, err)
        return
    }
    jsonData, err := synthesizeSubmitPayload(string(body))
    if err != nil {
        sendErrorResponse(w, err)
        return
    }
    _, err = db.Exec(query, jsonData)
    if err != nil {
        sendErrorResponse(w, err)
        return
    }
    w.WriteHeader(http.StatusCreated)
    log.Println("Success")
}

func submitPlant(w http.ResponseWriter, r *http.Request) {
    submit(w, r, `INSERT INTO plant SELECT * FROM json_populate_recordset (NULL::plant, $1);`)
}

func submitPlantData(w http.ResponseWriter, r *http.Request) {
    submit(w, r, `INSERT INTO plant_data SELECT * FROM json_populate_recordset (NULL::plant_data, $1);`)
}

func submitLineAccession(w http.ResponseWriter, r *http.Request) {
    submit(w, r, `INSERT INTO line_accession SELECT * FROM json_populate_recordset (NULL::line_accession, $1);`)
}

func submitContainer(w http.ResponseWriter, r *http.Request) {
    submit(w, r, `INSERT INTO container SELECT * FROM json_populate_recordset (NULL::container, $1);`)
}
 
func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
    // Ad hoc api key validation; preferably should have been chi middleware but oh well
    clientApikey, ok := req.QueryStringParameters["apikey"]
    if !ok || apikey != clientApikey {
        return events.APIGatewayProxyResponse{
            StatusCode: http.StatusForbidden,
            Body:       "Invalid API key",
        }, nil
    }
    // If no name is provided in the HTTP request body, throws an error
    return chiLambda.ProxyWithContext(ctx, req)
}

func main() {
    lambda.Start(Handler)
}
