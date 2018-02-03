**Payday**

This program will attempt to faithfully recreate the 1970s Payday game. This game will be single player where the other three are computers. In the future, I hope to expand this to be P2P, but I presently do not know how C++ deals with network programming.

**Outline**
As for a general outline of what shall be done:
- Create a gameboard/Player/Deal/Mail class
- Create the container to represent a Card Stack (discards + auto-shuffle)
- Assume infinite money in the bank. Maybe later add a bank class.
- give everything a render ability (this shall be a terminal program, latter, I'll attempt to learn how to use the WinAPI to create it for Windows).
- Although the gamboard will have a method referring to the action of taking a turn, this method should be further broken down so that when the "Go back one space" is landed on, the die isn't thrown.

