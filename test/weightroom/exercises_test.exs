defmodule Weightroom.ExercisesTest do
  use Weightroom.DataCase

  import Weightroom.Factory

  alias Weightroom.Exercises
  alias Weightroom.Programs.Exercise
  alias Weightroom.Accounts.Auth

  describe "exercises" do
    @valid_attrs %{name: "exercise", muscles: ["Pecs"], public: true}
    @update_attrs %{name: "exerciseupdate", muscles: ["Pecs", "Shoulders"]}
    @invalid_attrs %{name: nil, muscles: nil}

    setup context do
      {:ok, user} =
        Auth.register(%{username: "test", email: "test@mail.com", password: "password"})

      exercise = unless context[:without_exercise], do: insert(:exercise, public: false, created_by: user)

      {:ok, %{user: user, exercise: exercise}}
    end

    @tag :without_exercise
    test "list_exercises/0 returns all public exercises" do
      assert Exercises.list_exercises() == []

      exercises = insert_list(5, :exercise)
      expected_exercise_ids = exercises |> Enum.map(fn exercise -> exercise.id end)

      actual_exercises = Exercises.list_exercises()
      actual_exercise_ids = actual_exercises |> Enum.map(fn exercise -> exercise.id end)

      assert actual_exercise_ids == expected_exercise_ids
      actual_exercises |> Enum.each(fn exercise -> assert exercise.public == true end)
    end

    test "list_programs/0 does not return private exercises" do
      assert Exercises.list_exercises() == []
    end

    test "get_user_exercises/2 returns all of a users exercises with valid user", %{
      user: user,
      exercise: exercise
    } do
      exercise_ids =
        Exercises.get_user_exercises(user.id, include_private: true)
        |> Enum.map(fn exercise -> exercise.id end)

      assert exercise_ids == [exercise.id]
      assert Exercises.get_user_exercises(user.id) == []
    end

    test "get_user_exercises/2 returns empty list with invalid user" do
      assert Exercises.get_user_exercises(-1, include_private: true) == []
    end

    @tag :without_exercise
    test "preload_user_exercises/1 with valid user returns user preloaded with exercises", %{
      user: user
    } do
      assert Exercises.preload_user_exercises(user).exercises == []

      exercises = insert_list(5, :exercise, created_by: user)
      expected_exercise_ids = exercises |> Enum.map(fn exercise -> exercise.id end)

      actual_exercise_ids =
        Exercises.preload_user_exercises(user).exercises
        |> Enum.map(fn exercise -> exercise.id end)

      assert actual_exercise_ids == expected_exercise_ids
    end

    @tag :without_exercise
    test "create_exercise/1 with valid data returns new exercise", %{user: user} do
      assert Exercises.list_exercises() == []
      assert {:ok, exercise} = Exercises.create_exercise(Map.merge(@valid_attrs, %{user_id: user.id}))
      assert Exercises.list_exercises() == [exercise]

      assert exercise.name == @valid_attrs.name
      assert exercise.muscles == @valid_attrs.muscles
    end

    @tag :without_exercise
    test "create_exercise/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Exercises.create_exercise(Map.merge(@invalid_attrs, %{user_id: user.id}))
      assert Exercises.list_exercises() == []
    end

    test "update_exercise/2 with valid data returns updated exercise", %{exercise: exercise} do
      assert {:ok, exercise} = Exercises.update_exercise(exercise, @update_attrs)
      assert exercise.name == @update_attrs.name
      assert exercise.muscles == @update_attrs.muscles
    end

    test "update_exercise/2 with invalid data returns error changeset", %{exercise: exercise} do
      assert {:error, %Ecto.Changeset{}} = Exercises.update_exercise(exercise, @invalid_attrs)
    end

    test "delete_exercise/1 with valid exercise returns deleted exercise", %{
      user: user,
      exercise: exercise
    } do
      assert Exercises.get_user_exercises(user.id, include_private: true) != []
      assert {:ok, %Exercise{}} = Exercises.delete_exercise(exercise)
      assert Exercises.get_user_exercises(user.id, include_private: true) == []
    end

    test "change_exercise/2 returns an exercise changeset", %{exercise: exercise} do
      assert %Ecto.Changeset{} = Exercises.change_exercise(exercise)
    end

    test "change_exercise/2 with invalid data returns error changeset", %{exercise: exercise} do
      changeset = Exercises.change_exercise(exercise, @invalid_attrs)
      assert changeset.valid? == false

      changeset = Exercises.change_exercise(exercise, Map.merge(@valid_attrs, %{name: "ab"}))
      assert Keyword.has_key?(changeset.errors, :name)

      changeset = Exercises.change_exercise(exercise, Map.merge(@valid_attrs, %{muscles: []}))
      assert Keyword.has_key?(changeset.errors, :muscles)

      changeset = Exercises.change_exercise(exercise, Map.merge(@valid_attrs, %{muscles: ["a", "b", "c", "d"]}))
      assert Keyword.has_key?(changeset.errors, :muscles)
    end
  end
end
