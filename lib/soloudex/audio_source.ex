defmodule SoLoudEx.AudioSource do
  @moduledoc """
  Utility functions that handle the construction of audio sources.
  """

  @sourcetypes Enum.with_index([:wavstream, :wav])

  alias SoLoudEx.AudioSource.{Instance, Wavstream}

  def create_wavstream(id), do: %Wavstream{id: id}

  def identify(%Wavstream{id: id}), do: {@sourcetypes[:wavstream], id}

  def create_instance(handle), do: %Instance{handle: handle}
end
