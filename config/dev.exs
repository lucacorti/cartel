use Mix.Config

config :logger, level: :debug

config :cartel, dealers: [
  [
    id: "com.mydomain1.myapp1",
    pushers: [
      %{
        type: Cartel.Pusher.Apns2,
        env: :sandbox,
        cert: "/Users/luca/Desktop/keys/tsc-apns-dev-crt.pem",
        key: "/Users/luca/Desktop/keys/tsc-apns-dev-key.pem",
        cacert: "/Users/luca/Desktop/keys/entrust_2048_ca.cer"
      },
      %{
        type: Cartel.Pusher.Gcm,
        env: :sandbox,
        sender: "abc",
        key: "def"
      }
    ]
  ],
  [
    id: "com.mydomain1.myapp2",
    pushers: [
      %{
        type: Cartel.Pusher.Apns,
        env: :sandbox,
        cert: "/Users/luca/Desktop/keys/tsc-apns-dev-crt.pem",
        key: "/Users/luca/Desktop/keys/tsc-apns-dev-key.pem",
        cacert: "/Users/luca/Desktop/keys/entrust_2048_ca.cer"
      }
    ]
  ],
  [
    id: "com.mydomain2.myapp1",
    pushers: [
      %{
        type: Cartel.Pusher.Gcm,
        env: :sandbox,
        sender: "abc",
        key: "def"
      }
    ]
  ]
]
