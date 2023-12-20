package main

import (
	"errors"
	"flag"
	"net/http"
	"os"
	"strings"

	logstash_logger "github.com/KaranJagtiani/go-logstash"
	"github.com/labstack/echo-contrib/echoprometheus"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/sirupsen/logrus"
)

const (
	httpPort       = ":80"
	metricsPort    = ":9110"
	logMetricsPort = ":8081"
)

// AppConfig структура для зберігання конфігурації додатку
type AppConfig struct {
	AppPort        string
	MetricsPort    string
	LogMetricsPort string
	FilePath       string
	CustomLogger   *logrus.Logger
}

func main() {
	filePath := flag.String("p", "./files/index.html", "path to index html file")
	flag.Parse()

	config := AppConfig{
		AppPort:        httpPort,
		MetricsPort:    metricsPort,
		LogMetricsPort: logMetricsPort,
		FilePath:       *filePath,
		CustomLogger:   setupLogger(),
	}

	startApp(config)
}

func startApp(config AppConfig) {
	config.CustomLogger.Info("Starting server on port", config.AppPort)
	app := setupEchoApp(config)
	metrics := echo.New()
	metrics.GET("/metrics", echoprometheus.NewHandler())
	config.CustomLogger.Info("Starting metrics server on port", config.MetricsPort)
	go startServer(metrics, config.MetricsPort)

	logger := logstash_logger.Init("logstash", 5228, "tcp", 5)

	payload := map[string]interface{}{
		"message": "TEST_MSG",
		"error":   false,
	}

	logger.Log(payload)   // Generic log
	logger.Info(payload)  // Adds "severity": "INFO"
	logger.Debug(payload) // Adds "severity": "DEBUG"
	logger.Warn(payload)  // Adds "severity": "WARN"
	logger.Error(payload) // Adds "severity": "ERROR"

	setupRoutes(app, config)
	config.CustomLogger.Info("Main server started. Listening on port", config.AppPort)
	startServer(app, config.AppPort)
}

func setupEchoApp(config AppConfig) *echo.Echo {
	app := echo.New()
	app.Use(middleware.Logger())
	app.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogURI:    true,
		LogStatus: true,
		LogValuesFunc: func(c echo.Context, values middleware.RequestLoggerValues) error {
			config.CustomLogger.WithFields(logrus.Fields{
				"URI":    values.URI,
				"status": values.Status,
			}).Info("request")
			return nil
		},
	}))
	customCounter := setupCustomCounter(config)
	app.Use(setupPrometheusMiddleware(customCounter, config))
	return app
}

func setupLogger() *logrus.Logger {
	logger := logrus.New()
	logger.SetFormatter(&logrus.TextFormatter{})
	logger.SetOutput(os.Stdout)
	return logger
}

func setupCustomCounter(config AppConfig) prometheus.Counter {
	counter := prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "custom_requests_total",
			Help: "How many HTTP requests processed, partitioned by status code and HTTP method.",
		},
	)
	if err := prometheus.Register(counter); err != nil {
		config.CustomLogger.Fatal(err)
	}
	return counter
}

func setupPrometheusMiddleware(counter prometheus.Counter, config AppConfig) echo.MiddlewareFunc {
	return echoprometheus.NewMiddlewareWithConfig(echoprometheus.MiddlewareConfig{
		AfterNext: func(c echo.Context, err error) {
			counter.Inc()
		},
		Skipper: func(c echo.Context) bool {
			return !strings.HasPrefix(c.Path(), "/")
		},
	})
}

func startServer(app *echo.Echo, port string) {
	if err := app.Start(port); err != nil && !errors.Is(err, http.ErrServerClosed) {
		logrus.Fatal(err)
	}
}

func setupRoutes(app *echo.Echo, config AppConfig) {
	config.CustomLogger.Info("Setting up routes with file", config.FilePath)
	app.File("/", config.FilePath)
	config.CustomLogger.Info("Routes set up successfully")
}
