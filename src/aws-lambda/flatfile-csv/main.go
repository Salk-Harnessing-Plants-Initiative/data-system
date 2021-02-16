// package main
 
// import (
//     "fmt"
//     "log"
//     "os"
//     "net/http"
//     "database/sql"
//     "github.com/aws/aws-lambda-go/lambda"
//     "github.com/aws/aws-lambda-go/events"
//     "github.com/aquasecurity/lmdrouter"

//     _ "github.com/lib/pq"
// )

// var (
// 	host string     = os.Getenv("host")
// 	port string     = os.Getenv("port")
// 	user string     = os.Getenv("user")
// 	password string = os.Getenv("password")
// 	database string = os.Getenv("database")
//     apikey string   = os.Getenv("apikey")
// )
// var db *sql.DB
// var router *lmdrouter.Router

// func init() {
//     router = lmdrouter.NewRouter("/api", loggerMiddleware, authMiddleware)
//     router.Route("GET", "/", listSomethings)
//     router.Route("POST", "/", postSomething, someOtherMiddleware)
//     router.Route("GET", "/:id", getSomething)
//     router.Route("PUT", "/:id", updateSomething)
//     router.Route("DELETE", "/:id", deleteSomething)

//     // Postgres
// 	psqlconn := fmt.Sprintf("host=%s port=%s user=%s " +
//     	"password=%s dbname=%s sslmode=disable",
//     	host, port, user, password, database)
//     var err error
// 	db, err = sql.Open("postgres", psqlconn)
// 	if err != nil {
//         log.Fatal(err)
//     }
// }

// func HandleLambdaEvent(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
//     /*
// 	var count int
// 	row := db.QueryRow(`SELECT COUNT(*) FROM "plant" WHERE "plant_id" = $1 OR "container_id" = $1`, event.QrCode)
// 	err := row.Scan(&count)
// 	CheckError(err)
// 	response := MyResponse{(count > 0)}
//     */
//     // Ad hoc api key validation
//     clientApikey, ok := request.QueryStringParameters["apikey"]
//     if !ok || apikey != clientApikey {
//         return events.APIGatewayProxyResponse{
//             StatusCode: http.StatusForbidden,
//             Body:       "Invalid API key",
//         }, nil
//     }


//     var payload interface{}
//     err := json.Unmarshal([]byte(request.Body), &payload)
//     if err != nil {
//         fmt.Println(err.Error()) 
//     }

//     payload["data"]["customer"]["userId"]
//     payload["data"]["customer"]["name"]
//     payload["data"]["validRows"]


//     fmt.Println(request)
//     fmt.Println("Hello world people")
//     return events.APIGatewayProxyResponse{
//         StatusCode: http.StatusOK,
//         Body:       "Howdy mc howdy",
//     }, nil
// }
 
// func main() {
//     lambda.Start(HandleLambdaEvent)
// }



package main

import (
    "log"
    "context"
    "net/http"

    "github.com/aws/aws-lambda-go/events"
    "github.com/aws/aws-lambda-go/lambda"

    "github.com/go-chi/chi"
    //"github.com/go-chi/chi/middleware"
    "github.com/awslabs/aws-lambda-go-api-proxy/chi"
)

var chiLambda *chiadapter.ChiLambda

func init() {
    log.Printf("Cold start")
    r := chi.NewRouter()
    //r.Use(middleware.Logger)
    r.Get("/flatfile-csv", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("welcome"))
    })
    r.Get("/flatfile-csv/taco/", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("welcome pancake"))
    })
    r.Get("/flatfile-csv/taco", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("welcome apricot"))
    })
    chiLambda = chiadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
    // If no name is provided in the HTTP request body, throw an error
    log.Printf("HELLO THERE!!!")
    log.Println(req.Path)
    return chiLambda.ProxyWithContext(ctx, req)
}

func main() {
    lambda.Start(Handler)
}