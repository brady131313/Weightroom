defmodule Weightroom.Accounts.Auth do
  import Ecto.{Query, Changeset}, warn: false
  alias Argon2

  alias Weightroom.Repo
  alias Weightroom.Accounts.User

  def authenticate_user(username, password) do
    query = from u in User, where: u.username == ^username

    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :unauthorized}

      user ->
        if Argon2.verify_pass(password, user.password) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  def register(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> put_password_hash()
    |> Repo.insert()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
