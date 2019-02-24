defmodule SoLoudExServerTest do
  use ExUnit.Case

  alias SoLoudEx.Server
  alias SoLoudEx.{AudioSource, Voice}

  @sample_path "test/fixtures/silence.ogg"

  test "load_wavstream/1" do
    assert {:ok, %AudioSource.WavStream{}} = Server.load_wavstream(@sample_path)
  end

  test "load_wavstream_to_slot/2" do
    slot = Enum.random(1..10)
    assert {:ok, %AudioSource.WavStream{id: ^slot}} = Server.load_wavstream_to_slot(@sample_path, slot)
  end

  test "audio_play/1" do
    assert {:ok, wavstream} = Server.load_wavstream(@sample_path)
    assert {:ok, %Voice{source: ^wavstream}} = Server.audio_play(wavstream)
  end
end
