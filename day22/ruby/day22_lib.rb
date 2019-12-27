class Card
  attr_accessor :prev, :id, :next
  def initialize(id)
    @id = id
  end

  def inspect
    return @id
  end
end

class CardStack
  def initialize(size = nil)
    @head = nil
    @tail = nil
    @length = 0

    if size then
      size.times do |id|
        insert(id)
      end
    end
  end

  def insert(id)
    card = Card.new(id)
    if @head == nil then
      @head = card
      @tail = card
    else
      card.prev = @tail
      @tail.next = card
      @tail = card
    end
    @length += 1
  end

  def reverse
    temp = @head
    @head = @tail
    @tail = temp

    temp = @head.prev
    @head.prev = @head.next
    @head.next = temp

    card = @head
    while card = card.next do
      temp = card.prev
      card.prev = card.next
      card.next = temp
    end
  end

  def deal_into_new
    reverse
  end

  def cut_cards(idx)
    if idx == 0 then raise "Invalid argument" end
    if idx > 0 then
      new_head = @head
      idx.times do
        new_head = new_head.next
      end

      old_head = @head
      new_tail = new_head.prev

      @head = new_head
      new_head.prev = nil

      @tail.next = old_head
      old_head.prev = @tail
      @tail = new_tail
      new_tail.next = nil
    else
      new_tail = @tail
      (idx.abs).times do
        new_tail = new_tail.prev
      end

      old_tail = @tail
      new_head = new_tail.next

      @tail = new_tail
      new_tail.next = nil

      @head.prev = old_tail
      old_tail.next = @head
      @head = new_head
      new_head.prev = nil
    end
  end

  def deal_with_inc(inc)
    new_order = Array.new(@length)

    # Add cards to array in new order
    idx = 0
    cur_card = @head
    @length.times do
      new_order[idx] = cur_card
      cur_card = cur_card.next
      idx += inc
      idx = idx % @length
    end

    # Update cards so linked list reflects array order
    @head = new_order[0]
    @head.prev = nil
    @head.next = new_order[1]

    @tail = new_order[@length - 1]
    @tail.next = nil
    @tail.prev = new_order[@length - 2]

    for i in 1..(@length - 2) do
      new_order[i].prev = new_order[i-1]
      new_order[i].next = new_order[i+1]
    end
  end

  def get_pos_of(id)
    cur_card = @head
    @length.times do |i|
      if cur_card.id == id then return i end
      cur_card = cur_card.next
    end
  end

  def as_arr # For testing
    arr = []
    card = @head
    arr.push(@head.id)

    while card = card.next do
      arr.push(card.id)
      #print " #{card.id}"
      #if card == @head then print "H" end
      #if card == @tail then print "T" end
    end
    return arr
  end
end

def process_commands(stack, commands)
  commands.each do |line|
    line = line.chomp
    puts "Processing #{line}"
    if line == "deal into new stack" then
      stack.deal_into_new
      next
    end

    match = line.match(/([a-zA-Z ]+) (-?[0-9]+)/)
    command = match[1]
    number = match[2].to_i

    if command == "deal with increment" then
      stack.deal_with_inc(number)
    elsif command == "cut" then
      stack.cut_cards(number)
    else
      raise "Unrecognised command in input"
    end
  end
end


def process_input(stack, filename)
  com_arr = []
  File.readlines(filename).each do |line|
    com_arr.push(line.chomp)
  end
  process_commands(stack, com_arr)
end
