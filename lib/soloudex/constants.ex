defmodule SoLoudEx.Constants do
  @moduledoc """
  Declares some shared constants that are used within SoLoudEx.
  """

  [
    opcodes: %{
      load_wavstream: 1,
      audio_play: 10,
      audio_stop: 11,
      audio_seek: 12
    },
    source_types: Enum.with_index([:wavstream, :wav])
  ]
  |> Enum.each(fn {constant, value} ->
    defmacro unquote(constant)(), do: Macro.escape(unquote(Macro.escape(value)))
  end)
end
