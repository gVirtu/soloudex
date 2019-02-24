defmodule SoLoudEx.AudioSource do
  @moduledoc """
  Utility functions that handle the construction of audio sources.
  """

  require SoLoudEx.Constants

  alias SoLoudEx.AudioSource.Wavstream
  alias SoLoudEx.Voice
  alias SoLoudEx.Constants

  def create_wavstream(id), do:
    %Wavstream{id: rem(id, Application.get_env(:soloudex, :max_wavstreams, 256))}

  def identify(%Wavstream{id: id}), do:
    {Constants.source_types()[:wavstream], id}

  def create_voice(source, handle), do:
    %Voice{source: source, handle: handle}
end
