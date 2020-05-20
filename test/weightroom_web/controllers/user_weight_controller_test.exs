defmodule WeightroomWeb.UserWeightControllerTest do
  use WeightroomWeb.ConnCase

  import Weightroom.Factory

  alias Weightroom.Accounts
  alias Weightroom.Accounts.Auth
  alias WeightroomWeb.UserWeightView

  def secure_conn(conn, user) do
    {:ok, jwt, _} = user |> Accounts.Guardian.encode_and_sign(%{}, token_type: :token)

    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Token " <> jwt)
  end

  setup %{conn: conn} = context do
    {:ok, user} = Auth.register(%{username: "test", email: "test@mail.com", password: "password"})
    user_weight = unless context[:without_weight], do: insert(:user_weight, user: user)

    {:ok,
     %{
       user: user,
       user_weight: user_weight,
       conn: put_req_header(conn, "accept", "application/json")
     }}
  end

  describe "index" do
    @tag :without_weight
    test "returns empty list when user has no weights", %{conn: conn, user: user} do
      conn = get(secure_conn(conn, user), Routes.user_weight_path(conn, :index))
      assert json_response(conn, 200)["user_weights"] == []
    end

    test "returns list of all users weights", %{conn: conn, user: user, user_weight: user_weight} do
      conn = get(secure_conn(conn, user), Routes.user_weight_path(conn, :index))

      assert json_response(conn, 200) ==
               render_json(UserWeightView, "index.json", user_weights: [user_weight])
    end

    @tag :without_weight
    test "returns error message when no user is authenticated", %{conn: conn} do
      conn = get(conn, Routes.user_weight_path(conn, :index))
      response = json_response(conn, 403)
      assert response == %{"message" => "Not Authenticated"}
    end
  end

  describe "create" do
    @tag :without_weight
    test "with valid data and authenticated user returns updated list of weights", %{
      conn: conn,
      user: user
    } do
      conn =
        post(
          secure_conn(conn, user),
          Routes.user_weight_path(conn, :create, %{"user_weight" => %{weight: 200}})
        )

      response = json_response(conn, 200)

      user_weights = Accounts.get_user_weights(user.id)
      assert response == render_json(UserWeightView, "index.json", user_weights: user_weights)
    end

    @tag :without_weight
    test "with invalid data and authenticated user returns error message", %{
      conn: conn,
      user: user
    } do
      conn =
        post(
          secure_conn(conn, user),
          Routes.user_weight_path(conn, :create, %{"user_weight" => %{weight: -1}})
        )

      response = json_response(conn, 422)
      assert Map.has_key?(response, "errors")
    end

    @tag :without_weight
    test "returns error message when no user is authenticated", %{conn: conn} do
      conn =
        post(conn, Routes.user_weight_path(conn, :create, %{"user_weight" => %{weight: 200}}))

      response = json_response(conn, 403)
      assert response == %{"message" => "Not Authenticated"}
    end
  end

  describe "update" do
    test "with valid data and authenticated user returns updated list of weights", %{
      conn: conn,
      user: user,
      user_weight: user_weight
    } do
      conn = put(secure_conn(conn, user), Routes.user_weight_path(conn, :update, user_weight.id, %{"user_weight" => %{weight: 100}}))
      response = json_response(conn, 200)

      user_weights = Accounts.get_user_weights(user.id)
      assert response == render_json(UserWeightView, "index.json", user_weights: user_weights)
    end

    test "with invalid data and authenticated user returns error message", %{
      conn: conn,
      user: user,
      user_weight: user_weight
    } do
      conn = put(secure_conn(conn, user), Routes.user_weight_path(conn, :update, user_weight.id, %{"user_weight" => %{weight: -1}}))
      response = json_response(conn, 422)
      assert Map.has_key?(response, "errors")
    end

    test "returns error message when no user is authenticated", %{
      conn: conn,
      user_weight: user_weight
    } do
      conn = put(conn, Routes.user_weight_path(conn, :update, user_weight.id, %{"user_weight" => %{weight: 100}}))
      response = json_response(conn, 403)
      assert response == %{"message" => "Not Authenticated"}
    end
  end

  describe "delete" do
    test "with valid weight id and authenticated user returns updated list of weights", %{conn: conn, user: user, user_weight: user_weight} do
      conn = delete(secure_conn(conn, user), Routes.user_weight_path(conn, :delete, user_weight.id))
      response = json_response(conn, 200)

      user_weights = Accounts.get_user_weights(user.id)
      assert response == render_json(UserWeightView, "index.json", user_weights: user_weights)
    end

    test "with invalid weight id and authenticated user returns resource not found error", %{conn: conn, user: user} do
      conn = delete(secure_conn(conn, user), Routes.user_weight_path(conn, :delete, -1))
      assert response = json_response(conn, 404)
    end

    test "with no authenticated user returns error message", %{conn: conn, user_weight: user_weight} do
      conn = delete(conn, Routes.user_weight_path(conn, :delete, user_weight.id))
      assert response = json_response(conn, 403)
      assert response == %{"message" => "Not Authenticated"}
    end
  end
end
