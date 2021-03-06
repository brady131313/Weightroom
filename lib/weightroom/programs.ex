defmodule Weightroom.Programs do
  import Ecto.Query, warn: false
  alias Weightroom.Repo

  alias Weightroom.Accounts.User
  alias Weightroom.Workouts.Workout
  alias Weightroom.Programs.Program

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
        where: w.program_id == ^program_id,
        order_by: [w.week, w.day, w.order]
      )
    )
  end

  def reorder_workouts(program_id, reorder) do
    alias Ecto.Multi
    workout_ids = Map.keys(reorder)

    workouts =
      Repo.all(
        from(w in Workout,
          where: w.id in ^workout_ids and w.program_id == ^program_id
        )
      )

    shift_workouts =
      Enum.reduce(workouts, Multi.new(), fn workout, multi ->
        Multi.update(
          multi,
          {:shift_workout, workout.id},
          Workout.changeset(workout, %{order: workout.order + 999})
        )
      end)

    updated_workouts =
      Enum.reduce(workouts, shift_workouts, fn workout, multi ->
        Multi.update(
          multi,
          {:update_workout, workout.id},
          Workout.changeset(workout, reorder[workout.id])
        )
      end)

    case Repo.transaction(updated_workouts) do
      {:ok, _} -> {:ok, get_program_workouts(program_id)}
      _ -> {:error, "Workouts must have unique positioning"}
    end
  end

  def preload_program_workouts(%Program{} = program) do
    Repo.preload(program, :workouts)
  end
end
