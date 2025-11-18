# frozen_string_literal: true

module Core
  module Services
    module Concerns
      module RecordLocator
        def locate_record(model_class, id)
          GlobalID::Locator.locate(id) || model_class.find_by(id: id)
        end

        def extract_record_id(model_class, id)
          locate_record(model_class, id)&.id
        end
      end
    end
  end
end
