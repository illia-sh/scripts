require 'benchmark'

arr = Array.new(99999) { rand(1...9) }
key = arr.sample

time1 = Benchmark.measure {
def linear_search(array, key)
  if array.index(key).nil?
    return -1
  else
    return "#{key} at index #{array.index(key)}"
  end
end
}


time2 = Benchmark.measure {
def linear_search_2(array, key)
  i = 0
  while i < array.length
      if array[i] == key
        return "#{key} at index #{array.index(key)}"
      end
      i+=1
    end
    return -1
end
}

p linear_search(arr, key)
puts time1.real

p linear_search_2(arr, key)
puts time2.real
