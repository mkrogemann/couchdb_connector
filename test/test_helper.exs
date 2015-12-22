ExUnit.start()

Code.load_file("test/test_config.exs")
Code.load_file("test/test_prep.exs")
Code.load_file("test/test_retry.exs")

Application.start :httpoison
