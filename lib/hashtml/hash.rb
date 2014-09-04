
class Hash

  # Checks if an 'hash' is a subset of the object
  #@param hash [Hash] pairs to verify
  #@return [Boolean]
  def include_pairs?(hash)
    hash.select { |k, v| self[k] != v }.empty?
  end
end