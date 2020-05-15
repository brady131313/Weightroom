defmodule WeightroomWeb.UserWeightController do
  use WeightroomWeb, :controller

  alias Weightroom.Accounts
  alias Weightroom.Accounts.UserWeight

  def index(conn, %{"user_id" => user_id}) do
    user_weights = Accounts.list_user_weights(user_id)
    render(conn, "index.json", user_weights: user_weights)
  end

  def show(conn, %{"id" => id}) do
    user_weight = Accounts.get_user_weight!(id)
    render(conn, "show.json", user_weight: user_weight)
  end

end
