hashtml [ ![Codeship Status for MRod15/hashtml](https://codeship.io/projects/6dd49080-19a4-0132-515f-0a39251edeca/status)](https://codeship.io/projects/34440) [![Build Status](https://travis-ci.org/MRod15/hashtml.svg?branch=master)](https://travis-ci.org/MRod15/hashtml) [![Code Climate](https://codeclimate.com/github/MRod15/hashtml/badges/gpa.svg)](https://codeclimate.com/github/MRod15/hashtml) [![PullReview stats](https://www.pullreview.com/github/MRod15/hashtml/badges/master.svg?)](https://www.pullreview.com/github/MRod15/hashtml/reviews/master) [![Dependency Status](https://gemnasium.com/MRod15/hashtml.svg)](https://gemnasium.com/MRod15/hashtml)
=======

HashTML is a gem for parsing HTML documents to Ruby Hash-like objects

## Installation

HashTML is available as a RubyGem:

    gem install hashtml

## Usage

HashTML parses a Nokogiri::HTML::Document or anything that responds
to to_s with a string of valid HTML.
A HashTML object corresponding to the data structure of the given HTML
is generated.

### Example:

    html = <<-HTML
        <html>
            <body>
                <div id="d1" style="color: blue">
                    <h1>hello world!</h1>
                </div>
            </body>
        </html>
    HTML
    hashtml = HashTML.new(html)
    hashtml.inspect # => #<HashTML:0x00000001328650 @root_node=#<HashTML::Node:0x000000013283f8 @name="document", @attributes={}, @children=[#<HashTML::Node:0x00000001327ef8 @name="html", @attributes={}, @children=[#<HashTML::Node:0x00000001327a20 @name="body", @attributes={}, @children=[#<HashTML::Text:0x00000001326300 @text="\n    ">, #<HashTML::Node:0x00000001326288 @name="div", @attributes={"id"=>"d1", "style"=>"color: blue"}, @children=[#<HashTML::Text:0x0000000132c8b8 @text="\n        ">, #<HashTML::Node:0x0000000132c728 @name="h1", @attributes={}, @children=[#<HashTML::Text:0x0000000132b4e0 @text="hello world!">]>, #<HashTML::Text:0x0000000132a7c0 @text="\n    ">]>, #<HashTML::Text:0x00000001329a50 @text="\n    ">, #<HashTML::Node:0x000000013299d8 @name="div", @attributes={"id"=>"d2", "style"=>"color: green"}, @children=[#<HashTML::Text:0x000000013306c0 @text="\n        ">, #<HashTML::Node:0x00000001330620 @name="p", @attributes={}, @children=[#<HashTML::Text:0x0000000132ef00 @text="Lorem ipsum dolor sit amet, consectetur adipiscing elit.">]>, #<HashTML::Text:0x0000000132e5c8 @text="\n    ">]>, #<HashTML::Text:0x0000000132d6f0 @text="\n  ">]>]>]>>


HashTML allows you to convert the object to a Ruby Hash with to_h.

### Example:

    html = <<-HTML
        <html>
            <body>
                <div id="d1" style="color: blue">
                    <h1>hello world!</h1>
                </div>
            </body>
        </html>
    HTML
    hashtml = HashTML.new(html)
    hashtml.to_h # => {"document"=>{:attributes=>{}, :children=>[{"html"=>{:attributes=>{}, :children=>[{"body"=>{:attributes=>{}, :children=>[{:text=>"\n    "}, {"div"=>{:attributes=>{"id"=>"d1", "style"=>"color: blue"}, :children=>[{:text=>"\n        "}, {"h1"=>{:attributes=>{}, :children=>[{:text=>"hello world!"}]}}, {:text=>"\n    "}]}}, {:text=>"\n    "}, {"div"=>{:attributes=>{"id"=>"d2", "style"=>"color: green"}, :children=>[{:text=>"\n        "}, {"p"=>{:attributes=>{}, :children=>[{:text=>"Lorem ipsum dolor sit amet, consectetur adipiscing elit."}]}}, {:text=>"\n    "}]}}, {:text=>"\n  "}]}}]}}]}}


You can access elements and change them simply by "navigating" trough them.
And when you're done, simply regenerate your HTML by doing to_html!

### Example:

    html = <<-HTML
        <html>
            <body>
                <div id="d1" style="color: blue">
                    <h1>hello world!</h1>
                </div>
            </body>
        </html>
    HTML

    hashtml = HashTML.new(html)
    hashtml.document.hmtl.body.div.inspect # => #<HashTML::Node:0x00000000b6c128 @name="div", @attributes={"id"=>"d1", "style"=>"color: blue"}, @children=[#<HashTML::Text:0x00000000b72528 @text="\n        ">, #<HashTML::Node:0x00000000b72348 @name="h1", @attributes={}, @children=[#<HashTML::Text:0x00000000b71268 @text="hello world!">]>, #<HashTML::Text:0x00000000b704a8 @text="\n    ">]>

    hashtml.document.hmtl.body.div.attributes['id'] = 'new_id1'
    hashtml.document.hmtl.body.div.inspect # => #<HashTML::Node:0x00000000b6c128 @name="div", @attributes={"id"=>"new_id1", "style"=>"color: blue"}, @children=[#<HashTML::Text:0x00000000b72528 @text="\n        ">, #<HashTML::Node:0x00000000b72348 @name="h1", @attributes={}, @children=[#<HashTML::Text:0x00000000b71268 @text="hello world!">]>, #<HashTML::Text:0x00000000b704a8 @text="\n    ">]>

    hashtml.document.hmtl.body.div.h1.text # => 'hello world!'
    hashtml.document.hmtl.body.div.h1.text = 'such edit! wow'
    hashtml.document.hmtl.body.div.h1.text # => 'such edit! wow'

    hashtml.to_html # => <document><html><body>
                                 <div id="new_id1" style="color: blue">
                                     <h1>such edit! wow</h1>
                                 </div>
                             </body></html></document>


Worried about navigating and having tons of elements with the same tag at the same level?
That's not a problem! Just identify the node by it's attributes!

### Example:

    html = <<-HTML
    <html>
      <body>
        <div class="main">
          <span id="s1" style="color: blue">
            <h1>hello world!</h1>
          </span>
          <span id="s2" style="color: green">
            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
          </span>
        </div>
      </body>
    </html>
    HTML

    hashtml = HashTML.new(html)
    hashtml.document.html.body.div.span({'id' => 's2'}).attributes['id'] = 'new_id2'
    hashtml.document.html.body.div.span({'id' => 's1'}).h1.text = 'such edit! much navigation! wow'

    hashtml.to_html # => <document><html><body>
                             <div class="main">
                               <span id="s1" style="color: blue">
                                 <h1>such edit! much navigation! wow</h1>
                               </span>
                               <span id="new_id2" style="color: green">
                                 <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
                               </span>
                             </div>
                           </body></html></document>

