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

  def get_user(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user}
    end
  end

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

  def get_user_weights(user_id) do
    result = get_user(user_id)
    case result do
      {:ok, user} ->
        Repo.all(
          from(w in UserWeight,
            where: w.user_id == ^user_id,
            order_by: [desc: w.inserted_at])
        )
      _ -> result
    end
  end

  def create_user_weight(attrs \\ %{}) do
    result =
      %UserWeight{}
      |> UserWeight.changeset(attrs)
      |> Repo.insert()

    case result do
      {:error, changeset} ->
        {:error, changeset}

      {:ok, user_weight} ->
        {:ok, get_user_weights(user_weight.user_id)}
    end
  end

  def update_user_weight(%UserWeight{} = user_weight, attrs) do
    result =
      user_weight
      |> UserWeight.changeset(attrs)
      |> Repo.update()

    case result do
      {:error, changeset} ->
        {:error, changeset}

      {:ok, user_weight} ->
        {:ok, get_user_weights(user_weight.user_id)}
    end
  end

  def delete_user_weight(%UserWeight{} = user_weight) do
    result =
      user_weight
      |> Repo.delete()

    case result do
      {:error, changeset} ->
        {:error, changeset}

      {:ok, user_weight} ->
        {:ok, get_user_weights(user_weight.user_id)}
    end
  end

  def change_user_weight(%UserWeight{} = user_weight, attrs \\ %{}) do
    UserWeight.changeset(user_weight, attrs)
  end
end
