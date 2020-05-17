defmodule WeightroomWeb.UserView do
  use WeightroomWeb, :view
  alias WeightroomWeb.{UserView, UserWeightView}

  def render("index.json", %{users: users}) do
    %{users: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user, jwt: jwt}) do
    %{data: Map.merge(render_one(user, UserView, "show.json"), %{token: jwt})}
  end

  def render("show.json", %{user: user}) do
    rendered_user =
      user
      |> render_one(UserView, "user.json")
      |> Map.put(:weights, render_many(user.weights, UserWeightView, "user_weight.json"))

    %{user: rendered_user}
  end

  def render("login.json", %{jwt: jwt, user: user}) do
    %{data: Map.merge(render_one(user, UserView, "show.json"), %{token: jwt})}
  end

  def render("error.json", %{message: message}) do
    %{message: message}
  end

  def render("user.json", %{user: user}) do
    user
    |> Map.from_struct()
    |> Map.take([:id, :email, :username, :token])
  end
end
