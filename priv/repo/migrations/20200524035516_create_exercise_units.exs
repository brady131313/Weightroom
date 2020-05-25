defmodule Weightroom.Repo.Migrations.CreateExerciseUnits do
  use Ecto.Migration

  def change do
    create table(:exercise_units) do
      add :order, :integer
      add :workout_id, references(:workouts, on_delete: :delete_all)
      add :exercise_id, references(:exercises, on_delete: :delete_all)

      timestamps()
    end

    create index(:exercise_units, [:workout_id])
    create index(:exercise_units, [:exercise_id])
    create unique_index(:exercise_units, [:workout_id, :order])
  end
end
