defmodule WeightroomWeb.UserWeightController do
  use WeightroomWeb, :controller
  use WeightroomWeb.GuardedController

  alias Weightroom.Accounts

  action_fallback WeightroomWeb.FallbackController

  plug(Guardian.Plug.EnsureAuthenticated when action in [:index, :create, :update, :delete])

  def index(conn, _params, current_user) do
    user_weights = Accounts.get_user_weights(current_user.id)
    render(conn, "index.json", user_weights: user_weights)
  end

  def create(conn, %{"user_weight" => weight_params}, current_user) do
    with {:ok, user_weights} <- Accounts.create_user_weight(Map.merge(weight_params, %{"user_id" => current_user.id})) do
      render(conn, "index.json", user_weights: user_weights)
    end
  end

  def update(conn, %{"id" => weight_id, "user_weight" => weight_params}, current_user) do
    with {:ok, user_weight} <- Accounts.get_user_weight(weight_id, current_user.id),
         {:ok, user_weights} <- Accounts.update_user_weight(user_weight, weight_params) do
      render(conn, "index.json", user_weights: user_weights)
    end
  end

  def delete(conn, %{"id" => weight_id}, current_user) do
    with {:ok, user_weight} <- Accounts.get_user_weight(weight_id, current_user.id),
         {:ok, user_weights} <- Accounts.delete_user_weight(user_weight) do
      render(conn, "index.json", user_weights: user_weights)
    end
  end
end
