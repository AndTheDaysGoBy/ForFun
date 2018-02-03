#include <string>
#include <vector>
#include "Deal.h"
#include "Mail.h"
class Player {
	private:
		unsigned int funds;
		int investments; //savings/loans
		bool carInsurance;
		bool healthInsurance;
		unsigned int lottery;
		std::vector<Mail> bills;
		std::vector<Deal> deals;
		unsigned in month;
	public:
		void transfer(int);
		void processBills();
		void redeemLottery();
		void buyCarInsurance();
		void carInsured();
		void buyHealthInsurance();
		void healthInsured();
		void sellDeal(const Deal&);
		void buyDeal(Deal&);
		void payday();
		void savings(unsigned int);
		void loans(unsigned int);
}
