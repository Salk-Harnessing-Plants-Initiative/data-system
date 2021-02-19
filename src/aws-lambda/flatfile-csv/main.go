package main

import (
    "log"
    "context"
    "fmt"
    "os"
    "io/ioutil"
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

func submitPlant(w http.ResponseWriter, r *http.Request) {
    body, err := ioutil.ReadAll(r.Body)
    CheckError(err)
    
    data := string(body)
    value := gjson.Get(data, "data.customer.userId")
    println(value.String())

    //fmt.Println("userId is ", payload["data"]["customer"]["userId"])
    //fmt.Println("name is ", payload["data"]["customer"]["name"])
    //fmt.Println("validRows is ", payload["data"]["validRows"])
}

func CheckError(err error) {
    if err != nil {
        log.Fatal(err)
    }
}

/*
r.Get("/flatfile-csv/taco/", func(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("welcome pancake"))
})
r.Get("/flatfile-csv/taco", func(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("welcome apricot"))
})
*/

/*
func HandleLambdaEvent(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var count int
	row := db.QueryRow(`SELECT COUNT(*) FROM "plant" WHERE "plant_id" = $1 OR "container_id" = $1`, event.QrCode)
	err := row.Scan(&count)
	CheckError(err)
	response := MyResponse{(count > 0)}
    
    // =====
    
    var payload interface{}
    err := json.Unmarshal([]byte(request.Body), &payload)
    if err != nil {
        fmt.Println(err.Error()) 
    }

    
    
    

    fmt.Println(request)
    fmt.Println("Hello world people")
    return events.APIGatewayProxyResponse{
        StatusCode: http.StatusOK,
        Body:       "Howdy mc howdy",
    }, nil
}
*/
 
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
