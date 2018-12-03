# binary search works only on sorted arrays
# two ways
# iterative method will continue to run within a loop condition
# recursive method will call binary_search on a subarray 

# iterative

def binary_search(array, key)
    low, high = 0, array.length - 1
    while low <= high
      mid = (low + high) >> 1
      case key <=> array[mid]  #  if key < array[mid] then return -1 if key = array[mid] then 0 else return 1
	 when 1
          low = mid + 1
        when -1
          high = mid - 1
        else
          return mid
      end
    end
end

def recursive_bsearch(array, key)
  low, high = [0, array.length - 1]
  if low >= high
    return false
  end
  mid = (low + high) / 2
  if array[mid] == key
    mid
  elsif array[mid] < key
    recursive_bsearch(array[(mid+1)..high], key)
  else
    recursive_bsearch(array[low..mid], key)
  end
end


arr = [0, 0, 3, 4, 6, 8, 9, 10, 12, 12, 12, 12, 14, 16, 16, 16, 18, 18, 18, 19]
key = 14

p binary_search(arr, key)
p recursive_bsearch(arr,key)

