# TE3270

This gem can be used to drive a 3270 terminal emulator.  You have to have a supported emulator installed on the
machines on which you use the gem.  Currently the only supported emulators are
[EXTRA! X-treme](http://www.attachmate.com/Products/Terminal+Emulation/Extra/xtreme/extra-x-treme.htm) by
Attachmate and [Quick3270](http://www.dn-computing.com/Quick3270.htm) by DN-Computing.  These are commercial
products and you will need to purchase one of them in order to use this gem.  We do plan to support other
emulators as time permits.

## Documentation

You can view the RDocs for this project [here](http://rdoc.info/gems/te3270/frames).

## Installation

Add this line to your application's Gemfile:

    gem 'te3270'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install te3270

## Usage

You can create classes that are similar to page-object classes.  In these classes you can define
the various fields that you wish to interact with on the screen.

    class MainframeScreen
      include TE3270

      text_field(:userid, 10, 30, 20)
      text_field(:password, 12, 30, 20)

      def login(username, password)
        self.userid = username
        self.password = password
      end
    end

    emulator = TE3270.emulator_for :extra do |platform|
      platform.session_file = 'sessionfile.edp'
    end
    my_screen = MainframeScreen.new(emulator)
    my_screen.userid = 'the_id'
    my_screen.password = 'the_password'

If you are using this gem with cucumber then you can register the ScreenFactory module with the
cucumber World like this:

    World(TE3270::ScreenFactory)

You also need to setup some hooks to start and stop the emulator:

    Begin do
      @emulator = TE3270.emulator_for :extra do |platform|
        platform.session_file = 'sessionfile.edp'
      end
    end

    After do
      TE3270.disconnect(@emulator)
    end

This allows you to use the `on` method in your step definitions like this:

    on(MainframeScreen).login('the_user', 'the_password')

or you can use the version of `on` that takes a block like this:

    on(MainframeScreen) do |screen|
      screen.userid = 'the_id'
      screen.password = 'the_password'
    end

There is also a way to pass in a `Hash` and have it populate an entire screen.  Just simply
ensure the key for an entry in the `Hash` matches the name you gave a text field and it will
find and set the value.  This allows the gem to easily work with the DataMagic gem.

    # given this Hash
    my_date = { userid: 'the_id', password: 'the_password' }

    # you can simply call this method
    on(MainframeScreen).populate_screen_with my_data


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
