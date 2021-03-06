defmodule Weightroom.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Weightroom.Accounts.UserWeight
  alias Weightroom.Programs.{Program, Exercise}

  schema "users" do
    field :email, :string
    field :password, :string
    field :username, :string

    has_many :weights, UserWeight
    has_many :programs, Program
    has_many :exercises, Exercise

    timestamps()
  end

  @required_fields ~w(email username password)a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:username, name: :users_username_index)
    |> unique_constraint(:email, name: :users_email_index)
  end
end
