# Getting started

## Installation

Add cartel to your list of dependencies in `mix.exs`:

    def deps do
      [{:cartel, "~> 0.1.0"}]
    end

Ensure cartel is started before your application:

    def application do
      [applications: [:cartel]]
    end

## Configuration

Configure your mobile applications in `config.exs`:

    config :cartel, dealers: [
      [
        id: "com.mydomain1.myapp1",
        pushers: [
          %{
            type: Cartel.Pusher.Apns2,
            env: :sandbox,
            cert: "app1-cert.pem",
            key: "app1-key.pem",
            cacert: "entrust_2048_ca.cer"
          },
          %{
            type: Cartel.Pusher.Gcm,
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
            env: :production,
            cert: "app2-crt.pem",
            key: "app2-key.pem",
            cacert: "entrust_2048_ca.cer"
          }
        ]
      ],
      [
        id: "com.mydomain2.myapp1",
        pushers: [
          %{
            type: Cartel.Pusher.Gcm,
            sender: "abc",
            key: "def"
          }
        ]
      ]
    ]
