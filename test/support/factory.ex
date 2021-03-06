defmodule Weightroom.Factory do
  use ExMachina.Ecto, repo: Weightroom.Repo

  def user_factory do
    %Weightroom.Accounts.User{
      username: sequence("test"),
      email: sequence(:email, &"test#{&1}@mail.com"),
      password: "password"
    }
  end

  def user_weight_factory do
    %Weightroom.Accounts.UserWeight{
      weight: 250,
      user: build(:user)
    }
  end

  def program_factory do
    %Weightroom.Programs.Program{
      name: sequence(:name, &"Program #{&1}"),
      description: "Some Description",
      likes: 5,
      public: true,
      author: build(:user)
    }
  end

  def workout_factory do
    %Weightroom.Workouts.Workout{
      comments: "Some Comments",
      week: 0,
      day: 0,
      order: sequence(:order, & &1),
      program: build(:program)
    }
  end

  def exercise_factory do
    %Weightroom.Programs.Exercise{
      name: sequence("exercise"),
      muscles: ["Pecs", "Triceps", "Shoulders"],
      public: true,
      created_by: build(:user)
    }
  end
end
