defmodule WeightroomWeb.UserController do
  use WeightroomWeb, :controller
  use WeightroomWeb.GuardedController

  import Ecto.Query, only: [from: 2]

  alias Weightroom.Repo
  alias Weightroom.Accounts
  alias Weightroom.Accounts.{User, Auth, UserWeight}

  action_fallback WeightroomWeb.FallbackController

  plug(Guardian.Plug.EnsureAuthenticated when action in [:current_user, :update])

  def index(conn, _, _) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def show(conn, %{"id" => user_id}, current_user) do
    case Accounts.get_user(user_id) do
      user ->
        if current_user == nil do
          render(conn, "show.json", user: %{user | weights: []})
        else
          user = Accounts.list_user_weights(user)
          render(conn, "show.json", user: user)
        end

      nil ->
        render(conn, "error.json", message: "User not found")
    end
  end

  def current_user(conn, _params, user) do
    jwt = Accounts.Guardian.Plug.current_token(conn)

    case user do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(WeightroomWeb.ErrorView, "403.json", [])

      _ ->
        user = Accounts.list_user_weights(user)
        conn
        |> put_status(:ok)
        |> render("show.json", %{jwt: jwt, user: user})
    end
  end

  def update(conn, %{"user" => user_params}, user) do
    jwt = Accounts.Guardian.Plug.current_token(conn)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        user = Accounts.list_user_weights(user)
        render(conn, "show.json", %{jwt: jwt, user: user})

      {:error, changeset} ->
        render(conn, WeightroomWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
