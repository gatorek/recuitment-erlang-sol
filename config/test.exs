import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hnapi, HnapiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "otQGuyb49yt6qpBnkZbxBA/fDnoz+d83fLkU/M2v1WfQmlX9yNQhNVnSZ7IdRd5u",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :hnapi,
  hn_req_opts: [plug: {Req.Test, Hnapi.Hn.Client}]
