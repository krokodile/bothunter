module Fb
  def self.arg2username arg
    ::Fb.arg2id arg, true
  end
end
