defmodule Weightroom.WorkoutsTest do
  use Weightroom.DataCase

  import Weightroom.Factory

  alias Weightroom.Programs
  alias Weightroom.Workouts
  alias Weightroom.Workouts.Workout

  describe "workouts" do
    @valid_attrs %{week: 0, day: 0, order: 0, comments: "Some Comments"}
    @update_attrs %{week: 1, day: 1, order: 1, comments: "Update Comments"}
    @invalid_attrs %{week: nil, day: nil, order: nil, comments: nil}

    setup context do
      program = insert(:program)
      workout = unless context[:without_workout], do: insert(:workout, program: program)

      {:ok, %{program: program, workout: workout}}
    end

    @tag :without_workout
    test "create_workout/1 with valid data returns new workout", %{program: program} do
      assert Programs.get_program_workouts(program.id) == []

      exercise = insert(:exercise)

      exercise_unit = %{
        order: 0,
        exercise_id: exercise.id,
        sets: [
          %{order: 0, reps: 5, weight: 10},
          %{order: 1, reps: 5, weight: 10}
        ]
      }

      params = Map.merge(@valid_attrs, %{program_id: program.id, exercise_units: [exercise_unit]})
      assert {:ok, workout} = Workouts.create_workout(params)
      assert workout.week == @valid_attrs.week
      assert workout.day == @valid_attrs.day
      assert workout.order == @valid_attrs.order

      workout = Workouts.preload_workout_exercise_units(workout)
      actual_exercise_unit = hd(workout.exercise_units)
      assert actual_exercise_unit.exercise.name == exercise.name
      assert actual_exercise_unit.sets |> Enum.map(fn set -> set.order end) == [0, 1] 

      IO.inspect(workout)
    end

    @tag :without_workout
    test "create_workout/1 with invalid data returns error changeset", %{program: program} do
      assert {:error, %Ecto.Changeset{}} =
               Workouts.create_workout(Map.merge(@invalid_attrs, %{program_id: program.id}))

      assert Programs.get_program_workouts(program.id) == []
    end

    test "update_workout/2 with valid data returns updated workout", %{workout: workout} do
      assert {:ok, workout} = Workouts.update_workout(workout, @update_attrs)
      assert workout.week == @update_attrs.week
      assert workout.day == @update_attrs.day
      assert workout.order == @update_attrs.order
      assert workout.comments == @update_attrs.comments
    end

    test "update_workout/2 with invalid data returns error changeset", %{workout: workout} do
      assert {:error, %Ecto.Changeset{}} = Workouts.update_workout(workout, @invalid_attrs)
    end

    test "delete_workout/1 with valid workout returns the deleted workout", %{
      program: program,
      workout: workout
    } do
      workout_ids =
        Programs.get_program_workouts(program.id) |> Enum.map(fn workout -> workout.id end)

      assert workout_ids == [workout.id]

      assert {:ok, %Workout{}} = Workouts.delete_workout(workout)
      assert Programs.get_program_workouts(program.id) == []
    end

    test "change_workout/2 returns a workout changeset", %{workout: workout} do
      assert %Ecto.Changeset{} = Workouts.change_workout(workout)
    end

    test "change_workout/2 with invalid data returns error changeset", %{workout: workout} do
      changeset = Workouts.change_workout(workout, @invalid_attrs)
      assert changeset.valid? == false

      changeset = Workouts.change_workout(workout, Map.merge(@valid_attrs, %{week: -1}))
      assert Keyword.has_key?(changeset.errors, :week)

      changeset = Workouts.change_workout(workout, Map.merge(@valid_attrs, %{week: 52}))
      assert Keyword.has_key?(changeset.errors, :week)

      changeset = Workouts.change_workout(workout, Map.merge(@valid_attrs, %{day: -1}))
      assert Keyword.has_key?(changeset.errors, :day)

      changeset = Workouts.change_workout(workout, Map.merge(@valid_attrs, %{day: 7}))
      assert Keyword.has_key?(changeset.errors, :day)

      changeset = Workouts.change_workout(workout, Map.merge(@valid_attrs, %{order: -1}))
      assert Keyword.has_key?(changeset.errors, :order)
    end

    test "change_workout/2 with two workouts in same order returns error changeset", %{
      program: program
    } do
      workout1 = insert(:workout, program: program)
      workout2 = insert(:workout, program: program)

      invalid_update = %{week: workout1.week, day: workout1.day, order: workout1.order}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Workouts.update_workout(workout2, invalid_update)
    end
  end
end
