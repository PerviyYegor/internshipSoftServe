package main

import (
	"errors"
	"flag"
	"log"
	"net/http"
	"strings"

	"github.com/labstack/echo-contrib/echoprometheus"
	"github.com/labstack/echo/v4"
	"github.com/prometheus/client_golang/prometheus"
)

const (
	httpPort    = ":80"
	metricsPort = ":9110"
)

var filePath = flag.String("p", "./files/index.html", "path to index html file")

func main() {
	log.Println("Starting server on port", httpPort)
	app := echo.New()
	customCounter := setupCustomCounter()
	app.Use(setupPrometheusMiddleware(customCounter))

	metrics := echo.New()
	metrics.GET("/metrics", echoprometheus.NewHandler())

	log.Println("Starting metrics server on port", metricsPort)
	go startServer(metrics, metricsPort)

	setupRoutes(app)
	log.Println("Main server started. Listening on port", httpPort)
	startServer(app, httpPort)
}

func setupCustomCounter() prometheus.Counter {
	counter := prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "custom_requests_total",
			Help: "How many HTTP requests processed, partitioned by status code and HTTP method.",
		},
	)
	if err := prometheus.Register(counter); err != nil {
		log.Fatal(err)
	}
	return counter
}

func setupPrometheusMiddleware(counter prometheus.Counter) echo.MiddlewareFunc {
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
		log.Fatal(err)
	}
}

func setupRoutes(app *echo.Echo) {
	log.Println("Setting up routes with file", *filePath)
	app.File("/", *filePath)
	log.Println("Routes set up successfully")
}
