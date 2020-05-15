defmodule Weightroom.Accounts.UserWeight do
  use Ecto.Schema
  import Ecto.Changeset
  alias Weightroom.Accounts.User

  schema "user_weights" do
    field :weight, :decimal

    belongs_to :user, User

    timestamps()
  end

  @required_fields ~w(weight user_id)a

  @doc false
  def changeset(user_weight, attrs) do
    user_weight
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than: 0, less_than: 1000)
    |> assoc_constraint(:user)
  end
end
