module Muve
  module Helper
    def self.symbolize_keys(hash = {})
      raise ArgumentError.new("argument must be a Hash but was a #{hash.class} #{hash}") unless hash.kind_of? Hash
      hash.map { |k, v| { k.to_sym => v } }.inject(&:merge)
    end
  end
end
