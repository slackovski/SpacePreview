#include <iostream>
#include <vector>
#include <algorithm>
#include <memory>

template<typename T>
class Stack {
    std::vector<T> data_;

public:
    void push(T value) { data_.push_back(std::move(value)); }

    T pop() {
        if (data_.empty()) throw std::underflow_error("Stack is empty");
        T val = std::move(data_.back());
        data_.pop_back();
        return val;
    }

    [[nodiscard]] bool empty() const noexcept { return data_.empty(); }
    [[nodiscard]] std::size_t size() const noexcept { return data_.size(); }
};

int main() {
    auto stack = std::make_unique<Stack<int>>();
    for (int i : {1, 2, 3, 4, 5}) stack->push(i);

    while (!stack->empty()) {
        std::cout << stack->pop() << '\n';
    }
    return 0;
}
