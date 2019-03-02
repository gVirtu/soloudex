use Mix.Config

config :soloudex,
  max_wavstreams: 256,
  supervision_children: [SoLoudEx.Server]

import_config "#{Mix.env}.exs"
