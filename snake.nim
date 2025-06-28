# scuffed snake in the terminal lol

import os, strutils, random, times, terminal, threadpool

type
  Coord = tuple[x, y: int]
  Direction = enum Up, Down, Left, Right

var
  snake: seq[Coord]
  food: Coord
  dir: Direction = Right
  nextDir: Direction = Right
  width = 40
  height = 20
  gameOver = false
  score = 0

proc clearScreen() =
  stdout.write "\e[2J\e[H"

proc moveCursor(x, y: int) =
  stdout.write "\e[", y, ";", x, "H"

proc drawBorder() =
  for y in 0..height:
    for x in 0..width:
      if y == 0 or y == height or x == 0 or x == width:
        moveCursor(x + 1, y + 1)
        stdout.write "#"

proc drawSnake() =
  for i, s in snake:
    moveCursor(s.x + 1, s.y + 1)
    if i == 0:
      stdout.write("O")
    else:
      stdout.write("o")

proc drawFood() =
  moveCursor(food.x + 1, food.y + 1)
  stdout.write("*")

proc generateFood() =
  while true:
    let newFood = (rand(1..width-1), rand(1..height-1))
    if newFood notin snake:
      food = newFood
      break

proc updateSnake() =
  dir = nextDir
  
  var newHead = snake[0]
  case dir
  of Up:    newHead.y -= 1
  of Down:  newHead.y += 1
  of Left:  newHead.x -= 1
  of Right: newHead.x += 1
  
  if newHead in snake or newHead.x == 0 or newHead.x == width or newHead.y == 0 or newHead.y == height:
    gameOver = true
    return
  
  snake.insert(newHead, 0)
  if newHead == food:
    inc score
    generateFood()
  else:
    discard snake.pop()

proc inputHandler() {.thread.} =
  while not gameOver:
    let inputChar = getch()
    case inputChar
    of 'w', 'W':
      if dir != Down: nextDir = Up
    of 's', 'S':
      if dir != Up: nextDir = Down
    of 'a', 'A':
      if dir != Right: nextDir = Left
    of 'd', 'D':
      if dir != Left: nextDir = Right
    of 'q', 'Q':
      gameOver = true
    else:
      discard

proc main() =
  randomize()
  clearScreen()
  snake = @[(width div 2, height div 2)]
  generateFood()
  
  var inputThread: Thread[void]
  createThread(inputThread, inputHandler)
  
  while not gameOver:
    updateSnake()
    
    if not gameOver:
      clearScreen()
      drawBorder()
      drawFood()
      drawSnake()
      moveCursor(1, height + 2)
      echo "Score: ", score
      moveCursor(1, height + 3)
      echo "Controls: WASD to move, Q to quit"
    
    sleep(150)
  
  joinThread(inputThread)
  
  moveCursor(1, height + 4)
  echo "Game Over! Final Score: ", score

main()
