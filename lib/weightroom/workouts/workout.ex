defmodule Weightroom.Workouts.Workout do
  use Ecto.Schema
  import Ecto.Changeset
  alias Weightroom.Programs.Program
  alias Weightroom.Workouts.ExerciseUnit

  schema "workouts" do
    field :comments, :string
    field :day, :integer
    field :order, :integer
    field :week, :integer

    belongs_to :program, Program
    has_many :exercise_units, ExerciseUnit

    timestamps()
  end

  @required_fields ~w(week day order program_id)a
  @optional_fields ~w(comments)a

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:week, greater_than_or_equal_to: 0, less_than_or_equal_to: 51)
    |> validate_number(:day, greater_than_or_equal_to: 0, less_than_or_equal_to: 6)
    |> validate_number(:order, greater_than_or_equal_to: 0)
    |> unique_constraint([:week, :day, :order])
    |> assoc_constraint(:program)
  end
end
