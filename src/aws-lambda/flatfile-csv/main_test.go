package main

import (
	"testing"
)

func TestGrabFields(t *testing.T) {
	t.Log("TestGrabFields")
	output, _ := GrabFields("[{\"cat\": 5, \"dog\": 20}]")
	t.Log(output)    
}

func TestGenerateSetListing(t *testing.T) {
	t.Log("TestGenerateSetListing")
	output := GenerateSetListing([]string{"cow", "pig", "chicken"})
	t.Log(output)
	if output == "" {
		t.Error("Got empty string")
	}
}

func TestSynthesizeSubmitPayload(t *testing.T) {
	t.Log("TestSynthesizeSubmitPayload")
	payload := `{
  "event": {
    "type": "batch:v1:upload",
    "id": "0656d7f4-0362-47af-9db5-1500a917787f",
    "sequence": {
      "length": 1,
      "index": 0
    }
  },
  "data": {
    "customer": {
      "id": "fb85b43d-5d0a-44f5-803e-e148e7598259",
      "userId": "irrelevantSalk",
      "name": "{\"created_by\":\"russelltranbio@gmail.com\",\"timestamp\":\"2021-03-07T08:00:00.000Z\"}",
      "email": null,
      "companyId": null,
      "companyName": null,
      "teamId": 6607,
      "createdAt": "2021-03-01T20:22:52.000Z",
      "updatedAt": "2021-03-08T07:50:19.000Z"
    },
    "meta": {
      "batch": {
        "id": "9eaf6a37-29a1-4820-a067-e8d6e5513cfc"
      },
      "settings": {
        "id": null
      },
      "length": 1
    },
    "validRows": [
      {
        "plant_id": "taco",
        "height_cm": "55"
      }
    ],
    "invalidRows": []
  }
}`
	
	output, err := SynthesizeSubmitPayload(payload)
	if err != nil {
		t.Error(err)
	}
	t.Log(output)


	t.Log("TestSynthesizeSubmitPayload part 2")
	payload = `{
  "event": {
    "type": "batch:v1:upload",
    "id": "0656d7f4-0362-47af-9db5-1500a917787f",
    "sequence": {
      "length": 1,
      "index": 0
    }
  },
  "data": {
    "customer": {
      "id": "fb85b43d-5d0a-44f5-803e-e148e7598259",
      "userId": "irrelevantSalk",
      "name": "{\"created_by\":\"russelltranbio@gmail.com\",\"timestamp\":\"2021-03-07T08:00:00.000Z\"}",
      "email": null,
      "companyId": null,
      "companyName": null,
      "teamId": 6607,
      "createdAt": "2021-03-01T20:22:52.000Z",
      "updatedAt": "2021-03-08T07:50:19.000Z"
    },
    "meta": {
      "batch": {
        "id": "9eaf6a37-29a1-4820-a067-e8d6e5513cfc"
      },
      "settings": {
        "id": null
      },
      "length": 1
    },
    "validRows": [
      {
        "plant_id": "taco",
        "height_cm": ""
      }
    ],
    "invalidRows": []
  }
}`

	output, err = SynthesizeSubmitPayload(payload)
	if err != nil {
		t.Error(err)
	}
	t.Log(output)

}
