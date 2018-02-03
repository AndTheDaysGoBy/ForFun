#include <string>
#include "mail_types.h"
class Mail {
	private:
		Type type;
		std::string title;
		std::string description;
		int value;

	public:
		Mail(Type t, std::string ti, std::string desc, int val) {
			type = t;
			title = ti;
			
		}
		Type type() const { return type; }
		std::string title() const { return title; }
		std::string description() const { return description; }
		int value() const { return value; }
}
