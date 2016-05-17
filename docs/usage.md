# Usage

## Common API

All the pusher types share a common interface for message sending.
Use `send/3` for both single recipient and bulk sending.

    alias Cartel.Pusher.<Type>, as: Pusher
    alias Cartel.Message.<Type>, as: Message
    alias Message.Item

    Pusher.send("appid", <message>)

    Pusher.send("appid", <message>, ["devicetoken", "devicetoken"])

When passing the token list, the device token in the message struct, if present,
is ignored.

Each pusher type uses a different message format, examples are provided below.

The Apns pusher exposes the feedback service via a `Stream.t`

    alias Cartel.Pusher.Apns

    {:ok, stream} = Apns.feedback("appid")


## Message Formats

### APNS

`Cartel.Message.Apns`:

    alias Cartel.Message.Apns, as: Message

    %Message{
      items: [
        %Item{
          id: Item.device_token,
          data: "devicetoken"
        },
        %Item{
          id: Item.payload,
          data: %{aps: %{alert: "Hello"}}
        }
      ]
    }

### APNS2

`Cartel.Message.Apns2`:

    alias Cartel.Message.Apns2, as: Message

    %Message{
      token: "devicetoken",
      payload: %{aps: %{alert: "Hello"}}
    }

### GCM

`Cartel.Message.Gcm`:

    alias Cartel.Message.Gcm, as: Message

    %Message{
      to: "devicetoken",
      data: %{"message": "Hello"}
    }

### WNS

TBD
