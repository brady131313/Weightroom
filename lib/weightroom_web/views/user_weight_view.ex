defmodule WeightroomWeb.UserWeightView do
  use WeightroomWeb, :view
  alias WeightroomWeb.UserWeightView

  def render("index.json", %{user_weights: user_weights}) do
    %{user_weights: render_many(user_weights, UserWeightView, "user_weight.json")}
  end

  def render("user_weight.json", %{user_weight: user_weight}) do
    %{
      id: user_weight.id,
      weight: user_weight.weight,
      user_id: user_weight.user_id,
      inserted_at: user_weight.inserted_at
    }
  end
end
