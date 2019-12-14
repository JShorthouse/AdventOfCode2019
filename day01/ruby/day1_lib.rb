def calc_fuel(mass)
  ((mass.to_f / 3.0) - 2.0).floor
end


def recursive_fuel(mass)
  fuel_sum = 0
  last_mass = mass

  loop do
    fuel = [0,calc_fuel(last_mass)].max
    fuel_sum += fuel
    last_mass = fuel

    break if fuel == 0
  end

  fuel_sum
end
