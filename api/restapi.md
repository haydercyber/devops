# How API IS Working 
Inside this Golang file we want to add the following code
> 1. Create an API service
i have create HTTP-API (e.g. RESTful) service that allows reading some data from moke
```
package main

import (
    "encoding/json"
    "log"
    "net/http"

    "github.com/gorilla/mux"
)

type Person struct {
    ID        string   `json:"id,omitempty"`
    Firstname string   `json:"firstname,omitempty"`
    Lastname  string   `json:"lastname,omitempty"`
    Address   *Address `json:"address,omitempty"`
}

type Address struct {
    City  string `json:"city,omitempty"`
    State string `json:"state,omitempty"`
}

var people []Person

func GetPersonEndpoint(w http.ResponseWriter, req *http.Request) {
    params := mux.Vars(req)
    for _, item := range people {
        if item.ID == params["id"] {
            json.NewEncoder(w).Encode(item)
            return
        }
    }
    json.NewEncoder(w).Encode(&Person{})
}

func GetPeopleEndpoint(w http.ResponseWriter, req *http.Request) {
    json.NewEncoder(w).Encode(people)
}

func CreatePersonEndpoint(w http.ResponseWriter, req *http.Request) {
    params := mux.Vars(req)
    var person Person
    _ = json.NewDecoder(req.Body).Decode(&person)
    person.ID = params["id"]
    people = append(people, person)
    json.NewEncoder(w).Encode(people)
}

func DeletePersonEndpoint(w http.ResponseWriter, req *http.Request) {
    params := mux.Vars(req)
    for index, item := range people {
        if item.ID == params["id"] {
            people = append(people[:index], people[index+1:]...)
            break
        }
    }
    json.NewEncoder(w).Encode(people)
}

func main() {
    router := mux.NewRouter()
    people = append(people, Person{ID: "1", Firstname: "haider", Lastname: "raed", Address: &Address{City: "Baghdad", State: "iraq"}})
	people = append(people, Person{ID: "2", Firstname: "raed", Lastname: "kareem"})
    router.HandleFunc("/people", GetPeopleEndpoint).Methods("GET")
    router.HandleFunc("/people/{id}", GetPersonEndpoint).Methods("GET")
    router.HandleFunc("/people/{id}", CreatePersonEndpoint).Methods("POST")
    router.HandleFunc("/people/{id}", DeletePersonEndpoint).Methods("DELETE")
    log.Fatal(http.ListenAndServe(":9098", router))
}
```
So what is happening in the above code?

The first thing you’ll notice is that we’re importing various dependencies. We’ll be working with JSON data so the encoding/json dependency is required. While we’ll be working with HTTP requests, the net/http dependency is not quite enough. The mux dependency is a helper to not only make endpoints easier to create, but also give us more features. Since this is an external dependency, it must be downloaded like follows:

```
go get github.com/gorilla/mux
```
More information on mux can be found in the official documentation.

With the dependencies imported we want to create the struct objects that will house our data. The data we plan to store will be people data:

```
type Person struct {
    ID        string   `json:"id,omitempty"`
    Firstname string   `json:"firstname,omitempty"`
    Lastname  string   `json:"lastname,omitempty"`
    Address   *Address `json:"address,omitempty"`
}
```
You’ll notice we are defining what properties exist in the struct, but we are also defining tags that describe how the struct will appear as JSON. Inside each of the tags there is an omitempty parameter. This means that if the property is null, it will be excluded from the JSON data rather than showing up as an empty string or value.

Inside the Person struct there is an Address property that is a pointer. This will represent a nested JSON object and it must be a pointer otherwise the omitempty will fail to work. So what does Address look like?

```
type Address struct {
    City  string `json:"city,omitempty"`
    State string `json:"state,omitempty"`
}
```
Again, this is a nested structure that is not too different from the previous.

Because we’re not using a database, we want to create a public variable that is global to the project. This variable will be a slice of Person and contain all the data used in this application.

Our easiest endpoint is probably the GetPeopleEndpoint because it will only return the full person variable to the frontend. Where things start to change is when we want to insert, delete, or get a particular record.

```
func GetPersonEndpoint(w http.ResponseWriter, req *http.Request) {
    params := mux.Vars(req)
    for _, item := range people {
        if item.ID == params["id"] {
            json.NewEncoder(w).Encode(item)
            return
        }
    }
    json.NewEncoder(w).Encode(&Person{})
}
```
n the above GetPersonEndpoint we are trying to get a single record. Using the mux library we can get any parameters that were passed in with the request. We then loop over our global slice and look for any ids that match the id found in the request parameters. If a match is found, use the JSON encoder to display it, otherwise create an empty JSON object.

