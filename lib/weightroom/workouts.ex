defmodule Weightroom.Workouts do
  import Ecto.Query, warn: false
  alias Weightroom.Repo

  alias Weightroom.Workouts.{Workout, ExerciseUnit, Set}

  def create_workout(attrs \\ %{}) do
    %Workout{}
    |> Workout.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:exercise_units,
      with: &Weightroom.Workouts.ExerciseUnit.assoc_changeset/2
    )
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

  def preload_workout_exercise_units(%Workout{} = workout) do
    query =
      from eu in ExerciseUnit,
        preload: [:exercise]

    Repo.preload(workout, exercise_units: [:exercise, sets: from(s in Set, order_by: s.order)])
  end
end
