#include <queue>
#include <list>
template <class T>
class CardStack {
	private:
		std::queue<T> cards;
		std::list<T> discard;
		//Might want same container type to just re-assign pointers on shuffle.
	public:
		T draw();
		void toss(T);
}