In reality, your endpoints will communicate with a database and will probably involve a lot less application logic. This is because you’ll be using some form of querying instead.

The CreatePersonEndpoint is a bit different because we’ll be receiving JSON data to work with in the request.

```
func CreatePersonEndpoint(w http.ResponseWriter, req *http.Request) {
    params := mux.Vars(req)
    var person Person
    _ = json.NewDecoder(req.Body).Decode(&person)
    person.ID = params["id"]
    people = append(people, person)
    json.NewEncoder(w).Encode(people)
}
```
In the above we decode the JSON data that was passed in and store it in a Person object. We assign the new object an id based on what mux found and then we append it to our global slice. In the end, our global array will be returned and it should include everything including our newly added piece of data.

In the scenario of this example application, the method for deleting data is a bit different as well.
```
func DeletePersonEndpoint(w http.ResponseWriter, req *http.Request) {
    params := mux.Vars(req)
    for index, item := range people {
        if item.ID == params["id"] {
            people = append(people[:index], people[index+1:]...)
            break
        }
    }
    json.NewEncoder(w).Encode(people)
}
```
In this case, we have the DeletePersonEndpoint looping through the data similarly to the GetPersonEndpoint we saw earlier. The difference is that instead of printing the data, we need to remove it. When the id to be deleted has been found, we can recreate our slice with all data excluding that found at the index.

Finally we end up in our runnable main function that brings the application together.
```
func main() {
router := mux.NewRouter()
	people = append(people, Person{ID: "1", Firstname: "haider", Lastname: "raed", Address: &Address{City: "Baghdad", State: "iraq"}})
	people = append(people, Person{ID: "2", Firstname: "raed", Lastname: "kareem"})
	router.HandleFunc("/people", GetPeopleEndpoint).Methods("GET")
	router.HandleFunc("/people/{id}", GetPersonEndpoint).Methods("GET")
	router.HandleFunc("/people/{id}", CreatePersonEndpoint).Methods("POST")
	router.HandleFunc("/people/{id}", DeletePersonEndpoint).Methods("DELETE")
	router.HandleFunc("/healthcheck", HealthCheck)
	router.Handle("/metrics", promhttp.Handler())
	log.Fatal(http.ListenAndServe(":9098", router))
}
```
In the above code we first create our new router and add two objects to our slice to get things started. Next up we have to create each of the endpoints that will call our endpoint functions. Notice we are using GET, POST, and DELETE where appropriate. We are also defining parameters that can be passed in.

At the very end we define that our server will run on port ``9098``, which at this point brings our project to a close. Run the project and give it a shot. You might need a tool like Postman or cURL to test all the endpoints.

> 2 Iinstrument the code with a prometheus counter/gauge using prometheus
client libraries in this case will use to expose some metrics for cpu and http status and other related to app and the os Exporting Prometheus metrics from Go


Exporting Prometheus metrics is quite straightforward, specially from a Go application - it is a Go project after all, as long as you know the basics of the process. The first step is to understand that Prometheus is not just a monitoring system, but also a time series database. So in order to collect metrics with it, there are three components involved: an application exporting its metrics in Prometheus format, a Prometheus scraper that will grab these metrics in pre-defined intervals and a time series database that will store them for later consumption - usually Prometheus itself, but it’s possible to use other storage backends. The focus here is the first component, the metrics export process.

The first step is to decide which type is more suitable for the metric to be exported. The Prometheus documentation gives a nice explanation about the four types (Counter, Gauge, Histogram and Summary) offered. What’s important to understand is that they are basically a metric name (like job_queue_size), possibly associated with labels (like {type="email"}) that will have a numeric value associated with it (like 10). When scraped, these will be associated with the collection time, which makes it possible, for instance, to later plot these values in a graph. Different types of metrics will offer different facilities to collect the data.

Next, there’s a need to decide when metrics will be observed. The short answer is “synchronously, at collection time”. The application shouldn’t worry about observing metrics in the background and give the last collected values when scraped. The scrape request itself should trigger the metrics observation - it doesn’t matter if this process isn’t instant. The long answer is that it depends, as when monitoring events, like HTTP requests or jobs processed in a queue, metrics will be observed at event time to be later collected when scraped.

