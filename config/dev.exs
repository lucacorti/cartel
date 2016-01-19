use Mix.Config

config :logger, level: :debug

config :cartel, dealers: [
  [
    id: "com.mydomain1.myapp1",
    pushers: [
      [
        type: :apns,
        env: :sandbox,
        cert: "/Users/luca/Desktop/keys/tsc-apns-dev-crt.pem",
        key: "/Users/luca/Desktop/keys/tsc-apns-dev-key.pem",
        cacert: "/Users/luca/Desktop/keys/entrust_2048_ca.cer",
        poolboy_opts: [
          size: 10
        ]
      ],
      [
        type: :gcm,
        key: "abc"
      ]
    ]
  ],
  [
    id: "com.mydomain1.myapp2",
    pushers: [
      [
        type: :apns,
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
        type: :gcm,
        key: "abc"
      ]
    ]
  ]
]
