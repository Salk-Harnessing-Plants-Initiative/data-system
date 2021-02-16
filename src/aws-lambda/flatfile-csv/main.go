package main
 
import (
    "fmt"
    "log"
    "os"
    "net/http"
    "database/sql"
    "github.com/aws/aws-lambda-go/lambda"
    "github.com/aws/aws-lambda-go/events"

    _ "github.com/lib/pq"
)

var (
	host string     = os.Getenv("host")
	port string     = os.Getenv("port")
	user string     = os.Getenv("user")
	password string = os.Getenv("password")
	database string = os.Getenv("database")
    apikey string = os.Getenv("apikey")
)
var db *sql.DB


func CheckError(err error) {
    if err != nil {
        log.Fatal(err)
    }
}

func init() {
	psqlconn := fmt.Sprintf("host=%s port=%s user=%s " +
    	"password=%s dbname=%s sslmode=disable",
    	host, port, user, password, database)
    var err error
	db, err = sql.Open("postgres", psqlconn)
	CheckError(err)
}

func HandleLambdaEvent(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
    /*
	var count int
	row := db.QueryRow(`SELECT COUNT(*) FROM "plant" WHERE "plant_id" = $1 OR "container_id" = $1`, event.QrCode)
	err := row.Scan(&count)
	CheckError(err)
	response := MyResponse{(count > 0)}
    */
    // Compare against custom apikey we stored in Lambda env variable
    clientApikey, ok := request.QueryStringParameters["apikey"]
    if !ok || apikey != clientApikey {
        fmt.Println("BAD ", ok, clientApikey)
        return events.APIGatewayProxyResponse{
            StatusCode: http.StatusForbidden,
            Body:       "Invalid API key",
        }, nil
    }

    fmt.Println(request)
    fmt.Println("Hello world people")
    return events.APIGatewayProxyResponse{
        StatusCode: http.StatusOK,
        Body:       "Howdy mc howdy",
    }, nil
}
 
func main() {
    lambda.Start(HandleLambdaEvent)
}