The following example will illustrate how metrics can be observed at event time:
```
package main

import (
  "io"
  "log"
  "net/http"

  "github.com/gorilla/mux"
  "github.com/prometheus/client_golang/prometheus"
  "github.com/prometheus/client_golang/prometheus/promhttp"
)

var httpRequestsTotal = prometheus.NewCounter(
  prometheus.CounterOpts{
    Name:        "http_requests_total",
    Help:        "Total number of HTTP requests",
    ConstLabels: prometheus.Labels{"server": "api"},
  },
)

func HealthCheck(w http.ResponseWriter, r *http.Request) {
  httpRequestsTotal.Inc()
  w.WriteHeader(http.StatusOK)
  io.WriteString(w, "OK")
}

func main() {
	prometheus.MustRegister(httpRequestsTotal)
	router := mux.NewRouter()
	people = append(people, Person{ID: "1", Firstname: "haider", Lastname: "raed", Address: &Address{City: "Baghdad", State: "iraq"}})
	people = append(people, Person{ID: "2", Firstname: "raed", Lastname: "kareem"})
	router.HandleFunc("/people", GetPeopleEndpoint).Methods("GET")
	router.HandleFunc("/people/{id}", GetPersonEndpoint).Methods("GET")
	router.HandleFunc("/people/{id}", CreatePersonEndpoint).Methods("POST")
	router.HandleFunc("/people/{id}", DeletePersonEndpoint).Methods("DELETE")
	router.HandleFunc("/healthcheck", HealthCheck)
	router.Handle("/metrics", promhttp.Handler())
	log.Fatal(http.ListenAndServe(":9098", router))
}
```
There’s a single Counter metric called http_requests_total (the “total” suffix is a naming convention) with a constant label {server="api"}. The HealthCheck() HTTP handler itself will call the Inc() method responsible for incrementing this counter, but in a real-life application that would preferable be done in a HTTP middleware. It’s important am only useing perpsong for use liveness probe in k8s deployment 


# Func Test let test all func 
> First will test the get Method GET is used to request data from a specified resource
```
# curl localhost:9098/people/1
```
``output``
```
{"id":"1","firstname":"haider","lastname":"raed","address":{"city":"Baghdad","state":"iraq"}}
```

> Second will test post Method POST is used to send data to a server to create/update a resource

```
# curl -X POST localhost:9098/people/3  -d '{"ID": "3","Firstname": "ahmed" , "lastname": "raed" }'
```
``output``
```
{"id":"3","firstname":"ahmed","lastname":"raed"}
```
> Three will test Delete Method The DELETE method deletes the specified resource.
```
#  curl -X "DELETE" localhost:9098/people/3
```
``output``
```
[{"id":"1","firstname":"haider","lastname":"raed","address":{"city":"Baghdad","state":"iraq"}},{"id":"2","firstname":"raed","lastname":"kareem"}]
```
> let test if it expose metrics at /metrics 

