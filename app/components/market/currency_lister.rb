module Market
  class CurrencyLister
    def self.call
      YAML.load_file("#{Rails.root.to_s}/config/data/currencies.yml")
    end
  end
end
