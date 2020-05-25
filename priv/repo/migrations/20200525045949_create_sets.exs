defmodule Weightroom.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :order, :integer, null: false
      add :reps, :integer
      add :weight, :decimal
      add :exercise_unit_id, references(:exercise_units, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:sets, [:exercise_unit_id])
    create unique_index(:sets, [:exercise_unit_id, :order])
  end
end
