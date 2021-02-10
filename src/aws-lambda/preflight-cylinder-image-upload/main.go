package main
 
import (
        "fmt"
        "log"
        "os"
        "database/sql"
        "github.com/aws/aws-lambda-go/lambda"

        _ "github.com/lib/pq"
)

var (
	host string     = os.Getenv("host")
	port string        = os.Getenv("port")
	user string     = os.Getenv("user")
	password string = os.Getenv("password")
	database string = os.Getenv("database")
)
var db *sql.DB

type MyEvent struct {
    QrCode string `json:"qr_code"`
    UploadDeviceId string `json:"upload_device_id"`
}
 
type MyResponse struct {
	QrCodeValid bool `json:"qr_code_valid:"`
}

func CheckError(err error) {
    if err != nil {
        log.Fatal(err)
    }
}

func init() {
	psqlconn := fmt.Sprintf("host=%s port=%s user=%s "+
    	"password=%s dbname=%s sslmode=disable",
    	host, port, user, password, database)
    var err error
	db, err = sql.Open("postgres", psqlconn)
	CheckError(err)
}

func HandleLambdaEvent(event MyEvent) (MyResponse, error) {
	var count int
	row := db.QueryRow(`SELECT COUNT(*) FROM "plant" WHERE "plant_id" = $1 OR "container_id" = $1`, event.QrCode)
	err := row.Scan(&count)
	CheckError(err)

	response := MyResponse{(count > 0)}
    return response, nil
}
 
func main() {
        lambda.Start(HandleLambdaEvent)
}
