package main

import (
    "fmt"
    "log"
    "net/http"
    "time"
)

func main() {
    http.HandleFunc("/", handleRoot)
    http.HandleFunc("/health", handleHealth)
    
    log.Println("🚀 Server starting on port 8080...")
    if err := http.ListenAndServe(":8080", nil); err != nil {
        log.Fatal(err)
    }
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello from Go Multi-Stage Build! 🐹\n")
    fmt.Fprintf(w, "Time: %s\n", time.Now().Format(time.RFC3339))
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    fmt.Fprintf(w, "OK")
}
