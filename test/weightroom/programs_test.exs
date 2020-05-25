defmodule Weightroom.ProgramsTest do
  use Weightroom.DataCase

  import Weightroom.Factory

  alias Weightroom.Programs
  alias Weightroom.Programs.Program
  alias Weightroom.Accounts.Auth

  describe "programs" do
    @valid_attrs %{name: "Some Name", description: "Some Desc", likes: 2, public: true}
    @update_attrs %{name: "Updated Name", description: "Updated Desc", likes: 3, public: true}
    @invalid_attrs %{name: nil, description: nil, likes: -1}

    setup context do
      {:ok, author} =
        Auth.register(%{username: "test", email: "test@mail.com", password: "password"})

      program =
        unless context[:without_program], do: insert(:program, public: false, author: author)

      {:ok, %{author: author, program: program}}
    end

    @tag :without_program
    test "list_programs/0 returns all public programs" do
      assert Programs.list_programs() == []

      programs = insert_list(5, :program)
      expected_user_ids = programs |> Enum.map(fn program -> program.id end)

      actual_programs = Programs.list_programs()
      actual_user_ids = actual_programs |> Enum.map(fn program -> program.id end)

      assert expected_user_ids == actual_user_ids
      actual_programs |> Enum.each(fn program -> assert program.public == true end)
    end

    test "list_progams/0 does not return private programs" do
      assert Programs.list_programs() == []
    end

    test "get_user_programs/2 returns all of a users programs with valid user", %{
      author: author,
      program: program
    } do
      program_ids =
        Programs.get_user_programs(author.id, include_private: true)
        |> Enum.map(fn program -> program.id end)

      assert program_ids == [program.id]
      assert Programs.get_user_programs(author.id) == []
    end

    test "get_user_programs/2 returns empty list with invalid user" do
      assert Programs.get_user_programs(-1, include_private: true) == []
    end

    @tag :without_program
    test "preload_user_programs/1 with valid user returns user preloaded with programs", %{
      author: author
    } do
      assert Programs.preload_user_programs(author).programs == []

      programs = insert_list(5, :program, author: author)
      expected_program_ids = programs |> Enum.map(fn program -> program.id end)

      actual_program_ids =
        Programs.preload_user_programs(author).programs |> Enum.map(fn program -> program.id end)

      assert expected_program_ids == actual_program_ids
    end

    @tag :without_program
    test "create_program/1 with valid data returns new program", %{author: author} do
      assert Programs.list_programs() == []

      assert {:ok, program} =
               Programs.create_program(Map.merge(@valid_attrs, %{user_id: author.id}))

      assert Programs.list_programs() == [program]

      assert program.name == @valid_attrs.name
      assert program.description == @valid_attrs.description
      assert program.public == @valid_attrs.public
      assert program.likes == @valid_attrs.likes
    end

    @tag :without_program
    test "create_program/1 with invalid data returns error changeset", %{author: author} do
      assert {:error, %Ecto.Changeset{}} =
               Programs.create_program(Map.merge(@invalid_attrs, %{user_id: author.id}))

      assert Programs.list_programs() == []
    end

    test "update_program/2 with valid data returns updated program", %{program: program} do
      assert {:ok, program} = Programs.update_program(program, @update_attrs)
      assert program.name == @update_attrs.name
      assert program.description == @update_attrs.description
      assert program.likes == @update_attrs.likes
    end

    test "update_program/2 with invalid data returns error changeset", %{program: program} do
      assert {:error, %Ecto.Changeset{}} = Programs.update_program(program, @invalid_attrs)
    end

    test "delete_program/1 with valid program returns the deleted program", %{
      author: author,
      program: program
    } do
      program_ids =
        Programs.get_user_programs(author.id, include_private: true)
        |> Enum.map(fn program -> program.id end)

      assert program_ids == [program.id]

      assert {:ok, %Program{}} = Programs.delete_program(program)
      assert Programs.get_user_programs(author.id, include_private: true) == []
    end

    test "change_program/2 returns a program changeset", %{program: program} do
      assert %Ecto.Changeset{} = Programs.change_program(program)
    end

    test "change_program/2 with invalid data retursn error changeset", %{program: program} do
      changeset = Programs.change_program(program, @invalid_attrs)
      assert changeset.valid? == false

      changeset = Programs.change_program(program, Map.merge(@valid_attrs, %{likes: -1}))
      assert Keyword.has_key?(changeset.errors, :likes)

      changeset = Programs.change_program(program, Map.merge(@valid_attrs, %{name: "abc"}))
      assert Keyword.has_key?(changeset.errors, :name)
    end
  end

  describe "workouts" do
    setup context do
      program = insert(:program)
      workout = unless context[:without_workout], do: insert(:workout, program: program)

      {:ok, %{program: program, workout: workout}}
    end

    @tag :without_workout
    test "get_program_workout/1 returns all of a programs workouts with valid program", %{
      program: program
    } do
      assert Programs.get_program_workouts(program.id) == []

      workouts = insert_list(5, :workout, program: program)
      expected_workout_ids = workouts |> Enum.map(fn workout -> workout.id end)

      actual_workout_ids =
        Programs.get_program_workouts(program.id) |> Enum.map(fn workout -> workout.id end)

      assert expected_workout_ids == actual_workout_ids
    end

    test "get_program_workout/1 returns empty list with invalid program" do
      assert Programs.get_program_workouts(-1) == []
    end

    @tag :without_workout
    test "preload_program_workouts/1 with valid program returns program preloaded with workouts",
         %{program: program} do
      assert Programs.preload_program_workouts(program).workouts == []

      workouts = insert_list(5, :workout, program: program)
      expected_workout_ids = workouts |> Enum.map(fn workout -> workout.id end)

      actual_workout_ids =
        Programs.preload_program_workouts(program).workouts
        |> Enum.map(fn workout -> workout.id end)

      assert expected_workout_ids == actual_workout_ids
    end

    @tag :without_workout
    test "reorder_workouts/2 with valid workout reordering returns updated list of workouts", %{
      program: program
    } do
      workout1 = insert(:workout, week: 0, day: 0, order: 0, program: program)
      workout2 = insert(:workout, week: 0, day: 0, order: 1, program: program)

      expected_workout_ids = [workout1.id, workout2.id]

      actual_workout_ids =
        Programs.get_program_workouts(program.id) |> Enum.map(fn workout -> workout.id end)

      assert expected_workout_ids == actual_workout_ids

      reorder = %{workout1.id => %{order: 1}, workout2.id => %{order: 0}}

      assert {:ok, workouts} = Programs.reorder_workouts(program.id, reorder)
      expected_workout_ids = [workout2.id, workout1.id]

      actual_workout_ids =
        Programs.get_program_workouts(program.id) |> Enum.map(fn workout -> workout.id end)

      assert expected_workout_ids == actual_workout_ids
    end

    @tag :without_workout
    test "reorder_workouts/2 leaves unchanged workouts in the same place", %{program: program} do
      workout1 = insert(:workout, week: 0, day: 0, order: 0, program: program)
      workout2 = insert(:workout, week: 0, day: 0, order: 1, program: program)
      workout3 = insert(:workout, week: 0, day: 0, order: 2, program: program)

      expected_workout_ids = [workout1.id, workout2.id, workout3.id]

      actual_workout_ids =
        Programs.get_program_workouts(program.id) |> Enum.map(fn workout -> workout.id end)

      assert expected_workout_ids == actual_workout_ids

      reorder = %{workout1.id => %{order: 2}, workout3.id => %{order: 0}}
      assert {:ok, workouts} = Programs.reorder_workouts(program.id, reorder)

      expected_workout_ids = [workout3.id, workout2.id, workout1.id]

      actual_workout_ids =
        Programs.get_program_workouts(program.id) |> Enum.map(fn workout -> workout.id end)

      assert expected_workout_ids == actual_workout_ids
    end

    @tag :without_workout
    test "reorder_workouts/2 with invalid reordering returns an error", %{program: program} do
      workout1 = insert(:workout, week: 0, day: 0, order: 0, program: program)
      _workout2 = insert(:workout, week: 0, day: 0, order: 1, program: program)

      reorder = %{workout1.id => %{order: 1}}
      assert {:error, _} = Programs.reorder_workouts(program.id, reorder)
    end

  end
end
