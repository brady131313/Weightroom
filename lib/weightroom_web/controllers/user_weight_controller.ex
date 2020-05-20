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
    case Accounts.create_user_weight(Map.merge(weight_params, %{"user_id" => current_user.id})) do
      {:error, changeset} ->
        conn
        |> put_view(WeightroomWeb.ChangesetView)
        |> render("error.json", changeset: changeset)

      {:ok, user_weights} ->
        render(conn, "index.json", user_weights: user_weights)
    end
  end

  def update(conn, %{"id" => weight_id, "user_weight" => weight_params}, current_user) do
  end
end
