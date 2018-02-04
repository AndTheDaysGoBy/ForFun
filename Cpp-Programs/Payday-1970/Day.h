#ifndef DAY_H
#define DAY_H

#include <string>
#include "day_types.h"
class Day {
	private:
		Event type;
		std::string description;
		int value;
	public:
		int value() { return value; }
		std::string description() { return description; }
		Event type() { return type; }		
}

#endif
