require 'csv'
def foo()
  "Hello!"
end

if caller.length == 0
  foo()
end
