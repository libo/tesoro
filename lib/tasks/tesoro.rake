namespace :tesoro do
  desc "Import USD/DDK conversion rate by Danish National Bank"
  task import_usd_conversion: :environment do
    Conversion.import('USD')
    Rails.cache.clear # We must recompute all numbers...
  end
end
