Feature: test hash include_pairs?

  Scenario Outline: Verifying hash subsets
    Given a hash "<hash>"
    When is verified if the given hash includes the pairs from "<new_hash>"
    Then the hash search result should be <result>

  Examples:
    | hash                                    | new_hash              | result |
    | { 'a' => 1,  'b' => 2  }                | { 'b' => 2 }          | true   |
    | { 'a' => { 'b' => 1 } }                 | {'a' => { 'b' => 1 }} | true   |
    | { :a => 1, :b => 2, :d => 3 }           | { :c => 2, :d => 3 }  | false  |
    | { :a => 1, :b => { :c => 2, :d => 3 } } | {:b => { :c => 2 }}   | false  |
    | { :a => 1, :c => 2, :d => 3 }           | { :c => 2, :d => 3 }  | true   |