defmodule WeightroomWeb.GuardedController do
  defmacro __using__(_opts \\ %{}) do
    quote do
      def action(conn, _opts) do
        apply(__MODULE__, action_name(conn), [
          conn,
          conn.params,
          Weightroom.Accounts.Guardian.Plug.current_resource(conn)
        ])
      end
    end
  end
end
