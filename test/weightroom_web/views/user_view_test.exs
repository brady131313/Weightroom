defmodule WeightroomWeb.UserViewTest do
  use WeightroomWeb.ConnCase, async: true

  alias Weightroom.Accounts

  import Phoenix.View
  import Weightroom.Factory

  test "renders user.json" do
    user = insert(:user)

    assert render(WeightroomWeb.UserView, "user.json", user: user) == %{
             id: user.id,
             username: user.username,
             email: user.email
           }
  end

  test "renders index.json" do
    user = insert(:user)
    rendered_users = render(WeightroomWeb.UserView, "index.json", users: [user])

    assert rendered_users == %{users: [render(WeightroomWeb.UserView, "user.json", user: user)]}
  end

  test "renders show.json" do
    user = insert(:user) |> Accounts.preload_user_weights()
    rendered_user = render(WeightroomWeb.UserView, "show.json", user: user)

    assert rendered_user == %{
             user: Map.put(render(WeightroomWeb.UserView, "user.json", user: user), :weights, [])
           }
  end
end
