defmodule Weightroom.Exercises do
  import Ecto.Query, warn: false
  alias Weightroom.Repo

  alias Weightroom.Accounts.User
  alias Weightroom.Programs.Exercise

  def list_exercises do
    Repo.all(
      from(e in Exercise,
        where: e.public == true
      )
    )
  end

  def get_user_exercises(user_id, opts \\ [include_private: false]) do
    if Keyword.get(opts, :include_private) do
      Repo.all(
        from(e in Exercise,
          where: e.user_id == ^user_id,
          order_by: e.name
        )
      )
    else
      Repo.all(
        from(e in Exercise,
          where: e.user_id == ^user_id and e.public == true,
          order_by: e.name
        )
      )
    end
  end

  def preload_user_exercises(%User{} = user) do
    Repo.preload(user, :exercises)
  end

  def create_exercise(attrs \\ %{}) do
    %Exercise{}
    |> Exercise.changeset(attrs)
    |> Repo.insert()
  end

  def update_exercise(%Exercise{} = exercise, attrs \\ %{}) do
    exercise
    |> Exercise.changeset(attrs)
    |> Repo.update()
  end

  def delete_exercise(%Exercise{} = exercise) do
    exercise
    |> Repo.delete()
  end

  def change_exercise(%Exercise{} = exercise, attrs \\ %{}) do
    Exercise.changeset(exercise, attrs)
  end
end