```
# curl localhost:9098/metrics
```
``output``
```
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
go_gc_duration_seconds{quantile="0.75"} 0
go_gc_duration_seconds{quantile="1"} 0
go_gc_duration_seconds_sum 0
go_gc_duration_seconds_count 0
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 8
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.16.12"} 1
# HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
# TYPE go_memstats_alloc_bytes gauge
go_memstats_alloc_bytes 940608
# HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed.
# TYPE go_memstats_alloc_bytes_total counter
go_memstats_alloc_bytes_total 940608
# HELP go_memstats_buck_hash_sys_bytes Number of bytes used by the profiling bucket hash table.
# TYPE go_memstats_buck_hash_sys_bytes gauge
go_memstats_buck_hash_sys_bytes 1.444331e+06
# HELP go_memstats_frees_total Total number of frees.
# TYPE go_memstats_frees_total counter
go_memstats_frees_total 365
# HELP go_memstats_gc_cpu_fraction The fraction of this program's available CPU time used by the GC since the program started.
# TYPE go_memstats_gc_cpu_fraction gauge
go_memstats_gc_cpu_fraction 0
# HELP go_memstats_gc_sys_bytes Number of bytes used for garbage collection system metadata.
# TYPE go_memstats_gc_sys_bytes gauge
go_memstats_gc_sys_bytes 4.029992e+06
# HELP go_memstats_heap_alloc_bytes Number of heap bytes allocated and still in use.
# TYPE go_memstats_heap_alloc_bytes gauge
go_memstats_heap_alloc_bytes 940608
# HELP go_memstats_heap_idle_bytes Number of heap bytes waiting to be used.
# TYPE go_memstats_heap_idle_bytes gauge
go_memstats_heap_idle_bytes 6.4626688e+07
# HELP go_memstats_heap_inuse_bytes Number of heap bytes that are in use.
# TYPE go_memstats_heap_inuse_bytes gauge
go_memstats_heap_inuse_bytes 2.08896e+06
# HELP go_memstats_heap_objects Number of allocated objects.
# TYPE go_memstats_heap_objects gauge
go_memstats_heap_objects 5096
# HELP go_memstats_heap_released_bytes Number of heap bytes released to OS.
# TYPE go_memstats_heap_released_bytes gauge
go_memstats_heap_released_bytes 6.4561152e+07
# HELP go_memstats_heap_sys_bytes Number of heap bytes obtained from system.
# TYPE go_memstats_heap_sys_bytes gauge
go_memstats_heap_sys_bytes 6.6715648e+07
# HELP go_memstats_last_gc_time_seconds Number of seconds since 1970 of last garbage collection.
# TYPE go_memstats_last_gc_time_seconds gauge
go_memstats_last_gc_time_seconds 0
# HELP go_memstats_lookups_total Total number of pointer lookups.
# TYPE go_memstats_lookups_total counter
go_memstats_lookups_total 0
# HELP go_memstats_mallocs_total Total number of mallocs.
# TYPE go_memstats_mallocs_total counter
go_memstats_mallocs_total 5461
# HELP go_memstats_mcache_inuse_bytes Number of bytes in use by mcache structures.
# TYPE go_memstats_mcache_inuse_bytes gauge
go_memstats_mcache_inuse_bytes 4800
# HELP go_memstats_mcache_sys_bytes Number of bytes used for mcache structures obtained from system.
# TYPE go_memstats_mcache_sys_bytes gauge
go_memstats_mcache_sys_bytes 16384
# HELP go_memstats_mspan_inuse_bytes Number of bytes in use by mspan structures.
# TYPE go_memstats_mspan_inuse_bytes gauge
go_memstats_mspan_inuse_bytes 45288
# HELP go_memstats_mspan_sys_bytes Number of bytes used for mspan structures obtained from system.
# TYPE go_memstats_mspan_sys_bytes gauge
go_memstats_mspan_sys_bytes 49152
# HELP go_memstats_next_gc_bytes Number of heap bytes when next garbage collection will take place.
# TYPE go_memstats_next_gc_bytes gauge
go_memstats_next_gc_bytes 4.473924e+06
# HELP go_memstats_other_sys_bytes Number of bytes used for other system allocations.
# TYPE go_memstats_other_sys_bytes gauge
go_memstats_other_sys_bytes 965877
# HELP go_memstats_stack_inuse_bytes Number of bytes in use by the stack allocator.
# TYPE go_memstats_stack_inuse_bytes gauge
go_memstats_stack_inuse_bytes 393216
# HELP go_memstats_stack_sys_bytes Number of bytes obtained from system for stack allocator.
# TYPE go_memstats_stack_sys_bytes gauge
go_memstats_stack_sys_bytes 393216
# HELP go_memstats_sys_bytes Number of bytes obtained from system.
# TYPE go_memstats_sys_bytes gauge
go_memstats_sys_bytes 7.36146e+07
# HELP go_threads Number of OS threads created.
# TYPE go_threads gauge
go_threads 6
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{server="api"} 1
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 0.51
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 262144
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 9
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 1.9079168e+07
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.64767189674e+09
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 7.28727552e+08
# HELP process_virtual_memory_max_bytes Maximum amount of virtual memory available in bytes.
# TYPE process_virtual_memory_max_bytes gauge
process_virtual_memory_max_bytes 1.8446744073709552e+19
# HELP promhttp_metric_handler_requests_in_flight Current number of scrapes being served.
# TYPE promhttp_metric_handler_requests_in_flight gauge
promhttp_metric_handler_requests_in_flight 1
# HELP promhttp_metric_handler_requests_total Total number of scrapes by HTTP status code.
# TYPE promhttp_metric_handler_requests_total counter
promhttp_metric_handler_requests_total{code="200"} 0
promhttp_metric_handler_requests_total{code="500"} 0
promhttp_metric_handler_requests_total{code="503"} 0
```

> test healthcheck 
the use of this is only for liveness probes in k8s 

```
# curl  -v localhost:9098/healthcheck
```
``output``
```
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 9098 (#0)
> GET /healthcheck HTTP/1.1
> Host: localhost:9098
> User-Agent: curl/7.61.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Sat, 19 Mar 2022 13:12:54 GMT
< Content-Length: 2
< Content-Type: text/plain; charset=utf-8
<
* Connection #0 to host localhost left intact
```
Next: [Dockerize the app with multe stage of container](../docker/docker.md)