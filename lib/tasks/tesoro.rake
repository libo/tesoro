namespace :tesoro do
  desc "Import USD/DDK conversion rate by Danish National Bank"
  task import_usd_conversion: :environment do
    Conversion.wipe_and_import('USD')
  end

  desc "Backfill Event#sort_column values"
  task backfill_event_sort_column: :environment do
    Event.where(sort_column: nil).each do |event|
      event.save!
    end
  end
end
