Feature: Using roles with rspec-fire
  In order to mock roles rather than objects and build more flexible systems
  As an avid RSpec user
  I want to see failing specs when role interfaces are not honored

  Background:
    Given a file named "spec_helper.rb" with:
      """ruby
      require "rubygems"
      require "bundler/setup"
      Bundler.setup

      require "rspec/fire"
      require "rspec/fire/roles"

      RSpec.configure do |config|
        config.include RSpec::Fire
        config.include RSpec::Fire::Roles
      end
      """
    And a file named "batch_sender_spec.rb" with:
      """ruby
      require "spec_helper"
      require "batch_sender"
      require "notifier"

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
      """
    And a file named "batch_sender.rb" with:
      """ruby
      class BatchSender
        def initialize(notifier)
          @notifier = notifier
        end

        def send_messages(messages)
          messages.each { |msg| @notifier.notify(*msg.compact) }
        end
      end
      """
    And a file named "notifier.rb" with:
      """ruby
      module Roles
        class Notifier
          def notify(subject, body = nil); end
        end
      end
      """
    And a file named "email_notifier_spec.rb" with:
      """ruby
      require "spec_helper"
      require "email_notifier"
      require "notifier"

      describe EmailNotifier do
        implements_role "Roles::Notifier"
      end
      """

  Scenario: A role with a matching implementation
    Given a file named "email_notifier.rb" with:
      """ruby
      class EmailNotifier
        def notify(subject, body = nil); end
      end
      """
    When I run `rspec batch_sender_spec.rb email_notifier_spec.rb`
    Then it should pass

  Scenario: A role with a method with the wrong arguments defined
    Given a file named "email_notifier.rb" with:
      """ruby
      class EmailNotifier
        def notify(message); end
      end
      """
    When I run `rspec batch_sender_spec.rb`
    Then it should pass
    When I run `rspec email_notifier_spec.rb`
    Then it should fail with "Incomplete implementation of Roles::Notifier. Parameters for #notify(subject, body = nil) do not match."

  Scenario: A role with an implementation missing a method
    Given a file named "email_notifier.rb" with:
      """ruby
      class EmailNotifier
      end
      """
    When I run `rspec batch_sender_spec.rb`
    Then it should pass
    When I run `rspec email_notifier_spec.rb`
    Then it should fail with "Incomplete implementation of Roles::Notifier. #notify(subject, body = nil) is not defined."

  Scenario: A role with an implementation with incorrectly-named arguments
    Given a file named "email_notifier.rb" with:
      """ruby
      class EmailNotifier
        def notify(name, content = nil); end
      end
      """
    When I run `rspec batch_sender_spec.rb email_notifier_spec.rb`
    Then it should fail with "Incomplete implementation of Roles::Notifier. Parameters for #notify(subject, body = nil) do not match."
