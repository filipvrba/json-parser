# json-parser

## Example
```ruby
path = File.absolute_path("../../share/db.json", __FILE__)
db   = JsonParser.new path

db.on :value, "hello"  # Create new symbols for empty json (first call)
puts db.parse :value   # Get or Set hash
```
