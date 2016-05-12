# Usage

## Common API

All the `Cartel.Pusher` types share a common interface for message sending.
`send/3` for single recipient and `send_bulk/4` for bulk sending.

    alias Cartel.Pusher.<Type>, as: Pusher
    alias Cartel.Message.<Type>, as: Message
    alias Message.Item

    Pusher.send("appid", :production, <message>)

    Pusher.send_bulk("appid", :sandbox, ["devicetoken", "devicetoken"], <message>)

When doing bulk sending, the device token in the message is ignored.
Each pusher uses a different message format, detailed below.

## Pusher specific APIs and Message Formats

### APNS

`Cartel.Message.Apns`:

    %Cartel.Apns.Message{
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

`Cartel.Pusher.Apns` also allows consuming feedback as a `Stream.t`:

    alias Cartel.Pusher.Apns

    {:ok, stream} = Apns.feedback("appid", :sandbox)

### APNS2

`Cartel.Message.Apns2`:

    %Message{
      token: "devicetoken",
      payload: %{aps: %{alert: "Hello"}}
    }

### GCM

TBD

### WNS

TBD
