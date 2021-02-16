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

// func main() {
//     lambda.Start(router.Handler)
// }

// // the rest of the code is a redacted example, it will probably reside in a
// // separate package inside your project

// type listSomethingsInput struct {
//     ID                string   `lambda:"path.id"`                // a path parameter declared as :id
//     ShowSomething     bool     `lambda:"query.show_something"`   // a query parameter named "show_something"
//     AcceptedLanguages []string `lambda:"header.Accept-Language"` // a multi-value header parameter
// }

// type postSomethingInput struct {
//     Title   string    `json:"title"`
//     Date    time.Time `json:"date"`
// }

// func listSomethings(ctx context.Context, req events.APIGatewayProxyRequest) (
//     res events.APIGatewayProxyResponse,
//     err error,
// ) {
//     // parse input from request and path parameters
//     var input listSomethingsInput
//     err = lmdrouter.UnmarshalRequest(req, false, &input)
//     if err != nil {
//         return lmdrouter.HandleError(err)
//     }

//     // call some business logic that generates an output struct
//     // ...

//     return lmdrouter.MarshalResponse(http.StatusOK, nil, output)
// }

// func postSomethings(ctx context.Context, req events.APIGatewayProxyRequest) (
//     res events.APIGatewayProxyResponse,
//     err error,
// ) {
//     // parse input from request body
//     var input postSomethingsInput
//     err = lmdrouter.UnmarshalRequest(req, true, &input)
//     if err != nil {
//         return lmdrouter.HandleError(err)
//     }

//     // call some business logic that generates an output struct
//     // ...

//     return lmdrouter.MarshalResponse(http.StatusCreated, nil, output)
// }

// func loggerMiddleware(next lmdrouter.Handler) lmdrouter.Handler {
//     return func(ctx context.Context, req events.APIGatewayProxyRequest) (
//         res events.APIGatewayProxyResponse,
//         err error,
//     ) {
//         // [LEVEL] [METHOD PATH] [CODE] EXTRA
//         format := "[%s] [%s %s] [%d] %s"
//         level := "INF"
//         var code int
//         var extra string

//         res, err = next(ctx, req)
//         if err != nil {
//             level = "ERR"
//             code = http.StatusInternalServerError
//             extra = " " + err.Error()
//         } else {
//             code = res.StatusCode
//             if code >= 400 {
//                 level = "ERR"
//             }
//         }

//         log.Printf(format, level, req.HTTPMethod, req.Path, code, extra)

//         return res, err
//     }
// }

// package main

// import (
//     "fmt"
//     "log"
//     "net/http"

//     "github.com/go-chi/chi"
//     "github.com/go-chi/chi/middleware"
//     "github.com/apex/gateway"
// )

// func main() {
//     r := chi.NewRouter()
//     r.Use(middleware.Logger)
//     r.Get("/", hello)
//     log.Fatal(gateway.ListenAndServe(":3000", r))
// }

// func hello(w http.ResponseWriter, r *http.Request) {
//     fmt.Println("YODEL")
//     // example retrieving values from the api gateway proxy request context.
//     requestContext, ok := gateway.RequestContext(r.Context())
//     if !ok || requestContext.Authorizer["sub"] == nil {
//         fmt.Fprint(w, "Hello World from Go")
//         return
//     }

//     userID := requestContext.Authorizer["sub"].(string)
//     fmt.Fprintf(w, "Hello %s from Go", userID)
// }

package main

import (
    "fmt"
    "log"
    "net/http"

    "github.com/apex/gateway"
)

func main() {
    http.HandleFunc("/", hello)
    log.Fatal(gateway.ListenAndServe(":3000", nil))
}

func hello(w http.ResponseWriter, r *http.Request) {
    // example retrieving values from the api gateway proxy request context.
    requestContext, ok := gateway.RequestContext(r.Context())
    if !ok || requestContext.Authorizer["sub"] == nil {
        fmt.Fprint(w, "Hello World from Go")
        return
    }

    userID := requestContext.Authorizer["sub"].(string)
    fmt.Fprintf(w, "Hello %s from Go", userID)
}

