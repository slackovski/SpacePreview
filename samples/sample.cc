#include <iostream>
#include <string>
#include <vector>

class Logger {
private:
  std::vector<std::string> logs;

public:
  void log(const std::string& message) {
    logs.push_back(message);
    std::cout << "[LOG] " << message << std::endl;
  }

  void printAll() const {
    for (const auto& msg : logs) {
      std::cout << msg << std::endl;
    }
  }
};

int main() {
  Logger logger;
  logger.log("Application started");
  logger.log("Processing data");
  logger.printAll();
  return 0;
}
