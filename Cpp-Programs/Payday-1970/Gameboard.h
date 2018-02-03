#include <vector>
#include "Day.h"
class Gameboard {
	private:
		unsigned int MAX_MONTHES;
		unsigned int die;
		unsigned int player;
		std::vector<int> positions;
		std::vector<Day> calendar;
		sd::vector<Player> players;
		void roll();
		void move();
		void evalDay(Day day);

	public:
		Gameboard(unsigned int MAX, unsigned int numPlayers);
		void takeTurn();
}
