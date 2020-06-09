defmodule Weightroom.Workouts.Set do
  use Ecto.Schema
  import Ecto.Changeset
  alias Weightroom.Workouts.ExerciseUnit

  schema "sets" do
    field :order, :integer
    field :reps, :integer
    field :weight, :decimal

    belongs_to :exercise_unit, ExerciseUnit

    timestamps()
  end

  @required_fields ~w(exercise_unit_id order)a
  @optional_fields ~w(reps weight)a

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:exercise_unit_id, :order])
    |> assoc_constraint(:exercise_unit)
  end

  def assoc_changeset(set, attrs) do
    set
    |> cast(attrs, @required_fields)
    |> assoc_constraint(:exercise_unit)
  end
end
