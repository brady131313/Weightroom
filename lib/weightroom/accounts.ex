defmodule Weightroom.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Weightroom.Repo

  alias Weightroom.Accounts.{User, UserWeight}

  def list_users do
    Repo.all(User)
  end

  def get_user(id), do: Repo.get(User, id)

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def list_user_weights(%User{} = user) do
    user
    |> Repo.preload(
      weights:
        from(w in UserWeight,
          order_by: [desc: w.inserted_at]
        )
    )
  end

  def get_user_weight!(id), do: Repo.get(UserWeight, id)
end
