defmodule SoLoudEx.AudioSource do
  @moduledoc """
  Utility functions that handle the construction of audio sources.
  """

  require SoLoudEx.Constants

  alias SoLoudEx.AudioSource.WavStream
  alias SoLoudEx.Constants
  alias SoLoudEx.Voice

  def create_wavstream(id), do:
    %WavStream{id: rem(id, Application.get_env(:soloudex, :max_wavstreams, 256))}

  def identify(%WavStream{id: id}), do:
    {Constants.source_types()[:wavstream], id}

  def create_voice(source, handle), do:
    %Voice{source: source, handle: handle}
end
