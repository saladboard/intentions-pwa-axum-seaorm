Will use this to ask questions ask I go? 

Trying to figure out the right orgnaizal structure for the api as it grows. 


I see a few... 



Domain first ? 
src/
├── domain/
│   ├── user/
│   │   ├── routes.rs
│   │   ├── service.rs
│   │   ├── repository.rs
│   │   └── entity.rs
│   │
│   ├── order/
│   │   ├── routes.rs
│   │   ├── service.rs
│   │   └── repository.rs
│
├── db/
├── state.rs
├── app.rs
└── main.rs

classic service repo? 
src/
├── domain/
│   ├── user/
│   │   ├── routes.rs
│   │   ├── service.rs
│   │   ├── repository.rs
│   │   └── entity.rs
│   │
│   ├── order/
│   │   ├── routes.rs
│   │   ├── service.rs
│   │   └── repository.rs
│
├── db/
├── state.rs
├── app.rs
└── main.rs
 
