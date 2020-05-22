defmodule Weightroom.Programs do
  import Ecto.Query, warn: false
  alias Weightroom.Repo

  alias Weightroom.Accounts.User
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
          where: p.user_id == ^user_id)
      )
    else
      Repo.all(
        from(p in Program,
          where: p.user_id == ^user_id and p.public == true)
      )
    end
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
end
