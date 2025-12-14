package main
import "core:os"
import "base:runtime"
import "core:os/os2"
import "core:c"
import "core:strconv"
import "core:fmt"
import "core:strings"





parse_input :: proc(numbers: string) -> []int {
  output: [dynamic]int
  str_nums := strings.split(numbers, "\n")

  for digit in str_nums {
    num, ok := strconv.parse_int(digit)
    append_elem(&output, num)
  }
  
  // Because the 'cat' command adds a newline, the slice has an extra element
  pop(&output)

  const_output: []int = output[:]
  return const_output
}


new_relapse :: proc(days: int, name: string, path: string) -> int {

  full_path := fmt.tprintf("%s/%s.txt", path, name)
  fmt.printfln(full_path)

  // echo appends on newline, so the sep is a \n
  cmd := fmt.tprintf("echo \"%d\" >> %s", days, full_path)

  state, stdout, stderr, err := os2.process_exec({command={"sh", "-c", cmd}}, context.allocator)

  if stderr != nil {
    fmt.eprintln("Error adding data to file: ", stderr)
    return 1
  }
  return 0
}


new_habit :: proc(name: string, path: string) -> int{

  full_path := fmt.tprintf("%s/%s.txt", path, name)
  fmt.printfln(full_path)

  state, stdout, stderr, err := os2.process_exec({command={"touch", full_path}}, context.allocator)

  if stderr != nil {
    fmt.eprintln("Error creating habit file: ", err)
    return 1
  }

  return 0
}

spaces :: proc(n: int) -> string {
  spaces : string
  for i:=0; i<n; i+=1 {
    spaces = fmt.tprintf("%s ")
  }
  return spaces
}

display_stats :: proc(name: string, path: string) -> int {

  full_path := fmt.tprintf("%s/%s.txt", path, name)

  cmd := fmt.tprintf("cat %s", full_path)

  state, stdout, stderr, err := os2.process_exec({command={"sh", "-c", cmd}}, context.allocator)

  if stderr != nil {
    fmt.eprintln("Error reading habit file: ", err)
    return 1
  }
  
  numbers := parse_input(fmt.tprintf("%s", stdout))

  max := 0
  total_days := 0
  frequency := make(map[int]int)
  total_relapse := len(numbers)

  if total_relapse == 0 { fmt.eprintln("No relapses recorded for that name."); return 1 }

  max = numbers[0]
  for n in numbers {
    if n > max { max = n }
    total_days += n

    frequency[n] += 1
  }

  max_frequency := -1
  mf := -1

  for n, t in frequency {
    if t > max_frequency {
      max_frequency = t
      mf = n
    }
  }

  padding := 25

  fmt.printfln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	fmt.printfln(
		"   Max streak %*s     %d               ",
		padding - len("Max streak"),
		" ",
		max
	)
  fmt.printfln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	fmt.printfln(
		"   Average streak %*s     %.2f               ",
		padding - len("Average streak"),
		" ",
		f64(total_days)/f64(total_relapse)
	)
  fmt.printfln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	fmt.printfln(
		"   Total relapses %*s     %d               ",
		padding - len("Total relapses"),
		" ",
		total_relapse
	)
  fmt.printfln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	fmt.printfln(
		"   Frequent streak %*s     %d               ",
		padding - len("Frequent streak"),
		" ",
    mf
	)
  fmt.printfln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  return 0
}

main :: proc() {

  command_warning := "Invalid command. \n \nUsage: \n  relapsium <COMMAND> [ARGUMENT] \n \nCommands: \n  new:<name>   Creates a new habit database with the given `name` \n  relapse:<name> d    Adds a relapse mark to the database called `name` at d number of days since the last relapse \n  stat:<name>   Display statistics of a specific habit \n"


  if len(os.args) < 2 {
    fmt.eprintfln(command_warning)
    os.exit(0)
  }

  home := os.get_env("HOME")


  dir_path := fmt.tprintf("%s/.relapsium", home)
  if !os.is_dir(dir_path) {
    err := os.make_directory(dir_path, 0o777)
    if err != os.ERROR_NONE {
      fmt.eprintfln("Failed to create directory:", dir_path, "error:", err)
      os.exit(1)
    }
  }



  arg_string := os.args[1]
  parts := strings.split(arg_string, ":")
  
  if len(parts) == 1 {
    fmt.eprintfln(command_warning)
    os.exit(1)
  }


  switch  parts[0] {
  case "new": {
    result := new_habit(parts[1], dir_path)
    if result==1 { fmt.printfln("I/O error... Exiting."); os2.exit(2) }
  }

  case "relapse": {
    if len(os.args) == 3 {
      num_of_days, ok := strconv.parse_int(os.args[2])
      if !ok {
        fmt.println("Error: Days have to be a whole number.", os.args[2])
        os.exit(-1) 
      }
      // OK !
      result := new_relapse(num_of_days, parts[1], dir_path)
      if result==1 { fmt.printfln("I/O error... Exiting."); os2.exit(2) }

    } else {
        fmt.println("Error: Need to specify days.", os.args[2])
    }
  }

  case "stat": {
    result := display_stats(parts[1], dir_path)
    if result==1 { fmt.printfln("I/O error... Exiting."); os2.exit(2) }
  }

  case "help": {
    fmt.eprintfln(command_warning)
  }

  case: fmt.eprintfln(command_warning)
    os.exit(1)
  }
}
