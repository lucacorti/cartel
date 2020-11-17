# Usage

## Pusher API

All the pusher types share a common interface for message sending.
You can use `send/3` for both single recipient and bulk sending.

```elixir
    alias Cartel.Pusher.<Type>, as: Pusher
    alias Cartel.Message.<Type>, as: Message

    Pusher.send("appid", <message>)
    Pusher.send("appid", <message>, ["devicetoken", "devicetoken"])
```

When passing the token list, the device token in the message struct, if present,
is ignored.

Each pusher type uses a different message format, examples are provided below.


## Message Formats


### APNS

`Cartel.Message.Apns`:

```elixir
    alias Cartel.Message.Apns, as: Message

    %Message{
      token: "devicetoken",
      payload: %{aps: %{alert: "Hello"}}
    }
```

### GCM

`Cartel.Message.Gcm`:

```elixir
    alias Cartel.Message.Gcm, as: Message

    %Message{
      to: "devicetoken",
      data: %{"message": "Hello"}
    }
```

### WNS

`Cartel.Message.Wns`:

```elixir
    alias Cartel.Message.Wns, as: Message

    %Message{
      channel: "channeluri",
      payload: "..."
    }
```