defmodule Weightroom.Repo.Migrations.CreateWorkouts do
  use Ecto.Migration

  def change do
    create table(:workouts) do
      add :week, :integer
      add :day, :integer
      add :order, :integer
      add :comments, :string
      add :program_id, references(:programs)

      timestamps()
    end

    create unique_index(:workouts, [:week, :day, :order])
  end
end
