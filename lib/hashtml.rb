# -*- encoding : utf-8 -*-
require 'nokogiri'
require File.join(File.dirname(__FILE__), 'hashtml', 'hash.rb')
#
# HashTML translates between HTML documents and Ruby Hash-like objects.
# This work is loosely inspired on the work done by CobraVsMongoose.
# (see http://cobravsmongoose.rubyforge.org/)
#
class HashTML
  attr_reader :root_node

  # Returns a HashTML object corresponding to the data structure of the given HTML,
  # which should be a Nokogiri::HTML::Document or anything that responds to to_s
  # with a string of valid HTML.
  # @param html [Nokogiri::HTML::Document|String], or document to parse
  # @return [HashTML]
  def initialize(html)
    doc        = (html.is_a?(Nokogiri::HTML::Document) ? html : Nokogiri::HTML(html))
    @root_node = HashTML::Node.new(doc)
  end


  # Returns an HTML string corresponding to the data structure of the given Hash.
  # @return [String]
  def to_html
    @root_node.to_html
  end

  # Converts the HashTML object to a hash
  # @return [Hash]
  def to_h
    @root_node.to_h
  end

  # Accessor methods
  # @param method [String] accessor
  # @param args [Array] arguments
  # @return [Object]
  def method_missing(method, *args)
    method           = method.to_s
    attributes, _nil = args
    attributes       ||= {}
    if method.end_with?('?')
      key = method[0..-2]
      _check_for_presence(key, attributes)
    else
      _get_value(method, attributes)
    end
  end

  private
  # Validates the presence of an attribute
  # @param key [String] attribute name
  # @param attributes [Hash] attribute attributes
  # @return [Boolean]
  def _check_for_presence(key, attributes={})
    !!_get_value(key, attributes)
  end

  # Returns the value of node path
  # @param key [String] attribute name
  # @param attributes [Hash] attribute attributes
  # @return [Object]
  def _get_value(key, attributes={})
    return nil unless @root_node.name == key
    return @root_node unless attributes
    return ((@root_node.attributes and @root_node.attributes.include_pairs?(attributes)) ? @root_node : nil)
  end

  public

  class << self
    # Converts a Hash to a HashTML object
    # @param hash [Hash]
    # @return [HashTML]
    def to_hashtml(hash)
      convert_to_hashtml(hash)
    end

    # Converts a Hash to HTML
    # @param hash [Hash]
    # @return [String] HTML document
    def to_html(hash)
      convert_to_hashtml(hash).to_html
    end

    private
    # Converts a Hash to a HashTML object
    # @param hash [Hash]
    # @return [HashTML]
    def convert_to_hashtml(hash)
      hashtml = nil
      hash.each do |key, value|
        return HashTML::Text.new(value) if key == :text
        hashtml            = HashTML::Node.new
        hashtml.name       = key
        hashtml.attributes = (value[:attributes] or {})
        hashtml.children   = value[:children].map { |child| convert_to_hashtml(child) }
      end
      hashtml
    end
  end

  # HasHTML complex nodes wrapper
  class Node
    attr_accessor :name, :attributes, :children

    # Creates a new HasHTML::Node
    # @param node [Nokogiri::XML::Node]
    # @return [HasHTML::Node]
    def initialize(node=nil)
      return unless node
      node        = catch(:node) do
        if node.is_a?(Nokogiri::HTML::Document)
          node = node.children.each do |child|
            throw(:node, child) unless child.is_a?(Nokogiri::XML::DTD)
          end
        else
          throw(:node, node)
        end
      end
      @name       = node.name
      @attributes = node.respond_to?(:attributes) ? get_html_node_attributes(node) : {}
      @children   = get_html_node_children(node)
    end

    # Converts the node to Hash
    # @return [Hash]
    def to_h
      { @name => { children: @children.map { |child| child.to_h }, attributes: @attributes } }
    end

    # Converts the node to HTML
    # @return [String]
    def to_html
      space          = (@attributes.any? ? ' ' : '')
      children_html  = @children.map { |child| child.to_html }.join
      attribute_list = @attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
      "<#{@name}#{space}#{attribute_list}>#{children_html}</#{@name}>"
    end

    # Accessor methods
    # @param method [String] accessor
    # @param args [Array] arguments
    # @return [HasHTML::Node]
    def method_missing(method, *args)
      method                      = method.to_s
      attributes, new_value, _nil = args
      attributes                  ||= {}
      if method.end_with?('?')
        key = method[0..-2]
        _check_for_presence(key, attributes)
      elsif method.end_with?('=')
        key                   = method[0..-2]
        new_value, attributes = attributes, {} if new_value.nil?
        _change_value(key, attributes, new_value)
      else
        _get_value(method, attributes)
      end
    end

    private
    # Validates the presence of an attribute
    # @param key [String] attribute name
    # @param attributes [Hash] attribute attributes
    # @return [Boolean]
    def _check_for_presence(key, attributes={})
      !!_get_value(key, attributes)
    end

    # Returns the value of node path
    # @param key [String] attribute name
    # @param attributes [Hash] attribute attributes
    # @return [Object]
    def _get_value(key, attributes={})
      if key.eql?('text')
        @children.select { |child| child.is_a?(HashTML::Text) }.map(&:text).join
      else
        catch(:value) do
          @children.each do |child|
            next if child.is_a?(HashTML::Text)
            throw(:value, child) if child.name.eql?(key) and child.attributes.include_pairs?(attributes)
          end
        end
      end
    end

    # Changes the value of a node
    # @param key [String] attribute name
    # @param attributes [Hash] attribute attributes
    # @param new_value [Object] node new value
    # @return [Boolean]
    def _change_value(key, attributes, new_value)
      if key.eql?('text')
        new_children = @children.select { |child| !child.is_a?(HashTML::Text) }
        @children    = new_children.empty? ? [HashTML::Text.new(new_value)] : [new_children, HashTML::Text.new(new_value)]
      else
        @children.each_with_index do |child, index|
          next if child.is_a?(HashTML::Text)
          @children[index] = new_value if child.name.eql?(key) and child.attributes.include_pairs?(attributes)
        end
      end
    end

    # Fetches the HTML node children
    # @param node [Nokogiri::HTML::Node]
    def get_html_node_children(node)
      node.children.map do |child|
        case child.class.to_s
          when 'Nokogiri::XML::Text', 'Nokogiri::XML::CDATA'
            HashTML::Text.new(child.to_s)
          when 'Nokogiri::XML::Element'
            HashTML::Node.new(child)
          else
            nil
        end
      end.reject(&:nil?)
    end

    # Fetches the node attributes
    # @param node [Nokogiri::HTML::Node]
    def get_html_node_attributes(node)
      Hash[node.attributes.map { |name, value| [name, value.value] }]
    end
  end

  # HTML text nodes wrapper
  class Text
    attr_accessor :text

    # Creates a new HaHTML::Text
    # @return [HasHTML::Text]
    def initialize(text)
      @text = text
    end

    # Converts the node to Hash
    # @return [Hash]
    def to_h
      { text: @text }
    end

    # Converts the node to HTML
    # @return [String]
    def to_html
      @text
    end
  end
end