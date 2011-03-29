Thread.new { Goldberg::GoldbergInit.new.start_poller } if ::Rails.env == "development"
