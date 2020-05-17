defmodule WeightroomWeb.SessionControllerTest do
  use WeightroomWeb.ConnCase

  alias Weightroom.Accounts

  @create_attrs %{
    email: "test@mail.com",
    username: "test",
    password: "password"
  }

  @invalid_attrs %{
    email: nil,
    username: nil,
    password: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register" do
    test "with valid credentials creates a new user", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :register, %{"user" => @create_attrs}))

      response = json_response(conn, 201)["data"]
      assert response["user"]["username"] == @create_attrs.username
      assert response["user"]["email"] == @create_attrs.email
      assert response["token"] != nil
    end

    test "with invalid credentials returns error", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :register, %{"user" => @invalid_attrs}))
      response = json_response(conn, 200)
      assert Map.has_key?(response, "errors")
    end
  end

  describe "login" do
    test "with valid credentials returns user and token", %{conn: conn} do
      {:ok, _} = Accounts.Auth.register(@create_attrs)
      conn = post(conn, Routes.session_path(conn, :login, %{"user" => %{"username" => @create_attrs.username, "password" => @create_attrs.password}}))

      response = json_response(conn, 201)["data"]
      assert response["user"]["username"] == @create_attrs.username
      assert response["user"]["email"] == @create_attrs.email
      assert response["token"] != nil
    end

    test "with invalid credentials returns error", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :login, %{"user" => %{"username" => "bad", "password" => "password"}}))

      response = json_response(conn, 401)
      assert response["message"] != nil
    end
  end

end
