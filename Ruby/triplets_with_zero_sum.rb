# Three Elements That Sum To Zero
input = [0,-1,2,1,50,13,-20,432,1131,000,5.4,0.3,-0.5,0.5]

sorted = input.permutation(3).to_a
sorted.each do |array|
  if array.sum == 0
    p array
  end
end
