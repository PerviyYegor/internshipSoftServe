package main

import (
	"errors"
	"flag"
	"net/http"
	"os"
	"strings"

	"github.com/ic2hrmk/lokigrus"
	"github.com/labstack/echo-contrib/echoprometheus"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/sirupsen/logrus"
)

const (
	httpPort    = ":80"
	metricsPort = ":9110"
)

func main() {
	filePath := flag.String("p", "./files/index.html", "path to index html file")
	lokiURL := flag.String("l", "", "address of loki server")
	flag.Parse()

	logger := setupLogger()

	if *lokiURL != "" {
		logger.Info("Trying to start push logs to loki server")
		initLokiSupport(logger, *lokiURL, map[string]string{"app": "go-app"})
	} else {
		logger.Warning("Loki URL didn't provide. You can do it with -l flag")
	}

	logger.Info("Starting server on port", httpPort)
	app := setupEchoApp(logger, *filePath)
	metrics := echo.New()
	metrics.GET("/metrics", echoprometheus.NewHandler())
	logger.Info("Starting metrics server on port", metricsPort)
	go startServer(metrics, metricsPort)

	setupRoutes(app, logger, *filePath)
	logger.Info("Main server started. Listening on port", httpPort)
	startServer(app, httpPort)
}

func initLokiSupport(logger *logrus.Logger, lokiAddress string, appLabels map[string]string) error {
	promtailHook, err := lokigrus.NewPromtailHook(lokiAddress, appLabels)
	if err != nil {
		logger.Fatal(err)
		return err
	}

	logger.AddHook(promtailHook)

	return nil
}

func setupEchoApp(logger *logrus.Logger, filePath string) *echo.Echo {
	app := echo.New()
	app.Use(middleware.Logger())

	app.Use(func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			c.Set("realIP", c.Request().RemoteAddr)
			return next(c)
		}
	})
	app.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogURI:      true,
		LogStatus:   true,
		LogRemoteIP: true,
		LogValuesFunc: func(c echo.Context, values middleware.RequestLoggerValues) error {
			logger.WithFields(logrus.Fields{
				"IP":     values.RemoteIP,
				"URI":    values.URI,
				"status": values.Status,
			}).Info("request")
			return nil
		},
	}))
	customCounter := setupCustomCounter(logger)
	app.Use(setupPrometheusMiddleware(customCounter, logger))
	return app
}

func setupLogger() *logrus.Logger {
	logger := logrus.New()
	logger.SetFormatter(&logrus.TextFormatter{})
	logger.SetOutput(os.Stdout)
	return logger
}

func setupCustomCounter(logger *logrus.Logger) prometheus.Counter {
	counter := prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "custom_requests_total",
			Help: "How many HTTP requests processed, partitioned by status code and HTTP method.",
		},
	)
	if err := prometheus.Register(counter); err != nil {
		logger.Fatal(err)
	}
	return counter
}

func setupPrometheusMiddleware(counter prometheus.Counter, logger *logrus.Logger) echo.MiddlewareFunc {
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

func setupRoutes(app *echo.Echo, logger *logrus.Logger, filePath string) {
	logger.Info("Setting up routes with file", filePath)
	app.File("/", filePath)
	logger.Info("Routes set up successfully")
}
