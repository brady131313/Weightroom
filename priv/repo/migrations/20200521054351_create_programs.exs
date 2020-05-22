defmodule Weightroom.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string
      add :description, :string
      add :likes, :integer
      add :public, :boolean
      add :user_id, references(:users)

      timestamps()
    end
  end
end
