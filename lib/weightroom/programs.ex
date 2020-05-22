defmodule Weightroom.Programs do
  import Ecto.Query, warn: false
  alias Weightroom.Repo

  alias Weightroom.Accounts.User
  alias Weightroom.Programs.{Program, Workout}

  def list_programs do
    Repo.all(
      from(p in Program,
        where: p.public == true
      )
    )
  end

  def get_user_programs(user_id, opts \\ [include_private: false]) do
    if Keyword.get(opts, :include_private) do
      Repo.all(
        from(p in Program,
          where: p.user_id == ^user_id
        )
      )
    else
      Repo.all(
        from(p in Program,
          where: p.user_id == ^user_id and p.public == true
        )
      )
    end
  end

  def preload_user_programs(%User{} = user) do
    Repo.preload(user, :programs)
  end

  def create_program(attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert()
  end

  def update_program(%Program{} = program, attrs \\ %{}) do
    program
    |> Program.changeset(attrs)
    |> Repo.update()
  end

  def delete_program(%Program{} = program) do
    program
    |> Repo.delete()
  end

  def change_program(%Program{} = program, attrs \\ %{}) do
    Program.changeset(program, attrs)
  end

  def get_program_workouts(program_id) do
    Repo.all(
      from(w in Workout,
        where: w.program_id == ^program_id   
      )
    )
  end

  def preload_program_workouts(%Program{} = program) do
    Repo.preload(program, :workouts)
  end

  def create_workout(attrs \\ %{}) do
    %Workout{}
    |> Workout.changeset(attrs)
    |> Repo.insert()
  end

  def update_workout(%Workout{} = workout, attrs \\ %{}) do
    workout
    |> Workout.changeset(attrs)
    |> Repo.update()
  end

  def delete_workout(%Workout{} = workout) do
    workout
    |> Repo.delete()
  end

  def change_workout(%Workout{} = workout, attrs \\ %{}) do
    Workout.changeset(workout, attrs)
  end
end
