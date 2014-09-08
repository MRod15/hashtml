Feature: HashTML manipulation tests for an input string

  Background:
    Given a html file named "test.html"
    When a HashTML object is initialized with the given file content


  Scenario: HashTML object initialization from string
    Then a HashTML object should be obtained


  Scenario: HashTML object root node validation
    Then the HashTML object root element should have the name "html"
    And the HashTML object root element should have no attributes


  Scenario Outline: HashTML object validations
    And the HashTML node "<node_path>" is accessed
    Then the HashTML node has name "<node_name>"
    And the HashTML node has attributes "<node_attributes>"

  Examples:
    | node_path                            | node_name | node_attributes                           |
    | html.body                            | body      |                                           |
    | html.body.div                        | div       | {'class' => 'main'}                       |
    | html.body.div.span                   | span      | {'id' => 's1', 'style' => 'color: blue'}  |
    | html.body.div.span.h1                | h1        |                                           |
    | html.body.div.span({'id' => 's2'})   | span      | {'id' => 's2', 'style' => 'color: green'} |
    | html.body.div.span({'id' => 's2'}).p | p         |                                           |


  Scenario Outline: HashTML text nodes validations
    And the HashTML node "<node_path>" text is accessed
    Then the HashTML node has text "<text>"

  Examples:
    | node_path                            | text                                                     |
    | html.body.div.span.h1                | hello world!                                             |
    | html.body.div.span({'id' => 's2'}).p | Lorem ipsum dolor sit amet, consectetur adipiscing elit. |


  Scenario: HashTML text is changed on a text node
    And the HashTML node "html.body.div.span.h1" text is accessed
    And the HashTML node has text "hello world!"
    When the HashTML node text "html.body.div.span.h1" is changed to "edited text"
    And the HashTML node "html.body.div.span.h1" text is accessed
    Then the HashTML node has text "edited text"

  @debug
  Scenario Outline: HashTML node attribute is changed
    And the HashTML node "<node_path>" attribute "<attribute>" is accessed
    And the HashTML node attribute value is "<old_value>"
    When the HashTML node "<node_path>" attribute "<attribute>" is changed to "<new_value>"
    And the HashTML node "<node_path>" attribute "<attribute>" is accessed
    Then the HashTML node attribute value is "<new_value>"

  Examples:
    | node_path          | attribute | old_value   | new_value  |
    | html.body.div      | class     | main        | new_class  |
    | html.body.div.span | style     | color: blue | color: red |
