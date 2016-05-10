# Cartel

**Multi platform, multi app push notification server**

## Installation

1. Add cartel to your list of dependencies in `mix.exs`:

    def deps do
      [{:cartel, "~> 0.1.0"}]
    end

2. Ensure cartel is started before your application:

    def application do
      [applications: [:cartel]]
    end

## Usage
