# Async2

## Usage

```ruby
Async2.instance.get("http://linuxfr.org") do |body|
    puts body
end
```
