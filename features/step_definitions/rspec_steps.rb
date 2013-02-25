Then /it should fail with "(.+)"/ do |message|
  step "the exit status should be 1"
  step %{the output should contain "#{message}"}
end

Then "it should pass" do
  step "the exit status should be 0"
end
