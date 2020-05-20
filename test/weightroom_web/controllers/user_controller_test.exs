defmodule WeightroomWeb.UserControllerTest do
  use WeightroomWeb.ConnCase

  import Weightroom.Factory

  alias Weightroom.Accounts
  alias WeightroomWeb.UserView

  @create_attrs %{
    email: "test@mail.com",
    password: "some password",
    username: "some username"
  }
  @update_attrs %{
    email: "testupdate@gmail.com",
    password: "updatedpassword",
    username: "testupdate"
  }
  @invalid_attrs %{email: nil, password: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.Auth.register(@create_attrs)
    user
  end

  def secure_conn(conn, user) do
    user = user || fixture(:user)
    {:ok, jwt, _} = user |> Accounts.Guardian.encode_and_sign(%{}, token_type: :token)

    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Token " <> jwt)
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)["users"] == []

      user = fixture(:user)
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200) == render_json(UserView, "index.json", users: [user])
    end
  end

  describe "show" do
    test "show user with valid id", %{conn: conn} do
      user = fixture(:user) |> Accounts.list_user_weights()
      conn = get(conn, Routes.user_path(conn, :show, user.id))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: user)
    end

    test "show user when not currently logged in, will not show users weights", %{conn: conn} do
      user = fixture(:user) |> Accounts.list_user_weights()
      insert(:user_weight, user: user)
      conn = get(conn, Routes.user_path(conn, :show, user.id))

      response = json_response(conn, 200)
      assert response == render_json(UserView, "show.json", user: user)
      assert response["user"]["weights"] == []
    end

    test "show user when logged in will show users weights", %{conn: conn} do
      user = fixture(:user)
      insert(:user_weight, user: user)
      conn = get(secure_conn(conn, user), Routes.user_path(conn, :show, user.id))

      user = Accounts.list_user_weights(user)
      response = json_response(conn, 200)
      assert response == render_json(UserView, "show.json", user: user)
      assert response["user"]["weights"] != []
    end

    test "show user with invalid user id returns error", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, -1))
      assert json_response(conn, 404)
    end
  end

  describe "current user" do
    test "returns current user with valid token", %{conn: conn} do
      user = fixture(:user)
      conn = get(secure_conn(conn, user), Routes.user_path(conn, :current_user))
      jwt = Accounts.Guardian.Plug.current_token(conn)

      user = Accounts.list_user_weights(user)
      response = json_response(conn, 200)
      assert response == render_json(UserView, "show.json", user: user, jwt: jwt)
    end

    test "returns error message when token is not present", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :current_user))
      response = json_response(conn, 403)
      assert response == %{"message" => "Not Authenticated"}
    end
  end

  describe "update" do
    test "returns updated user", %{conn: conn} do
      user = fixture(:user)

      conn =
        put(secure_conn(conn, user), Routes.user_path(conn, :update, %{"user" => @update_attrs}))

      jwt = Accounts.Guardian.Plug.current_token(conn)

      user = Accounts.list_user_weights(user)
      response = json_response(conn, 200)

      updated_user = %{
        user
        | username: @update_attrs.username,
          email: @update_attrs.email,
          password: @update_attrs.password
      }

      assert response == render_json(UserView, "show.json", user: updated_user, jwt: jwt)
    end

    test "returns error message when user is not authenticated", %{conn: conn} do
      fixture(:user)
      conn = put(conn, Routes.user_path(conn, :update, %{"user" => @update_attrs}))

      response = json_response(conn, 403)
      assert response == %{"message" => "Not Authenticated"}
    end

    test "returns error message when user updates with invalid data", %{conn: conn} do
      user = fixture(:user)

      conn =
        put(secure_conn(conn, user), Routes.user_path(conn, :update, %{"user" => @invalid_attrs}))

      response = json_response(conn, 422)
      assert Map.has_key?(response, "errors")
    end
  end
end
