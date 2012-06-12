# p "1000000".gsub(/([0-9])(?=(?:[0-9]{3})+\z)/, '\1,')

def keta(value)
  value.gsub(/([0-9])(?=(?:[0-9]{3})+\z)/, '\1,')
end

p keta("1000000")

# 
# "1,000,000"
# copy output
# Program exited with code #0 after 0.02 seconds.