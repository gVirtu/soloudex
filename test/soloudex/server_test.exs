defmodule SoLoudExServerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  require SoLoudEx.Constants

  alias SoLoudEx.{AudioSource, Constants, Server, Voice}

  @sample_path "test/fixtures/silence.ogg"

  setup do
    Server.start_link([])
    :ok
  end

  test "load_wavstream/1" do
    assert {:ok, %AudioSource.WavStream{}} = Server.load_wavstream(@sample_path)
  end

  test "load_wavstream_to_slot/2" do
    slot = Enum.random(1..10)
    assert {:ok, %AudioSource.WavStream{id: ^slot}} = Server.load_wavstream_to_slot(@sample_path, slot)
  end

  describe "playback" do
    setup do
      {:ok, wavstream} = Server.load_wavstream(@sample_path)
      [wavstream: wavstream]
    end

    test "audio_play/1, audio_seek/1, audio_stop/1", %{wavstream: wavstream} do
      assert {:ok, %Voice{source: ^wavstream} = voice} = Server.audio_play(wavstream)
      assert :ok = Server.audio_seek(voice, 0.5)
      assert :ok = Server.audio_stop(voice)
    end

    test "audio_play/2", %{wavstream: wavstream} do
      {v, p} = {:rand.uniform(), :rand.uniform()}
      assert {:ok, %Voice{source: ^wavstream}} = Server.audio_play(wavstream, volume: v, pan: p)

      expected_message = Constants.errors.opts_not_keyword
      assert {:error, ^expected_message} = Server.audio_play(wavstream, [v, p])
    end

    test "audio_stop/1", %{wavstream: wavstream} do
      assert {:ok, %Voice{source: ^wavstream}} = Server.audio_play(wavstream)
    end
  end

  test "recovery sequence" do
    assert capture_log([level: :warn], fn ->
      %{port: port} = :sys.get_state(Server)
      Port.close(port)

      %{port: new_port} = :sys.get_state(Server)

      assert port != new_port
    end) =~ "Reloading previously loaded wavstreams"
  end
end
