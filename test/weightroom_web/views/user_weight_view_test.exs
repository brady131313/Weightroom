defmodule WeightroomWeb.UserWeightViewTest do
  use WeightroomWeb.ConnCase, async: true

  import Phoenix.View
  import Weightroom.Factory

  test "renders user_weight.json" do
    user_weight = insert(:user_weight)

    assert render(WeightroomWeb.UserWeightView, "user_weight.json", user_weight: user_weight) ==
             %{
               id: user_weight.id,
               user_id: user_weight.user_id,
               weight: user_weight.weight,
               inserted_at: user_weight.inserted_at
             }
  end

  test "renders index.json" do
    user_weight = insert(:user_weight)

    rendered_user_weights =
      render(WeightroomWeb.UserWeightView, "index.json", user_weights: [user_weight])

    assert rendered_user_weights == %{
             user_weights: [
               render(WeightroomWeb.UserWeightView, "user_weight.json", user_weight: user_weight)
             ]
           }
  end
end
