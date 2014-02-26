require 'nokogiri'
require File.join(File.dirname(__FILE__), 'hashtml', 'hash.rb')
#
# HashTML translates between HTML documents and Ruby Hash-like objects.
# This work is loosely inspired on the work done by CobraVsMongoose.
# (see http://cobravsmongoose.rubyforge.org/)
#
class HashTML

  attr_reader :root_node

  # Returns a Hash corresponding to the data structure of the given HTML,
  # which should be a Nokogiri::HTML::Document or anything that responds to to_s
  # with a string of valid HTML.
  #@param html [Nokogiri::HTML::Document], or
  #@param html [String] document to parse
  #@return [Hash]
  #@example
  #  html = '<span id="row_29" class="step param">true</span>'
  #  HashTML.new(xml).to_h
  #  # => {
  #         "span" => {
  #           :children => [
  #             {
  #               :text => "true"
  #             }
  #           ],
  #           :attributes => {
  #             "id" => "row_29",
  #             "class" => "step param"
  #           }
  #         }
  #       }
  #
  def initialize(html)
    doc        = (html.is_a?(Nokogiri::HTML::Document) ? html : Nokogiri::HTML(html.to_s))
    @root_node = HashTML::Node.new(doc)
  end


  # Returns an HTML string corresponding to the data structure of the given Hash.
  #@return [String]
  #@example
  #  hash = { "span" =>
  #           {
  #             :children => [ { :text => "true" } ],
  #             :attributes => { "id" => "row_29", "class" => "step param" }
  #           }
  #         }
  #  HTMLParser.hash_to_html(hash)
  #  # => "<span id="row_29" class="step param">true</span>"
  #
  def to_html
    @root_node.to_html
  end

  def to_h
    @root_node.to_h
  end

  def method_missing(method, *args)
    method           = method.to_s
    attributes, _nil = args
    attributes       ||= {}
    if method.end_with?("?")
      key = method[0..-2]
      _check_for_presence(key, attributes)
    else
      _get_value(method, attributes)
    end
  end

  private

  def _check_for_presence(key, attributes={})
    !!_get_value(key, attributes)
  end

  def _get_value(key, attributes={})
    #$logger.debug("Looking for '#{key}'")
    #$logger.debug('It\'s the root node!')
    return nil unless @root_node.name == key
    return @root_node unless attributes
    return ((@root_node.attributes and @root_node.attributes.include_pairs?(attributes)) ? @root_node : nil)
  end

  class InvalidAttributeValuePairError < StandardError
  end

  public

  class << self
    def to_hashtml(hash)
      convert_to_hashtml(hash)
    end

    def to_html(hash)
      convert_to_hashtml(hash).to_html
    end

    private
    def convert_to_hashtml(hash)
      #$logger.warn(hash)
      hashtml = nil
      hash.each do |key, value|
        return HashTML::Text.new(value) if key == :text
        hashtml            = HashTML::Node.new
        hashtml.name       = key
        hashtml.attributes = (value[:attributes] or {})
        hashtml.children   = value[:children].map { |child| convert_to_hashtml(child) }
      end
      #$logger.debug hashtml
      hashtml
    end
  end

  class Node
    attr_accessor :name, :attributes, :children

    def initialize(node=nil)
      return unless node
      #$logger.warn "Analysing node: #{node.name}\n#{node}"
      @name       = node.name
      @attributes = node.respond_to?(:attributes) ? get_html_node_attributes(node) : {}
      @children   = get_html_node_children(node)
      #$logger.debug(@children, 'Children:')
    end

    def to_h
      { @name => { children: @children.map { |child| child.to_h }, attributes: @attributes } }
    end

    def to_html
      space          = (@attributes.any? ? ' ' : '')
      children_html  = @children.map { |child| child.to_html }.join
      attribute_list = @attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
      "<#{@name}#{space}#{attribute_list}>#{children_html}</#{@name}>"
    end

    def method_missing(method, *args)
      method                      = method.to_s
      #$logger.debug(method)
      #$logger.debug(args)
      attributes, new_value, _nil = args
      attributes                  ||= {}
      if method.end_with?("?")
        key = method[0..-2]
        _check_for_presence(key, attributes)
      elsif method.end_with?("=")
        key       = method[0..-2]
        new_value, attributes = attributes, {} if new_value.nil?
        _change_value(key, attributes, new_value)
      else
        _get_value(method, attributes)
      end
    end

    private

    def _check_for_presence(key, attributes={})
      !!_get_value(key, attributes)
    end

    def _get_value(key, attributes={})
      #$logger.debug("Looking for '#{key}'")
      #$logger.debug('It\'s a child node!')
      if key == 'text'
        #$logger.debug('Getting node text...')
        return @children.map { |child| child.text if child.is_a?(HashTML::Text) }.reject(&:nil?).join
      else
        @children.each do |child|
          next if child.is_a?(HashTML::Text)
          #$logger.debug child.attributes
          return child if (child.name == key and child.attributes.include_pairs?(attributes))
        end
      end
      nil
    end

    def _change_value(key, attributes, new_value)
      #$logger.debug("Looking for '#{key}'")
      #$logger.debug('It\'s a child node!')
      if key == 'text'
        #$logger.debug("Changing node text to '#{new_value}'...")
        #$logger.warn(@children)
        new_children = @children.select { |child| !child.is_a?(HashTML::Text) }
        @children    = new_children.empty? ? [HashTML::Text.new(new_value)] : [new_children, HashTML::Text.new(new_value)]
        #$logger.warn(@children)
      else
        #$logger.debug('Changing node value...')
        @children.each_with_index do |child, index|
          next if child.is_a?(HashTML::Text)
          if child.name == key and child.attributes.include_pairs?(attributes)
            @children[index] = new_value
          end
        end
      end
    end

    def get_html_node_children(node)
      #$logger.debug "Node children:\n#{node.children}"
      node.children.map do |child|
        #$logger.info("Child:\n#{child}\nChild class: '#{child.class}'")
        #$logger.info(child)
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

    def get_html_node_attributes(node)
      #$logger.debug "Node attributes: #{node.attributes}"
      Hash[node.attributes.map { |name, value| [name, value.value] }]
    end

  end

  class Text
    attr_accessor :text

    def initialize(text)
      @text = text
    end

    def to_h
      { text: @text }
    end

    def to_html
      @text
    end
  end

  class ParseError < RuntimeError
  end

end