defmodule WeightroomWeb.UserController do
  use WeightroomWeb, :controller
  use WeightroomWeb.GuardedController

  alias Weightroom.Accounts

  action_fallback WeightroomWeb.FallbackController

  plug(Guardian.Plug.EnsureAuthenticated when action in [:current_user, :update])

  def index(conn, _, _) do
    users = Accounts.list_users()
    render(conn, "index.json", %{users: users})
  end

  def show(conn, %{"id" => user_id}, current_user) do
    with {:ok, user} <- Accounts.get_user(user_id) do
      if current_user == nil do
        render(conn, "show.json", %{user: %{user | weights: []}})
      else
        user = Accounts.preload_user_weights(user)
        render(conn, "show.json", %{user: user})
      end
    end
  end

  def current_user(conn, _params, user) do
    jwt = Accounts.Guardian.Plug.current_token(conn)
    user = Accounts.preload_user_weights(user)

    conn
    |> put_status(:ok)
    |> render("show.json", %{jwt: jwt, user: user})
  end

  def update(conn, %{"user" => user_params}, user) do
    jwt = Accounts.Guardian.Plug.current_token(conn)

    with {:ok, user} <- Accounts.update_user(user, user_params) do
      user = Accounts.preload_user_weights(user)
      render(conn, "show.json", %{jwt: jwt, user: user})
    end
  end
end
