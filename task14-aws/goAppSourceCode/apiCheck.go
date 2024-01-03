package main

import (
	"encoding/json"
	"html/template"
	"net/http"
	"os"
	"time"

	"github.com/sirupsen/logrus"
)

const apiURL = "https://russianwarship.rip/api/v2/statistics/latest"

var (
	updateHour = 6
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

func fetchData(logger *logrus.Logger) (*ApiResponse, error) {
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

func writeDataToFile(apiResponse *ApiResponse, logger *logrus.Logger, dataFilePath string) error {
	file, err := os.Create(dataFilePath)
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

func generateHTML(apiResponse *ApiResponse, logger *logrus.Logger, dataFilePath, templateFilePath, filePath string) error {
	templateData, err := os.ReadFile(templateFilePath)
	if err != nil {
		logger.Error("Error reading template file:", err)
		return err
	}

	htmlTemplate := template.Must(template.New("template").Parse(string(templateData)))

	htmlFile, err := os.Create(filePath)
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

	logger.Info("HTML generated successfully in ", filePath)
	return nil
}

func checkAPI(logger *logrus.Logger, dataFilePath, templateFilePath, filePath string) {
	_, err := os.Stat(dataFilePath)

	if os.IsNotExist(err) {
		apiResponse, err := fetchData(logger)
		if err != nil {
			logger.Fatal("Error fetching data:", err)
			return
		}

		err = writeDataToFile(apiResponse, logger, dataFilePath)
		if err != nil {
			logger.Fatal("Error writing data to file:", err)
			return
		}

		err = generateHTML(apiResponse, logger, dataFilePath, templateFilePath, filePath)
		if err != nil {
			logger.Fatal("Error generating HTML:", err)
			return
		}
	} else {
		var apiResponse ApiResponse

		jsonData, err := os.ReadFile(dataFilePath)
		if err != nil {
			logger.Fatal("Error reading JSON file:", err)
		} else {
			logger.Info("JSON file in ", dataFilePath, " already exists. Skipping initial data fetch and try to unmarshal file.")
		}

		err = json.Unmarshal(jsonData, &apiResponse)
		if err != nil {
			logger.Fatal("Error unmarshalling JSON:", err)
		}

		err = generateHTML(&apiResponse, logger, dataFilePath, templateFilePath, filePath)
		if err != nil {
			logger.Fatal("Error generating HTML:", err)
			return
		}
	}

	for {
		currentTime := time.Now()
		nextUpdate := time.Date(currentTime.Year(), currentTime.Month(), currentTime.Day(), updateHour, 0, 0, 0, time.Local).Add(24 * time.Hour)

		durationUntilNextUpdate := nextUpdate.Sub(currentTime)
		logger.Info("Data will be updated next time at ", nextUpdate, " in ", durationUntilNextUpdate)

		time.Sleep(durationUntilNextUpdate)

		apiResponse, err := fetchData(logger)
		if err != nil {
			logger.Error("Error fetching data:", err)
			continue
		}

		err = writeDataToFile(apiResponse, logger, dataFilePath)
		if err != nil {
			logger.Error("Error writing data to json file:", err)
			continue
		}

		err = generateHTML(apiResponse, logger, dataFilePath, templateFilePath, filePath)
		if err != nil {
			logger.Fatal("Error generating HTML:", err)
			return
		}

		logger.Info("Data updated successfully. HTML (", filePath, ") and JSON (", dataFilePath, ") was successfully updated")
	}
}
