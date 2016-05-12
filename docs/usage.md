# Usage

## Common API

All the pusher types share a common interface for message sending.
`send/3` for single recipient and `send_bulk/4` for bulk sending.

    alias Cartel.Pusher.<Type>, as: Pusher
    alias Cartel.Message.<Type>, as: Message
    alias Message.Item

    Pusher.send("appid", :production, <message>)

    Pusher.send_bulk("appid", :sandbox, ["devicetoken", "devicetoken"], <message>)

When doing bulk sending, the device token in the message is ignored.
Each pusher uses a different message format, examples are provided below.

The Apns pusher exposes the feedback service via a `Stream.t`

    alias Cartel.Pusher.Apns

    {:ok, stream} = Apns.feedback("appid", :sandbox)


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

TBD

### WNS

TBD
