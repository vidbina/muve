module Muve
  module Helper
    def self.symbolize_keys(hash)
      hash.map { |k, v| { k.to_sym => v } }.inject(&:merge)
    end
  end
end
