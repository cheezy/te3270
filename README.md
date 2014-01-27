# TE3270

This gem can be used to drive a 3270 terminal emulator.  You have to have a supported emulator installed on the
machines on which you use the gem.  Currently the only supported emulators are
[EXTRA! X-treme](http://www.attachmate.com/Products/Terminal+Emulation/Extra/xtreme/extra-x-treme.htm) by
Attachmate and [Quick3270](http://www.dn-computing.com/Quick3270.htm) by DN-Computing.  These are commercial
products and you will need to purchase one of them in order to use this gem.  We do plan to support other
emulators as time permits.

## Installation

Add this line to your application's Gemfile:

    gem 'te3270'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install te3270

## Usage

    class MainframeScreen
      include TE3270

      text_field(:userid, 10, 30, 20, true)
      text_field(:password, 12, 30, 20, true)
    end

    emulator = TN3270.emulator_for :extra
    my_screen = MainframeScreen.new(emulator)
    my_screen.userid = 'the_id'
    my_screen.password = 'the_password'


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
