-- Sample challenges for the MVP

-- Challenge 1: Hello World (Free)
INSERT INTO public.challenges (
    title,
    description,
    starter_code,
    test_script,
    is_premium,
    difficulty,
    category,
    sort_order
) VALUES (
    'Hello Flutter World',
    '# Hello Flutter World

Welcome to your first Flutter challenge! 

## Task
Create a simple Dart function that returns the string "Hello, Flutter World!".

## Requirements
- Function name should be `getGreeting()`
- Should return exactly "Hello, Flutter World!"
- No parameters needed

## Example
```dart
print(getGreeting()); // Should output: Hello, Flutter World!
```

Good luck! 🚀',
    'String getGreeting() {
  // Your code here
  return "";
}

void main() {
  print(getGreeting());
}',
    'import "main.dart";

void main() {
  String result = getGreeting();
  assert(result == "Hello, Flutter World!", "Expected: Hello, Flutter World!, Got: $result");
  print("✅ Test passed!");
}',
    false,
    'easy',
    'basics',
    1
);

-- Challenge 2: Simple Counter (Free)
INSERT INTO public.challenges (
    title,
    description,
    starter_code,
    test_script,
    is_premium,
    difficulty,
    category,
    sort_order
) VALUES (
    'Simple Counter',
    '# Simple Counter

Create a simple counter function in Dart.

## Task
Implement a function called `incrementCounter()` that:
- Takes an integer parameter `current`
- Returns the next number (current + 1)

## Requirements
- Function name: `incrementCounter(int current)`
- Should return `current + 1`

## Example
```dart
print(incrementCounter(5)); // Should output: 6
print(incrementCounter(0)); // Should output: 1
```',
    'int incrementCounter(int current) {
  // Your code here
  return 0;
}

void main() {
  print(incrementCounter(5));
  print(incrementCounter(0));
}',
    'import "main.dart";

void main() {
  assert(incrementCounter(5) == 6, "Expected: 6, Got: ${incrementCounter(5)}");
  assert(incrementCounter(0) == 1, "Expected: 1, Got: ${incrementCounter(0)}");
  assert(incrementCounter(-1) == 0, "Expected: 0, Got: ${incrementCounter(-1)}");
  print("✅ All tests passed!");
}',
    false,
    'easy',
    'basics',
    2
);

-- Challenge 3: List Operations (Free)
INSERT INTO public.challenges (
    title,
    description,
    starter_code,
    test_script,
    is_premium,
    difficulty,
    category,
    sort_order
) VALUES (
    'List Sum Calculator',
    '# List Sum Calculator

Work with Dart lists to calculate the sum of numbers.

## Task
Create a function `calculateSum()` that:
- Takes a `List<int>` parameter called `numbers`
- Returns the sum of all numbers in the list
- Returns 0 if the list is empty

## Requirements
- Function name: `calculateSum(List<int> numbers)`
- Handle empty lists gracefully

## Example
```dart
print(calculateSum([1, 2, 3, 4])); // Should output: 10
print(calculateSum([])); // Should output: 0
```',
    'int calculateSum(List<int> numbers) {
  // Your code here
  return 0;
}

void main() {
  print(calculateSum([1, 2, 3, 4]));
  print(calculateSum([]));
  print(calculateSum([10, -5, 3]));
}',
    'import "main.dart";

void main() {
  assert(calculateSum([1, 2, 3, 4]) == 10, "Expected: 10, Got: ${calculateSum([1, 2, 3, 4])}");
  assert(calculateSum([]) == 0, "Expected: 0, Got: ${calculateSum([])}");
  assert(calculateSum([10, -5, 3]) == 8, "Expected: 8, Got: ${calculateSum([10, -5, 3])}");
  assert(calculateSum([100]) == 100, "Expected: 100, Got: ${calculateSum([100])}");
  print("✅ All tests passed!");
}',
    false,
    'easy',
    'basics',
    3
);

-- Challenge 4: String Manipulation (Premium)
INSERT INTO public.challenges (
    title,
    description,
    starter_code,
    test_script,
    is_premium,
    difficulty,
    category,
    sort_order
) VALUES (
    'Palindrome Checker',
    '# Palindrome Checker 🔒

Check if a string reads the same forwards and backwards.

## Task
Create a function `isPalindrome()` that:
- Takes a `String` parameter
- Returns `true` if the string is a palindrome
- Should ignore case and spaces
- Returns `false` otherwise

## Requirements
- Function name: `isPalindrome(String text)`
- Case-insensitive comparison
- Ignore spaces and punctuation

## Example
```dart
print(isPalindrome("racecar")); // true
print(isPalindrome("A man a plan a canal Panama")); // true
print(isPalindrome("hello")); // false
```',
    'bool isPalindrome(String text) {
  // Your code here
  return false;
}

void main() {
  print(isPalindrome("racecar"));
  print(isPalindrome("A man a plan a canal Panama"));
  print(isPalindrome("hello"));
}',
    'import "main.dart";

void main() {
  assert(isPalindrome("racecar") == true, "racecar should be a palindrome");
  assert(isPalindrome("A man a plan a canal Panama") == true, "A man a plan a canal Panama should be a palindrome");
  assert(isPalindrome("hello") == false, "hello should not be a palindrome");
  assert(isPalindrome("Madam") == true, "Madam should be a palindrome");
  assert(isPalindrome("") == true, "Empty string should be a palindrome");
  print("✅ All tests passed!");
}',
    true,
    'medium',
    'strings',
    4
);

-- Challenge 5: Widget Class (Premium)
INSERT INTO public.challenges (
    title,
    description,
    starter_code,
    test_script,
    is_premium,
    difficulty,
    category,
    sort_order
) VALUES (
    'Simple Widget Class',
    '# Simple Widget Class 🔒

Create a basic Widget class structure similar to Flutter.

## Task
Create a `SimpleWidget` class that:
- Has a `name` property (String)
- Has a `visible` property (bool, default: true)
- Has a constructor that takes both parameters
- Has a `render()` method that returns a description string

## Requirements
- Class name: `SimpleWidget`
- Constructor: `SimpleWidget(this.name, {this.visible = true})`
- Method: `String render()` returns "Widget: [name] (visible: [visible])"

## Example
```dart
var widget = SimpleWidget("Button", visible: false);
print(widget.render()); // "Widget: Button (visible: false)"
```',
    'class SimpleWidget {
  // Your code here
}

void main() {
  var widget1 = SimpleWidget("Button");
  var widget2 = SimpleWidget("Text", visible: false);
  
  print(widget1.render());
  print(widget2.render());
}',
    'import "main.dart";

void main() {
  var widget1 = SimpleWidget("Button");
  var widget2 = SimpleWidget("Text", visible: false);
  
  assert(widget1.name == "Button", "Expected name: Button");
  assert(widget1.visible == true, "Expected visible: true");
  assert(widget1.render() == "Widget: Button (visible: true)", "Unexpected render output for widget1");
  
  assert(widget2.name == "Text", "Expected name: Text");
  assert(widget2.visible == false, "Expected visible: false");
  assert(widget2.render() == "Widget: Text (visible: false)", "Unexpected render output for widget2");
  
  print("✅ All tests passed!");
}',
    true,
    'medium',
    'classes',
    5
);