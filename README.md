# pingas

Simple to configure monitoring solution in Crystal.

## Installation

Download a binary or follow these instructions to compile from source:
```sh
git clone https://github.com/dscottboggs/pingas.git
cd pingas
shards install
crystal build src/pingas
sudo mv pingas /usr/local/bin/
```

## Usage

A configuration file must be specified. There is an example config file at [here](https://github.com/dscottboggs/pingas/blob/master/spec/data/config.json).

### IMPORTANT
When defining all configuration options, `"kind"` must go **before** `"options"` in the config file.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/dscottboggs/pingas/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [D. Scott Boggs](https://github.com/dscottboggs) - creator and maintainer
