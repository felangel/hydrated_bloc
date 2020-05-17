package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	fmt.Println("End point ready")
	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	http.HandleFunc("/dump", DataDump)
	hsrv := &http.Server{
		Addr:    ":9091",
		Handler: nil, // use default mux
	}
	go func() {
		if err := hsrv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()
	log.Print("Server Started")
	<-done
	log.Print("Server Stopped")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := hsrv.Shutdown(ctx); err != nil {
		log.Fatalf("Server Shutdown Failed:%+v", err)
	}
}

// DataDump is an endpoint for bench data
func DataDump(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Println(err)
	}
	defer r.Body.Close()
	var req struct {
		Title string `json:"title"`
	}
	err = json.Unmarshal(body, &req)
	if err != nil {
		log.Println(err)
	}
	fmt.Println(req.Title)
	// fmt.Println(string(body))
	w.WriteHeader(200)
	err = ioutil.WriteFile(req.Title+".json", body, 0644)
	if err != nil {
		panic(err)
	}
}
