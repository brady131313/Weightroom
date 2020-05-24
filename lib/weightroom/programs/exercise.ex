defmodule Weightroom.Programs.Exercise do
  use Ecto.Schema
  import Ecto.Changeset
  alias Weightroom.Accounts.User

  schema "exercises" do
    field :muscles, {:array, :string}
    field :name, :string
    field :public, :boolean, default: false

    belongs_to :created_by, User, foreign_key: :user_id

    timestamps()
  end

  @required_fields ~w(name user_id muscles)a
  @optional_fields ~w(public)a

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 3, max: 30)
    |> validate_length(:muscles, min: 1, max: 3)
    |> unique_constraint([:user_id, :name])
    |> assoc_constraint(:created_by)
  end
end
