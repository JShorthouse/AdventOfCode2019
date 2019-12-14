Item = Struct.new(:amount, :name)

class Recipe
  attr_accessor :product, :ingredients
  def initialize(product)
    @product = product
    @ingredients = []
  end
end


$recipes = {} # Mapping of string name to recipe


def input_to_string(filename)
  File.open(filename).read.chomp
end

def split_quantity_name(string)
  split = string.split(" ")
  return split[0], split[1]
end

def process_input(input)
  input.split("\n").each do |line|
    split = line.split("=>")
    ingredients = split[0].split(',').map(&:strip)
    product = split[1].strip

    prod_q, prod_n = split_quantity_name(product)
    product = Item.new(prod_q.to_i, prod_n)
    recipe = Recipe.new(product)

    ingredients.each do |ing|
      ing_q, ing_n = split_quantity_name(ing)
      ingredient = Item.new(ing_q.to_i, ing_n)
      recipe.ingredients.push(ingredient)
    end

    if $recipes[product] != nil then raise "Input error, recipe added twice" end
    $recipes[prod_n] = recipe
  end
end

def calculate_needed_ore(fuel_amount = 1)
  needed_products = {}
  needed_products["FUEL"] = fuel_amount
  needed_products.default = 0
  leftovers = {}
  leftovers.default = 0

  ore_needed = 0

  while needed_products.length > 0 do
    needed_products.keys.each do |item_name|

      amount_needed = needed_products[item_name]

      #puts ""
      #puts "Needed products: #{needed_products}"
      #puts "Item: #{item_name}"

      # Take any existing already produced
      existing_amount = leftovers[item_name]
      
      # Find recipe for this product
      #p $recipes
      recipe = $recipes[item_name]
      recipe_provides = recipe.product.amount
      #puts "Leftover products: #{leftovers}"
      #puts "Recipe: #{recipe.ingredients}"


      #puts "Leftover amount: #{existing_amount}"
      #puts "Needed armound: #{amount_needed}"

      recipe_repetition = 0

      total_amount = existing_amount

      #while total_amount < amount_needed do
      #  #puts "ta: #{total_amount}, rp: #{recipe_provides}"
      #  total_amount += recipe_provides
      #  recipe_repetition += 1
      #end
      
      #binary search
      min = 0
      max = amount_needed
     
      loop do
        middle = ((min + max) / 2).floor
        amount = existing_amount + (middle * recipe_provides)
        if amount >= amount_needed then
          max = middle
        else # amount < amount_needed
          min = middle + 1
        end
        break if max == min 
      end

      recipe_repetition = max
      total_amount = existing_amount + (recipe_repetition * recipe_provides)


      #puts "Total amount: #{total_amount}"
      #puts "Repetition: #{recipe_repetition}"

      # Add any leftover product to leftovers
      leftover_amount = total_amount - amount_needed


      if leftover_amount > 0 then
        leftovers[item_name] = leftover_amount
      else
        leftovers.delete(item_name)
      end

      # Remove product and add ingreidents to needed_products list
      needed_products.delete(item_name)

      #print "Consume "

      recipe.ingredients.each do |ingredient|
        if ingredient.name != "ORE" then
          #print "#{ingredient.amount * recipe_repetition} #{ingredient.name}, "
          needed_products[ingredient.name] += ingredient.amount * recipe_repetition
        else
          ore_needed += ingredient.amount * recipe_repetition
          #print "#{ingredient.amount * recipe_repetition} #{ingredient.name}, "
        end
      end
      #print "to produce #{total_amount} #{item_name}\n"
    end
  end
  return ore_needed
end

def calculate_fuel_for_ore(ore_limit)

  min = 0
  max = ore_limit
  middle = nil

  # Binary search
  loop do
    middle = (max + min)/2
    #puts "Calculating for #{middle} fuel"
    ore = calculate_needed_ore(middle)
    # Find value that goes over limit
    if ore > ore_limit then
      max = middle
    else
      min = middle + 1
    end
    #puts "Min: #{min}, Max: #{max}, Middle: #{middle}, ore: #{ore}"
    break if min == max
  end

  lowest_within_limit = max - 1
  return lowest_within_limit
end
