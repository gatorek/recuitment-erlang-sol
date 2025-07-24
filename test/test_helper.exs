ExUnit.configure(exclude: [skip: true])
Mimic.copy(Hnapi.Hn.Client)
Mimic.copy(Hnapi.Datastore.Server)
ExUnit.start()
