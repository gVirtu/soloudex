defmodule SoLoudEx.Voice do
  @moduledoc """
  The Voice module.

  From SoLoud's official documentation:

  # Voice

  SoLoud can play audio from several sound sources at once (or, in fact, several times from the
  same sound source at the same time). Each of these sound instances is a “voice”. The number
  of concurrent voices is limited, as having unlimited voices would cause performance issues, as
  well as lead to unnecessary clipping.

  The default number of concurrent voices - maximum number of “streams” - is 16, but this can
  be adjusted at runtime. The hard maximum number is 4095, but if more are required, SoLoud
  can be modified to support more. But seriously, if you need more than 4095 sounds at once,
  you’re probably going to make some serious changes in any case.

  If all channels are already playing and the application requests another sound to play, SoLoud
  finds the oldest voice and kills it. Since this may be your background music, you can protect
  channels from being killed by using the soloud.setProtect() call.

  SoLoud also supports virtual voices, so things are a bit more complicated - basically you can
  have thousands of voices playing, but only the most audible ones are actually played.
  """

  @enforce_keys [:handle, :source]
  defstruct handle: 0, source: nil
end
