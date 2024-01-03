package main

import (
	"encoding/json"
	"flag"
	"html/template"
	"net/http"
	"os"
	"time"

	"github.com/sirupsen/logrus"
)

const apiURL = "https://russianwarship.rip/api/v2/statistics/latest"

var (
	dataFilePath     = flag.String("json", "../files/data.json", "path to index json file")
	dataHTMLFilePath = flag.String("html", "../files/index.html", "path to output html file")
	templateFilePath = flag.String("htmlTemplate", "./template.html", "path to template html file")
	updateHour       = 6
)

type ApiResponse struct {
	Message string `json:"message"`
	Data    struct {
		Date      string    `json:"date"`
		Day       int       `json:"day"`
		WarStatus WarStatus `json:"war_status"`
		Stats     Stats     `json:"stats"`
		Increase  Stats     `json:"increase"`
	} `json:"data"`
}

type WarStatus struct {
	Code  int    `json:"code"`
	Alias string `json:"alias"`
}

type Stats struct {
	PersonnelUnits           int `json:"personnel_units"`
	Tanks                    int `json:"tanks"`
	ArmouredFightingVehicles int `json:"armoured_fighting_vehicles"`
	// Add other fields as needed
}

var logger = logrus.New()

func fetchData() (*ApiResponse, error) {
	resp, err := http.Get(apiURL)
	if err != nil {
		logger.Error("Error making API request:", err)
		return nil, err
	}
	defer resp.Body.Close()

	var apiResponse ApiResponse
	err = json.NewDecoder(resp.Body).Decode(&apiResponse)
	if err != nil {
		logger.Error("Error decoding API response:", err)
		return nil, err
	}

	return &apiResponse, nil
}

func writeDataToFile(apiResponse *ApiResponse) error {
	file, err := os.Create(*dataFilePath)
	if err != nil {
		logger.Error("Error creating json file:", err)
		return err
	}
	defer file.Close()

	encoder := json.NewEncoder(file)
	encoder.SetIndent("", "  ")

	if err := encoder.Encode(apiResponse); err != nil {
		logger.Error("Error encoding JSON data:", err)
		return err
	}

	logger.Info("Data written to json file successfully.")
	return nil
}

func generateHTML(apiResponse *ApiResponse) error {
	templateData, err := os.ReadFile(*templateFilePath)
	if err != nil {
		logger.Error("Error reading template file:", err)
		return err
	}

	htmlTemplate := template.Must(template.New("template").Parse(string(templateData)))

	htmlFile, err := os.Create(*dataHTMLFilePath)
	if err != nil {
		logger.Error("Error creating HTML file:", err)
		return err
	}
	defer htmlFile.Close()

	err = htmlTemplate.Execute(htmlFile, struct {
		ApiResponse *ApiResponse
	}{
		ApiResponse: apiResponse,
	})
	if err != nil {
		logger.Error("Error generating HTML:", err)
		return err
	}

	logger.Info("HTML generated successfully in ", *dataHTMLFilePath)
	return nil
}

func main() {
	flag.Parse()
	_, err := os.Stat(*dataFilePath)

	if os.IsNotExist(err) {
		apiResponse, err := fetchData()
		if err != nil {
			logger.Fatal("Error fetching data:", err)
			return
		}

		err = writeDataToFile(apiResponse)
		if err != nil {
			logger.Fatal("Error writing data to file:", err)
			return
		}

		err = generateHTML(apiResponse)
		if err != nil {
			logger.Fatal("Error generating HTML:", err)
			return
		}
	} else {
		var apiResponse ApiResponse

		jsonData, err := os.ReadFile(*dataFilePath)
		if err != nil {
			logger.Fatal("Error reading JSON file:", err)
		} else {
			logger.Info("JSON file in ", *dataFilePath, " already exists. Skipping initial data fetch and try to unmarshal file.")
		}

		err = json.Unmarshal(jsonData, &apiResponse)
		if err != nil {
			logger.Fatal("Error unmarshalling JSON:", err)
		}

		err = generateHTML(&apiResponse)
		if err != nil {
			logger.Fatal("Error generating HTML:", err)
			return
		}
	}

	for {
		currentTime := time.Now()
		nextUpdate := time.Date(currentTime.Year(), currentTime.Month(), currentTime.Day(), updateHour, 0, 0, 0, time.Local).Add(24 * time.Hour)

		durationUntilNextUpdate := nextUpdate.Sub(currentTime)
		logger.Info("Data will updated next time at  ", nextUpdate, " in ", durationUntilNextUpdate)

		time.Sleep(durationUntilNextUpdate)

		apiResponse, err := fetchData()
		if err != nil {
			logger.Error("Error fetching data:", err)
			continue
		}

		err = writeDataToFile(apiResponse)
		if err != nil {
			logger.Error("Error writing data to json file:", err)
			continue
		}

		err = generateHTML(apiResponse)
		if err != nil {
			logger.Fatal("Error generating HTML:", err)
			return
		}

		logger.Info("Data updated successfully. HTML (", *dataHTMLFilePath, ") and JSON (", *dataFilePath, ") was succesfully updated")
	}
}
