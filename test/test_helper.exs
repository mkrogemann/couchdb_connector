ExUnit.start([{:trace, true}])

Code.load_file("test/test_config.exs")
Code.load_file("test/test_prep.exs")
Code.load_file("test/test_support.exs")

Application.start :httpoison
