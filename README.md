# relapsium

A simple command-line tool to record and display statistics about habits or relapses.  
You can use a relapse to mark a day where you fell into a bad habit, as well as to mark a day where you forgot to execute a new good habit.  
Basically it shows stats about streaks.  

---

## Features

- Stores streak/relapse data 
- Computes:
  - Max streak
  - Average streak
  - Total relapses
  - Most frequent streak
- Minimal design: Odin + shell I/O.
- No external database or dependencies.

---

## Installation

```sh
git clone https://github.com/el-lob0/relapsium.git
cd relapsium
./install.sh        # or build manually with Odin
```

---

# Usage
  
```
relapsium <COMMAND> [ARGUMENT]


Commands:

new:<name>   Creates a new habit called

relapse:<name> [d]    Adds a relapse after d number of dyas

stat:<name>   Display statistics of habit called name
```
  
Example output:  
  
```
Max streak                     31
Average streak                 9
Total relapses                 7
Frequent streak                8
```

# Contributing

Pull requests and issues are welcome.

