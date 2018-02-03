#include <string>
class Deal {
	private:
		unsigned int cost;
		unsigned int value;
		unsigned int commission;
		std::string title;
	public:
		Deal(unsigned int c, unsigned int v, unsigned int com, std::string ti) {
			cost = c;
			value = v;
			commission = com;
			title = ti;
		}
		unsigned int cost() const { return cost; }
		unsigned int value() const { return value; }
		unsigned int commission() const { return commission; }
		std::string name() const { return name; }
}
