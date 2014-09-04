Given /^I have the hash "([^"]*)"$/ do |wannabe|
  @hash = eval(wannabe)
end

When /^I verify the given hash includes the pairs "([^"]*)"$/ do |new_wannabe|
  new_hash = eval(new_wannabe)
  @result  = @hash.include_pairs?(new_hash)
end

Then(/^the hash search result should be (.*)$/) do |result|
  assert_equal(eval(result), @result)
end