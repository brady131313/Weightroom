defmodule Weightroom.Workouts.ExerciseUnit do
  use Ecto.Schema
  import Ecto.Changeset
  alias Weightroom.Programs.{Workout, Exercise, Set}

  schema "exercise_units" do
    field :order, :integer

    belongs_to :workout, Workout
    belongs_to :exercise, Exercise
    has_many :sets, Set

    timestamps()
  end

  @required_fields ~w(workout_id exercise_id order)a

  @doc false
  def changeset(exercise_unit, attrs) do
    exercise_unit
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:workout_id, :order])
    |> assoc_constraint(:workout)
    |> assoc_constraint(:exercise)
  end
end
