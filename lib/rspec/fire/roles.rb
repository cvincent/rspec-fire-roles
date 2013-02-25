require "rspec/fire/roles/version"

module RSpec
  module Fire
    module Roles
      def self.included(base)
        base.extend(ClassMethods)
      end

      protected

      def incomplete_implementation(role, error)
        fail "Incomplete implementation of #{role}. #{error}"
      end

      module ClassMethods
        def implements_role(role)
          role = role.split("::").inject(Kernel) { |last, const| last.const_get(const) }

          describe "#{role} interface" do
            role.public_instance_methods(false).each do |m|
              m = role.public_instance_method(m)
              params = m.parameters.map { |(opt, name)| name.to_s + (opt == :opt ? " = nil" : "") }.join(", ")

              it "defines ##{m.name}(#{params})" do
                begin
                  klass = subject.class
                  imp = klass.public_instance_method(m.name.to_sym)

                  if imp.parameters != m.parameters
                    incomplete_implementation(role, "Parameters for ##{m.name}(#{params}) do not match.")
                  end
                rescue NameError
                  puts $!.inspect
                  incomplete_implementation(role, "##{m.name}(#{params}) is not defined.")
                end
              end
            end
          end
        end
      end
    end
  end
end
