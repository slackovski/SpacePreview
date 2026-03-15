require "net/http"
require "json"

User = Data.define(:id, :name, :email)

class UserService
  def initialize
    @cache = {}
  end

  def get_user(id)
    @cache[id] ||= fetch_from_api(id)
  end

  private

  def fetch_from_api(id)
    uri = URI("https://api.example.com/users/#{id}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body, symbolize_names: true)
    User.new(**data)
  rescue StandardError => e
    warn "Failed to fetch user #{id}: #{e.message}"
    nil
  end
end

svc = UserService.new
if (user = svc.get_user(1))
  puts "Hello, #{user.name}!"
else
  puts "User not found"
end
