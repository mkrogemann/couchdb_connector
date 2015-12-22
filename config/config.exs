use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug,
  level: :debug,
  utc_log: true

import_config "#{Mix.env}.exs"
