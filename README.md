# rspec-fire-roles

Mocking against roles rather than concrete objects results in more flexible,
pluggable object designs. This gem builds upon the capabilities of rspec-fire
to make it easier to mock in this style while also knowing with confidence that
your objects and their collaborators are speaking through the same interfaces.

## Installation

Add this line to your application's Gemfile:

    gem "rspec-fire-roles"

Or install it yourself as:

    $ gem install rspec-fire-roles

Add it to your `spec_helper.rb`:

    RSpec.configure do |config|
      config.include RSpec::Fire
      config.include RSpec::Fire::Roles
    end

## Why

While rspec-fire allows you to create mocks of specific concrete classes, this
isn't quite enough if you'd like to mock a *role* rather than a class. Mocking
roles results in more flexible designs, because a given object might play more
than one role, and more than one object might play the same role. Thinking in
terms of roles rather than objects also assists in the process of *interface
discovery*, which is the main purpose of behavior-driven development as an
assistant to the design process.

For more on the topic of mocking roles, see [the seminal paper on the
topic](http://jmock.org/oopsla2004.pdf). Also highly recommended reads are the
infamous [Growing Object-Oriented Software Guided by
Tests](http://amzn.to/VWOwyA) and [Practical Object-Oriented Design in
Ruby](http://amzn.to/VWOHtP). See also the example usage below.

*Full disclosure: Them be affiliate links.*

## Usage

Skip directly to the [Relish
documentation](https://www.relishapp.com/cvincent/rspec-fire-roles/docs/using-roles-with-rspec-fire)
for a simple worked example. Read on for a more detailed explanation.

Let's say you have a `BatchSender` object. Here's your spec:

    describe BatchSender do
      describe "#send_messages" do
        it "passes each message to the injected notifier" do
          notifier = fire_double("Roles::Notifier")
          instance = BatchSender.new(notifier)
          notifier.should_receive(:notify).with("Subject 1", "Body 1").once
          notifier.should_receive(:notify).with("Subject 2").once

          instance.send_messages([["Subject 1", "Body 1"], ["Subject 2"]])
        end
      end
    end

We're using a regular old `fire_double` here to create the mock, just like with
rspec-fire. But notice that, rather than passing in the name of some concrete
class which implements `#notify` with two arguments, we pass in the name of a
role. Here's that role, which should be required in any isolated unit test
which depends upon this role so that rspec-fire recognizes it:

    module Roles
      class Notifier
        def notify(subject, body = nil)
        end
      end
    end

It's just an empty implementation of the interface. Thanks to rspec-fire, our
specs will now fail if they depend upon the `Notifier` role but the mock
expectations don't match this interface.

Now here's where rspec-fire-roles comes in.  Here's the spec for a concrete
object which implements the `Notifier` role:

    describe EmailNotifier do
      implements_role "Roles::Notifier"

      # [...] class-specific specs about notifying via email, not shown
    end

The `implements_role` macro ensures that this spec will fail if the
`EmailNotifier` class doesn't have the right methods to satisfy the `Notifier`
role. Of course, this class can have additional public methods which don't have
anything to do with the role; the macro only checks that the methods on
`Notifier` are also implemented on `EmailNotifier`. Furthermore, multiple
`implements_role` calls can be added to the spec for objects which play more
than one role.

Here's an example of another class in the same system which plays this role,
plus another role (for demonstration purposes):

    describe SmsNotifier do
      implements_role "Roles::Notifier"
      implements_role "Roles::Serializable"

      # [...] class-specific specs about notifying via SMS, not shown
    end

You should be able to see what this gains over using rspec-fire alone. Let's
say later you decide to extract a Value Object instead of using arrays to
represent messages. First you change the role:

    module Roles
      class Notifier
        def notify(message)
        end
      end
    end

Now your `BatchSender` spec will fail because the `fire_double` is expecting
the wrong arguments, and your specs for `EmailNotifier` and `SmsNotifier` will
fail because the classes still implement the old interface which takes a
subject and body. You you can haz fast, isolated unit tests which mock roles
rather than objects without having to worry or write extra integration tests to
ensure that the objects play well together. Bliss!

## Future improvements

 * It would be cool to have a nicer DSL for defining roles than just empty
   implementations.
 * It would also be cool if roles defined default return values for their
   `fire_double`s.
 * The `implements_role` method presently only supports the interface of
   instances of the class. It would be nice to be able to specify that a role
   is implemented by class methods instead.
 * False positives are still possible. If expectations on a `fire_double` are
   set with the correct number arguments, but the types of the arguments are
   incorrect (for example, the role expects a single float parameter but a
   string is passed in), there's no way to detect this disparity because
   arguments aren't typed. I can imagine placing additional constraints a role
   such that arguments must match some other role, though I don't know if such
   a restriction would be worth it. In practice, such a scenario is probably
   quite rare.
 * Anything else. Feedback is appreciated!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
