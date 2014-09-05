Given /^a hash "([^"]*)"$/ do |wannabe|
  @hash = eval(wannabe)
end

When /^is verified if the given hash includes the pairs from "([^"]*)"$/ do |new_wannabe|
  new_hash = eval(new_wannabe)
  @result  = @hash.include_pairs?(new_hash)
end

Then(/^the hash search result should be (.*)$/) do |result|
  assert_equal(eval(result), @result)
end

Given(/^a html string like$/) do |text|
  @html_string = <<-HTML
#{text.to_s}
  HTML
end

When(/^a Hashtml object is initialized with the given string$/) do
  @hashtml = HashTML.new(@html_string)
end

Then(/^a Hashtml object should be obtained$/) do
  @hashtml.is_a?(HashTML)
end

Then(/^the Hashtml object root element should have the name "([^"]*)"$/) do |name|
  assert_equal(name, @hashtml.root_node.name)
end

And(/^the Hashtml object root element should have no attributes$/) do
  assert(@hashtml.root_node.attributes.empty?)
end

When(/^the Hashtml node "([^"]*)" is accessed$/) do |node_path|
  iterations = node_path.split('.')
  object     = @hashtml
  iterations.each do |iteration|
    iteration, args = $1, $2 if iteration.match(/(\w+)\(([^\)]+)\)/)
    if args
      args   = eval(args)
      object = object.send(iteration.to_sym, args)
    else
      object = object.send(iteration.to_sym)
    end
  end
  @node = object
end

Then(/^the Hashtml node has name "([^"]*)"$/) do |name|
  assert_equal(name, @node.name)
end

And(/^the Hashtml node has attributes "([^"]*)"$/) do |attributes|
  attributes =if attributes.eql?('')
                {}
              else
                eval(attributes)
              end
  assert_equal(attributes, @node.attributes)
end