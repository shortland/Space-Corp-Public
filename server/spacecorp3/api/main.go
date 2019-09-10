package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/", rootPage).Methods("GET")
	router.HandleFunc("/auth/login", ipacLogin).Methods("POST")
	router.HandleFunc("/auth/register", ipacRegister).Methods("POST")
	log.Fatal(http.ListenAndServe(":8080", router))
}

func rootPage(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "starting something :]")
}

func ipacLogin(w http.ResponseWriter, r *http.Request) {
	email := mux.Vars(r)["email"]
	password := mux.Vars(r)["password"]

	fmt.Fprintf(w, "Login\nemail: %s, password: %s", email, password)
}

func ipacRegister(w http.ResponseWriter, r *http.Request) {
	email := mux.Vars(r)["email"]
	password := mux.Vars(r)["password"]

	fmt.Fprintf(w, "Register\nemail: %s, password: %s", email, password)
}
