# Check password contains at least one double
# and only incrementing or equal numbers
def valid_password(password)
  password = password.to_s.split('').map(&:to_i)
  dubs = false
  for i in 1..5 do
    if password[i] == password[i-1] then 
      dubs = true 
    elsif password[i] < password[i-1] then
      return false
    end
  end
  return dubs
end

def valid_password_2(password)
  password = password.to_s.split('').map(&:to_i)
  dubs = false
  potential_dubs = false
  last_was_dubs = false
  for i in 1..5 do
    if password[i] == password[i-1] then 
      if !last_was_dubs then
        potential_dubs = true
      else
        potential_dubs =false
      end
      last_was_dubs = true
    else
      last_was_dubs = false

      if potential_dubs then
        dubs = true
      end

      if password[i] < password[i-1] then
        return false
      end
    end
  end
  # Edge case for end of input
  return dubs || potential_dubs
end
