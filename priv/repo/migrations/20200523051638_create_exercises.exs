defmodule Weightroom.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises) do
      add :name, :string
      add :muscles, {:array, :string}
      add :public, :boolean
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:exercises, [:user_id])
    create unique_index(:exercises, [:user_id, :name])
  end
end
