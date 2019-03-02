defmodule SoLoudEx.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = Application.get_env(:soloudex, :supervision_children)

    opts = [strategy: :one_for_one, name: SoLoudEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
