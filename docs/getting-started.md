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

Cartel supports preconfigured dealers as well as dynamically adding and removing
dealers at runtime.

### Static configuration ###

You can configure your mobile applications in `config.exs`:

    config :cartel, dealers: %{
      "app1": %{
        Cartel.Pusher.Apns => %{
            env: :sandbox,
            cert: "/path/to/app1-cert.pem",
            key: "/path/to/app1-key.pem",
            cacert: "/path/to/entrust_2048_ca.cer"
        },
        Cartel.Pusher.Wns => %{
            sid: "ms-app://wns-sid",
            secret: "wns-secret"
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

### Dynamically adding and removing dealers ###

If you wish you can dynamically add and remove dealers at runtime, to do so call
`Cartel.Dealer.add/2` and `Cartel.Dealer.remove/1`:

    Cartel.Dealer.add("app3", %{
      Cartel.Pusher.Gcm => %{
          key: "gcm-key"
      }
    })

    ...

    Cartel.Dealer.remove("app3")


### Pooling ###

[poolboy](https://github.com/devinus/poolboy) is used to pool pusher processes.
By default `poolboy` creates a pool of 5 workers. You can change pooling options
per pusher by adding a `pool` key:

    ...
    "app4": %{
        Cartel.Pusher.Gcm => %{
            key: "gcm-key",
            pool: [size: 10, max_overflow: 20]
        }
    }
    ...

Refer to the poolboy docs for more information.
Please note that `name` and `worker_module` values, if present in the passed
`Keyword` list, are silently ignored.
