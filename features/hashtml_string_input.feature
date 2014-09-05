Feature: Hashtml manipulation tests for an input string

  Background:
    Given a html string like
    """
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
    """


  Scenario: Hashtml object initialization from string
    When a Hashtml object is initialized with the given string
    Then a Hashtml object should be obtained


  Scenario: Hashtml object root node validation
    When a Hashtml object is initialized with the given string
    Then the Hashtml object root element should have the name "html"
    And the Hashtml object root element should have no attributes

  @debug
  Scenario Outline: Hashtml object validations
    When a Hashtml object is initialized with the given string
    And the Hashtml node "<node_path>" is accessed
    Then the Hashtml node has name "<node_name>"
    And the Hashtml node has attributes "<node_attributes>"

  Examples:
    | node_path                            | node_name | node_attributes                           |
#    | html.body                            | body      |                                           |
#    | html.body.div                        | div       | {'class' => 'main'}                       |
#    | html.body.div.span                   | span      | {'id' => 's1', 'style' => 'color: blue'}  |
#    | html.body.div.span.h1                | h1        |                                           |
#    | html.body.div.span({'id' => 's2'})   | span      | {'id' => 's2', 'style' => 'color: green'} |
    | html.body.div.span({'id' => 's2'}).p | p         |                                           |
