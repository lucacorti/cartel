# Getting started

## Installation

Add cartel to your list of dependencies in `mix.exs`:

    def deps do
      [{:cartel, "~> 0.0.0"}]
    end

Ensure cartel is started before your application:

    def application do
      [applications: [:cartel]]
    end

## Configuration

Configure your mobile applications in `config.exs`:

    config :cartel, dealers: %{
      "app1": %{
        Cartel.Pusher.Apns2 => %{
            env: :sandbox,
            cert: "/path/to/app1-cert.pem",
            key: "/path/to/app1-key.pem",
            cacert: "/path/to/entrust_2048_ca.cer"
        },
        Cartel.Pusher.Gcm => %{
            key: "gcm-key"
        }
      },
      "app2": %{
        Cartel.Pusher.Apns => %{
            env: :production,
            cert: "/path/to/app2-crt.pem",
            key: "/path/to/app2-key.pem",
            cacert: "/path/to/entrust_2048_ca.cer"
        }
      },
      "app3": %{
        Cartel.Pusher.Gcm => %{
            key: "gcm-key"
        }
      }
    }

***Cartel*** uses [poolboy](https://github.com/devinus/poolboy) to pool
pusher processes. By default `poolboy` creates a pool of 5 workers.
You can change pooling options per pusher by adding a `pool` key:

    ...
    "app3": %{
        Cartel.Pusher.Gcm => %{
            key: "gcm-key",
            pool: [size: 10, max_overflow: 20]
        }
    }
    ...

Refer to the poolboy docs for more information.
