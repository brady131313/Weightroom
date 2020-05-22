defmodule Weightroom.AccountsTest do
  use Weightroom.DataCase

  import Weightroom.Factory

  alias Weightroom.Accounts
  alias Weightroom.Accounts.{Auth, User}

  describe "users" do
    @valid_attrs %{email: "test@mail.com", password: "password", username: "test"}
    @update_attrs %{
      email: "testupdate@mail.com",
      password: "passwordupdate",
      username: "testupdate"
    }
    @invalid_attrs %{email: nil, password: nil, username: nil}

    test "list_users/0 returns all users" do
      assert Accounts.list_users() == []

      users = insert_list(5, :user)
      expected_user_ids = users |> Enum.map(fn user -> user.id end)
      actual_user_ids = Accounts.list_users() |> Enum.map(fn user -> user.id end)
      assert expected_user_ids == actual_user_ids
    end

    test "get_user/1 returns existing user" do
      inserted_user = insert(:user)
      assert {:ok, user} = Accounts.get_user(inserted_user.id)
      assert user == inserted_user
    end

    test "get_user/1 returns nil with bad user id" do
      assert {:error, :not_found} = Accounts.get_user(-1)
    end

    test "register/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.register(@valid_attrs)
      assert user.username == @valid_attrs.username
      assert user.email == @valid_attrs.email

      # Make sure password is hashed
      assert user.password != @valid_attrs.password
      assert Argon2.verify_pass(@valid_attrs.password, user.password)
    end

    test "register/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.register(@invalid_attrs)

      user = insert(:user)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Auth.register(Map.merge(@valid_attrs, %{username: user.username}))

      assert Keyword.has_key?(changeset.errors, :username)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Auth.register(Map.merge(@valid_attrs, %{email: user.email}))

      assert Keyword.has_key?(changeset.errors, :email)
    end

    test "authenticate_user/2 with valid credentials returns user" do
      Auth.register(@valid_attrs)

      assert {:ok, %User{} = user} =
               Auth.authenticate_user(@valid_attrs.username, @valid_attrs.password)

      assert user.username == @valid_attrs.username
      assert user.email == @valid_attrs.email
    end

    test "authenticate_user/2 with invalid credentials returns error" do
      assert {:error, :unauthorized} = Auth.authenticate_user("nouser", "password")

      Auth.register(@valid_attrs)

      assert {:error, :unauthorized} =
               Auth.authenticate_user(@valid_attrs.username, "badpassword")
    end

    test "update_user/2 with valid data updates user" do
      user = insert(:user)

      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.username == @update_attrs.username
      assert user.email == @update_attrs.email
      assert user.password == @update_attrs.password
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)

      user2 = insert(:user)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.update_user(user, Map.merge(@valid_attrs, %{username: user2.username}))

      assert Keyword.has_key?(changeset.errors, :username)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.update_user(user, Map.merge(@valid_attrs, %{email: user2.email}))

      assert Keyword.has_key?(changeset.errors, :email)
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "change_user/1 with invalid data returns error changeset" do
      user = insert(:user)
      changeset = Accounts.change_user(user, @invalid_attrs)
      assert changeset.valid? == false

      changeset = Accounts.change_user(user, %{password: "short"})
      assert Keyword.has_key?(changeset.errors, :password)

      changeset = Accounts.change_user(user, %{email: "badformat"})
      assert Keyword.has_key?(changeset.errors, :email)
    end
  end

  describe "users weight" do
    setup context do
      {:ok, user} =
        Auth.register(%{username: "test", email: "test@mail.com", password: "password"})

      user_weight = unless context[:without_weight], do: insert(:user_weight, user: user)

      {:ok, %{user: user, user_weight: user_weight}}
    end

    @tag :without_weight
    test "preload_user_weights/0 with valid user returns user preloaded with weights", %{
      user: user
    } do
      assert Accounts.preload_user_weights(user).weights == []

      weights = insert_list(5, :user_weight, user: user)
      expected_weight_ids = weights |> Enum.map(fn weight -> weight.id end)

      actual_weight_ids =
        Accounts.preload_user_weights(user).weights |> Enum.map(fn weight -> weight.id end)

      assert expected_weight_ids == actual_weight_ids
    end

    @tag :without_weight
    test "create_user_weight/2 with valid data returns updated list of users weights", %{
      user: user
    } do
      assert Accounts.preload_user_weights(user).weights == []

      assert {:ok, user_weights} = Accounts.create_user_weight(%{weight: 250, user_id: user.id})

      actual_weight_ids =
        user_weights
        |> Enum.map(fn weight -> weight.id end)

      expected_weight_ids =
        Accounts.preload_user_weights(user).weights
        |> Enum.map(fn weight -> weight.id end)

      assert actual_weight_ids == expected_weight_ids
    end

    @tag :without_weight
    test "create_user_weight/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user_weight(%{weight: 250, user_id: -1})

      assert Accounts.preload_user_weights(user).weights == []
    end

    test "update_user_weight/2 with valid data returns updated list of user weights", %{
      user_weight: user_weight
    } do
      assert {:ok, user_weights} = Accounts.update_user_weight(user_weight, %{weight: 300})
      [updated_user_weight | _] = user_weights
      assert updated_user_weight.weight == Decimal.new(300)
    end

    test "update_user_weight/2 with invalid data returns error changeset", %{
      user_weight: user_weight
    } do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_weight(user_weight, %{weight: -1})
    end

    test "delete_user_weight/1 with valid user_weight returns updated list of user weights", %{
      user: user,
      user_weight: user_weight
    } do
      user_weights =
        Accounts.preload_user_weights(user).weights |> Enum.map(fn weight -> weight.id end)

      assert user_weight.id in user_weights

      assert {:ok, user_weights} = Accounts.delete_user_weight(user_weight)
      assert user_weights == []
    end

    test "change_user_weight/2 returns a user weight changeset", %{user_weight: user_weight} do
      assert %Ecto.Changeset{} = Accounts.change_user_weight(user_weight)
    end

    test "change_user_weight/2 with invalid data returns error changeset", %{
      user_weight: user_weight
    } do
      changeset = Accounts.change_user_weight(user_weight, %{weight: nil})
      assert changeset.valid? == false

      changeset = Accounts.change_user_weight(user_weight, %{weight: 0})
      assert Keyword.has_key?(changeset.errors, :weight)

      changeset = Accounts.change_user_weight(user_weight, %{weight: 1001})
      assert Keyword.has_key?(changeset.errors, :weight)
    end
  end
end
