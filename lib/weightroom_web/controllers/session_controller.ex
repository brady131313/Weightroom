defmodule WeightroomWeb.SessionController do
  use WeightroomWeb, :controller

  alias Weightroom.Accounts
  alias Weightroom.Accounts.Auth

  action_fallback(WeightroomWeb.FallbackController)

  def register(conn, %{"user" => user_params}) do
    case Auth.register(user_params) do
      {:ok, user} ->
        {:ok, jwt, _} = user |> Accounts.Guardian.encode_and_sign(%{}, token_type: :token)

        conn
        |> put_status(:created)
        |> put_view(WeightroomWeb.UserView)
        |> render("show.json", %{
          jwt: jwt,
          user: Map.merge(user, %{weights: []})
        })

      {:error, changeset} ->
        conn
        |> put_view(WeightroomWeb.ChangesetView)
        |> render("error.json", %{changeset: changeset})
    end
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Auth.authenticate_user(username, password) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} =
          user |> Accounts.Guardian.encode_and_sign(%{}, token_type: :token)

        user = Accounts.list_user_weights(user)

        conn
        |> put_status(:created)
        |> put_view(WeightroomWeb.UserView)
        |> render("login.json", %{jwt: jwt, user: user})

      {:error, message} ->
        conn
        |> put_status(401)
        |> put_view(WeightroomWeb.UserView)
        |> render("error.json", %{message: message})
    end
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:forbidden)
    |> put_view(WeightroomWeb.UserView)
    |> render("error.json", %{message: "Not Authenticated"})
  end
end
