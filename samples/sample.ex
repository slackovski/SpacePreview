defmodule UserService do
  @moduledoc """
  Fetches and caches user data from the API.
  """

  use GenServer

  @base_url "https://api.example.com"

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def get_user(id), do: GenServer.call(__MODULE__, {:get_user, id})

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:get_user, id}, _from, cache) do
    case Map.get(cache, id) do
      nil ->
        case fetch_user(id) do
          {:ok, user} -> {:reply, {:ok, user}, Map.put(cache, id, user)}
          error       -> {:reply, error, cache}
        end
      user ->
        {:reply, {:ok, user}, cache}
    end
  end

  defp fetch_user(id) do
    url = "#{@base_url}/users/#{id}"
    with {:ok, %{status: 200, body: body}} <- Tesla.get(url),
         {:ok, user} <- Jason.decode(body) do
      {:ok, user}
    else
      _ -> {:error, :not_found}
    end
  end
end
