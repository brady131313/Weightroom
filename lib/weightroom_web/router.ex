defmodule WeightroomWeb.Router do
  use WeightroomWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug(
      Guardian.Plug.Pipeline,
      error_handler: WeightroomWeb.SessionController,
      module: Weightroom.Accounts.Guardian
    )

    plug(Guardian.Plug.VerifyHeader, realm: "Token")
    plug(Guardian.Plug.LoadResource, allow_blank: true)
  end

  scope "/api", WeightroomWeb do
    pipe_through :api

    get "/user", UserController, :current_user
    put "/user", UserController, :update

    resources "/user/weights", UserWeightController, only: [:index, :create, :update, :delete]

    resources "/users", UserController, only: [:index, :show]

    post "/register", SessionController, :register
    post "/login", SessionController, :login
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: WeightroomWeb.Telemetry
    end
  end
end
