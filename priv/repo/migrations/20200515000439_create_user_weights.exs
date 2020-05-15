defmodule Weightroom.Repo.Migrations.CreateUserWeights do
  use Ecto.Migration

  def change do
    create table(:user_weights) do
      add :weight, :decimal
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_weights, [:user_id])
  end
end
