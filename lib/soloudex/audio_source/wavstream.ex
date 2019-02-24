defmodule SoLoudEx.AudioSource.WavStream do
  @moduledoc """
  The WavStream audio source module.

  Adapted from SoLoud's official documentation:

  # WavStream

  The `AudioSource.WavStream` module represents a wave sound effect that is streamed off disk while
  it’s playing. The source files may be in various RIFF WAV file formats, FLAC, MP3 or Ogg Vorbis
  files.

  The sounds are loaded in pieces while they are playing, which takes more processing power than
  playing samples from memory, but they require much less memory.
  For short or often used samples, you may want to use `AudioSource.Wav` instead.
  """

  @enforce_keys [:id]
  defstruct id: 0
end
