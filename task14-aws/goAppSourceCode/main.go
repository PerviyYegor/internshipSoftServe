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
	app := setupEcho()
	customCounter := setupCustomCounter()
	app.Use(setupPrometheusMiddleware(customCounter))

	go startMetricsServer()

	setupRoutes(app)
	startMainServer(app)
}

func setupEcho() *echo.Echo {
	return echo.New()
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

func startMetricsServer() {
	metrics := echo.New()
	metrics.GET("/metrics", echoprometheus.NewHandler())
	if err := metrics.Start(metricsPort); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
}

func startMainServer(app *echo.Echo) {
	if err := app.Start(httpPort); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
}

func setupRoutes(app *echo.Echo) {
	app.File("/", *filePath)
}
