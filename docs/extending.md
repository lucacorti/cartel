# Extending

## Implementation

You can easily add unsupported push technologies to your application without
directly modifying **Cartel**.

### Message

Define a struct and implement the `Cartel.Message` protocol for it.

    defmodule MyMessage do
        ...
        @defstruct [ ... ]
    end

    defimpl Cartel.Message, for: MyMessage do
        ...
    end

### Pusher

You also need a matching pusher module adopting the `Cartel.Pusher` behaviour:

    defmodule MyPusher do
        use Cartel.Pusher, message_module: MyMessage

        ...
    end

## Configuration

To configure your pusher in the **Cartel** configuration just add a pusher in
your application pushers section.

    config :cartel, dealers: %{
        "myappid": %{
            MyPusher => %{
                opt1: "value1",
                opt2: 10,
                opt3: :test
            }
         }
    }

All options in the config will passed to the `start_link/1` function of your
pusher module.
