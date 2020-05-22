defmodule Weightroom.Programs.Program do
  use Ecto.Schema
  import Ecto.Changeset
  alias Weightroom.Accounts.User

  schema "programs" do
    field :description, :string
    field :likes, :integer, default: 0
    field :name, :string
    field :public, :boolean

    belongs_to :author, User, foreign_key: :user_id

    timestamps()
  end

  @required_fields ~w(name user_id)a
  @optional_fields ~w(description likes public)a

  @doc false
  def changeset(program, attrs) do
    program
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:likes, greater_than: 0)
    |> validate_length(:name, min: 4)
    |> assoc_constraint(:author)
  end
end
