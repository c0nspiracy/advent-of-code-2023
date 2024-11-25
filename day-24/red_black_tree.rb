# frozen_string_literal: true

class Node
  attr_accessor :key, :value, :color, :left, :right, :parent

  def initialize(key, value, color, left = nil, right = nil, parent = nil)
    @key = key
    @value = value
    @color = color
    @left = left
    @right = right
    @parent = parent
  end
end

class RedBlackTree
  attr_accessor :root

  def initialize
    @root = nil
  end

  def insert(key, value)
    node = Node.new(key, value, :red)
    if @root.nil?
      @root = node
    else
      insert_recursive(@root, node)
      fix_insert(node)
    end
  end

  def search(key)
    search_recursive(@root, key)
  end

  def delete(key)
    node = search(@root, key)

    return if node.nil?

    if node.left && node.right
      successor = find_minimum(node.right)
      node.key, node.value = successor.key, successor.value
      node = successor
    end

    child = node.left || node.right

    if node.color == :black
      node.color = child.color if child
      fix_delete(node)
    end

    if node.parent
      if node == node.parent.left
        node.parent.left = child
      else
        node.parent.right = child
      end

      child.parent = node.parent
    else
      @root = child
    end
  end

  def above(key)
    node = search(@root, key)
    return nil if node.nil?

    above_node(node)
  end

  def below(key)
    node = search(@root, key)
    return nil if node.nil?

    below_node(node)
  end

  private

  def insert_recursive(root, node)
    if node.key < root.key
      if root.left.nil?
        root.left = node
        node.parent = root
      else
        insert_recursive(root.left, node)
      end
    else
      if root.right.nil?
        root.right = node
        node.parent = root
      else
        insert_recursive(root.right, node)
      end
    end
  end

  def fix_insert(node)
    while node.parent && node.parent.color == :red
      if node.parent == node.parent.parent.left
        uncle = node.parent.parent.right

        if uncle && uncle.color == :red
          node.parent.color = :black
          uncle.color = :black
          node.parent.parent.color = :red
          node = node.parent.parent
        else
          if node == node.parent.right
            node = node.parent
            rotate_left(node)
          end

          node.parent.color = :black
          node.parent.parent.color = :red
          rotate_right(node.parent.parent)
        end
      else
        uncle = node.parent.parent.left

        if uncle && uncle.color == :red
          node.parent.color = :black
          uncle.color = :black
          node.parent.parent.color = :red
          node = node.parent.parent
        else
          if node == node.parent.left
            node = node.parent
            rotate_right(node)
          end

          node.parent.color = :black
          node.parent.parent.color = :red
          rotate_left(node.parent.parent)
        end
      end
    end

    @root.color = :black
  end

  def rotate_left(node)
    right_child = node.right
    node.right = right_child.left

    if right_child.left
      right_child.left.parent = node
    end

    right_child.parent = node.parent

    if node.parent.nil?
      @root = right_child
    elsif node == node.parent.left
      node.parent.left = right_child
    else
      node.parent.right = right_child
    end

    right_child.left = node
    node.parent = right_child
  end

  def rotate_right(node)
    left_child = node.left
    node.left = left_child.right

    if left_child.right
      left_child.right.parent = node
    end

    left_child.parent = node.parent

    if node.parent.nil?
      @root = left_child
    elsif node == node.parent.right
      node.parent.right = left_child
    else
      node.parent.left = left_child
    end

    left_child.right = node
    node.parent = left_child
  end

  def search_recursive(node, key)
    return nil if node.nil? || node.key == key

    if key < node.key
      search_recursive(node.left, key)
    else
      search_recursive(node.right, key)
    end
  end

  def fix_delete(node)
    while node != @root && (node.nil? || node.color == :black)
      if node == node.parent.left
        sibling = node.parent.right

        if sibling.color == :red
          sibling.color = :black
          node.parent.color = :red
          rotate_left(node.parent)
          sibling = node.parent.right
        end

        if (sibling.left.nil? || sibling.left.color == :black) && (sibling.right.nil? || sibling.right.color == :black)
          sibling.color = :red
          node = node.parent
        else
          if sibling.right.nil? || sibling.right.color == :black
            sibling.left.color = :black
            sibling.color = :red
            rotate_right(sibling)
            sibling = node.parent.right
          end

          sibling.color = node.parent.color
          node.parent.color = :black
          sibling.right.color = :black
          rotate_left(node.parent)
          node = @root
        end
      else
        sibling = node.parent.left

        if sibling.color == :red
          sibling.color = :black
          node.parent.color = :red
          rotate_right(node.parent)
          sibling = node.parent.left
        end

        if (sibling.right.nil? || sibling.right.color == :black) && (sibling.left.nil? || sibling.left.color == :black)
          sibling.color = :red
          node = node.parent
        else
          if sibling.left.nil? || sibling.left.color == :black
            sibling.right.color = :black
            sibling.color = :red
            rotate_left(sibling)
            sibling = node.parent.left
          end

          sibling.color = node.parent.color
          node.parent.color = :black
          sibling.left.color = :black
          rotate_right(node.parent)
          node = @root
        end
      end
    end

    node.color = :black if node
  end

  def above_node(node)
    return nil if node.nil?

    if node.left
      return find_maximum(node.left)
    end

    parent = node.parent
    while parent && node == parent.left
      node = parent
      parent = parent.parent
    end

    parent
  end

  def below_node(node)
    return nil if node.nil?

    if node.right
      return find_minimum(node.right)
    end

    parent = node.parent
    while parent && node == parent.right
      node = parent
      parent = parent.parent
    end

    parent
  end

  def find_maximum(node)
    while node.right
      node = node.right
    end
    node
  end

  def find_minimum(node)
    while node.left
      node = node.left
    end
    node
  end
end
