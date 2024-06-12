module Market
  class CurrencyLister
    def call
      YAML.load_file("#{Rails.root.to_s}/config/currencies.yml")
    end
  end
end
