# -*- encoding : utf-8 -*-
Given(/^a hash "([^"]*)"$/) do |wannabe|
  @hash = eval(wannabe)
end

When(/^is verified if the given hash includes the pairs from "([^"]*)"$/) do |new_wannabe|
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

When(/^a HashTML object is initialized with the given string$/) do
  @hashtml = HashTML.new(@html_string)
end

Then(/^a HashTML object should be obtained$/) do
  @hashtml.is_a?(HashTML)
end

Then(/^the HashTML object root element should have the name "([^"]*)"$/) do |name|
  assert_equal(name, @hashtml.root_node.name)
end

And(/^the HashTML object root element should have no attributes$/) do
  assert(@hashtml.root_node.attributes.empty?)
end

When(/^the HashTML node "([^"]*)" is accessed$/) do |node_path|
  iterations = node_path.split('.')
  object     = @hashtml.clone
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

Then(/^the HashTML node has name "([^"]*)"$/) do |name|
  assert_equal(name, @node.name)
end

And(/^the HashTML node has attributes "([^"]*)"$/) do |attributes|
  attributes = attributes.eql?('') ? {} : eval(attributes)
  assert_equal(attributes, @node.attributes)
end

And(/^the HashTML node "([^"]*)" text is accessed$/) do |node_path|
  object = step("the HashTML node \"#{node_path}\" is accessed")
  @text  = object.text
end

Then(/^the HashTML node has text "([^"]*)"$/) do |text|
  assert_equal(text, @text)
end

And(/^the HashTML node text "([^"]*)" is changed to "([^"]*)"$/) do |node_path, value|
  object      = step("the HashTML node \"#{node_path}\" is accessed")
  object.text = value
end

And(/^the HashTML node "([^"]*)" attribute "([^"]*)" is accessed$/) do |node_path, attribute|
  object           = step("the HashTML node \"#{node_path}\" is accessed")
  @attribute_value = object.attributes[attribute]
end

And(/^the HashTML node attribute value is "([^"]*)"$/) do |value|
  assert_equal(value, @attribute_value)
end

When(/^the HashTML node "([^"]*)" attribute "([^"]*)" is changed to "([^"]*)"$/) do |node_path, attribute, value|
  object                       = step("the HashTML node \"#{node_path}\" is accessed")
  object.attributes[attribute] = value
end

Given(/^a html file named "([^"]*)"$/) do |filename|
  @file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources', filename))
end

When(/^a HashTML object is initialized with the given file content$/) do
  html     = Nokogiri::HTML(File.read(@file))
  @hashtml = HashTML.new(html)
end