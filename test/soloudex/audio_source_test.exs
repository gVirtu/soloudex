defmodule SoLoudExAudioSourceTest do
  use ExUnit.Case

  require SoLoudEx.Constants

  alias SoLoudEx.{AudioSource, Voice}
  alias SoLoudEx.Constants

  test "create a wavstream" do
    max = Application.get_env(:soloudex, :max_wavstreams, 256)
    id = Enum.random(0..(max-1))
    assert %AudioSource.Wavstream{id: ^id} = AudioSource.create_wavstream(id)

    alt_id = id + max
    assert %AudioSource.Wavstream{id: ^id} = AudioSource.create_wavstream(alt_id)
  end

  test "identify a wavstream" do
    wavstream = %AudioSource.Wavstream{id: Enum.random(0..10)}

    assert {type, id} = AudioSource.identify(wavstream)
    assert type == Constants.source_types[:wavstream]
    assert id == wavstream.id
  end

  test "create a voice" do
    source = %AudioSource.Wavstream{id: Enum.random(0..10)}
    handle = Enum.random(0..100)

    assert %Voice{source: ^source, handle: ^handle} = AudioSource.create_voice(source, handle)
  end
end
