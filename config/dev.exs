use Mix.Config

alias Cartel.Pusher.{Apns,Gcm}

config :logger, level: :debug

config :cartel, dealers: [
  [
    id: "com.mydomain1.myapp1",
    pushers: [
      [
        type: Apns,
        env: :sandbox,
        cert: "/Users/luca/Desktop/keys/tsc-apns-dev-crt.pem",
        key: "/Users/luca/Desktop/keys/tsc-apns-dev-key.pem",
        cacert: "/Users/luca/Desktop/keys/entrust_2048_ca.cer"
      ],
      [
        type: Gcm,
        key: "abc"
      ]
    ]
  ],
  [
    id: "com.mydomain1.myapp2",
    pushers: [
      [
        type: Apns,
        env: :sandbox,
        cert: "/Users/luca/Desktop/keys/tsc-apns-dev-crt.pem",
        key: "/Users/luca/Desktop/keys/tsc-apns-dev-key.pem",
        cacert: "/Users/luca/Desktop/keys/entrust_2048_ca.cer"
      ]
    ]
  ],
  [
    id: "com.mydomain2.myapp1",
    pushers: [
      [
        type: Gcm,
        key: "abc"
      ]
    ]
  ]
]
